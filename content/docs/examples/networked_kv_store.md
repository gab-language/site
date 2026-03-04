---
title: "Networked Key-Value Store"
weight: 2
---

This example extends the [in-memory key-value store](/docs/examples/kv_store) with a TCP server. Clients connect and send text commands; the server parses each line, dispatches it to the store actor, and writes a response.

## The Protocol

Each request is a single newline-terminated line. Each response is a single newline-terminated line.

| Request | Response | No key response |
|---|---|---|
| `GET key` | `OK value` | `NONE` |
| `SET key value` | `OK` | — |
| `DELETE key` | `OK value` | `NONE` |

---

## Handling a Connection

Each accepted connection gets its own fiber. The fiber reads one line, dispatches to the store, writes the response, and recurses until the client disconnects:

```gab
serve_client: .def (IO.Sockets.t, (store) => do
  sock = self

  'Connected $'.sprintf(sock).println

  loop = () => do
    recurse = self

    sock
      .until('\n'.to\b)
      .then(line => do
        (cmd, args*) = line.as\s.unwrap.trim.split(' ')
        response = cmd.to\m.run_command(sock, store, args*)
        sock.write('$\n'.sprintf(response).to\b)
        recurse.()
      end)
      .else(() => do
        'Disconnected $'.sprintf(sock).println
      end)
  end

  loop.()
end)
```

Note that `self` is captured as `sock` immediately. Inside the nested `then:` block, `self` would refer to the block rather than the socket. Similarly, `recurse = self` inside `loop` captures the `loop` block so the `then:` branch can recurse after writing the response.

`sock.until('\n'.to\b)` blocks until a newline arrives or the connection closes. On success, the line is converted from binary to string, trimmed, and split on spaces.`cmd` takes the first token, `args*` collects the rest. `cmd.to\m` converts the command string to a message value, which dispatches through `run_command:`. On failure the disconnection is logged and the fiber exits.

The command handlers receive the socket, the store, and any remaining arguments:

```gab
run_command: .defcase {
  GET: (socket, store, key, rest*) => do
    store.store\get key
      .then((val) => 'OK $'.sprintf(val))
      .else(()    => 'NONE')
  end

  SET: (socket, store, key, val, rest*) => do
    store.store\set (key val)
      .then(() => 'OK')
  end

  DELETE: (socket, store, key, rest*) => do
    store.store\delete key
      .then((val) => 'OK $'.sprintf(val))
      .else(()    => 'NONE')
  end
}
```

The `defcase` keys are `GET:`, `SET:`, and `DELETE:`. They explicitly match what `to\m` produces from the wire protocol strings. `rest*` absorbs any extra tokens so malformed commands don't crash the handler. Missing arguments arrive as `nil:`, which the store returns `none:` for, propagating back to the client as `NONE`.

## The Accept Loop

The server accepts connections one at a time, immediately spawning a fiber for each and looping:

```gab
accept_loop: .def (IO.Sockets.t, (store) => do
  server = self

  self.accept
    .then((client) => do
      Fibers.make () => client.serve_client(store)
      server.accept_loop(store)
    end)
    .else(() => 'server closed'.println)
end)
```

`server = self` captures the socket before the `then:` block, where `self` would refer to the block. `accept` blocks until a client connects; a new fiber is spawned immediately and the loop recurses without waiting for that client to finish.

## Starting the Server

`start:` is defined on the store type. It creates the socket, binds, listens, and launches the accept loop in a fiber:

```gab
[Store.t] .defmodule {
  start: (host, port) => do
    server = Socket.make(tcp:).unwrap
    server.bind(host port).unwrap
    server.listen(128).unwrap
    'Listening on $:$'.sprintf(host port).println
    store = self
    Fibers.make () => server.accept_loop(store)
  end
}
```

Inside the fiber, `self` would refer to the fiber's own block. Because of this, we capture the `self` as `store` beforehand.

## Putting it Together

Here is how you can now use the store:

```gab
store  = Store.make
server = store.start('::1' 6379)
server.await
```

Connect with any TCP client:

```sh
$ echo "SET name Gab" | nc ::1 6379
OK

$ echo "GET name" | nc ::1 6379
OK Gab

$ echo "DELETE name" | nc ::1 6379
OK Gab

$ echo "GET name" | nc ::1 6379
NONE
```

## The Full Program

The full store module now looks like this:

```gab
Socket = IO.Sockets
Store  = store:

# --- Store actor ---

make: .def (Store, () => do
  ch = Channels.make

  loop = (state) => do
    (cmd, reply, args*) = ch >! .unwrap
    next_state = (cmd, reply, state, args*) .handle
    self.(next_state)
  end

  Fibers.make () => loop.({})

  ch
end)

handle: .defcase {
  store\get: (reply, state, k) => do
    reply <! (state.at k)
    state
  end

  store\set: (reply, state, k, v) => do
    reply <! ok:
    state.put(k, v)
  end

  store\delete: (reply, state, k) => do
    reply <! (state.at k)
    state.take(k)
  end
}

t: .def (Store, Channels.t)

[Store.t] .defmodule {
  store\get: (k) => do
    reply = Channels.make
    self <! (store\get: reply k)
    reply >! .unwrap
  end

  store\set: (k, v) => do
    reply = Channels.make
    self <! (store\set: reply k v)
    reply >! .unwrap
  end

  store\delete: (k) => do
    reply = Channels.make
    self <! (store\delete: reply k)
    reply >! .unwrap
  end

  start: (host, port) => do
    server = Socket.make(tcp:).unwrap
    server.bind(host port).unwrap
    server.listen(128).unwrap
    'Listing on $:$'.sprintf(host port).println
    store = self
    Fibers.make () => server.accept_loop(store)
  end
}

run_command: .defcase {
  GET: (socket, store, key, rest*) => do
    store.store\get key
      .then((val) => 'OK $'.sprintf(val))
      .else(()    => 'NONE')
  end

  SET: (socket, store, key, val, rest*) => do
    store.store\set (key val)
      .then(() => 'OK')
  end

  DELETE: (socket, store, key, rest*) => do
    store.store\delete key
      .then((val) => 'OK $'.sprintf(val))
      .else(()    => 'NONE')
  end
}

serve_client: .def (IO.Sockets.t, (store) => do
  sock = self

  'Connected $'.sprintf(sock).println

  loop = () => do
    recurse = self

    sock
      .until('\n'.to\b)
      .then(line => do
        (cmd, args*) = line.as\s.unwrap.trim.split(' ')
        response = cmd.to\m.run_command(sock, store, args*)
        sock.write('$\n'.sprintf(response).to\b)
        recurse.()
      end)
      .else(() => do
        'Disconnected $'.sprintf(sock).println
      end)
  end

  loop.()
end)

accept_loop: .def (IO.Sockets.t, (store) => do
  server = self

  self.accept
    .then((client) => do
      Fibers.make () => client.serve_client(store)
      server.accept_loop(store)
    end)
    .else(() => 'server closed'.println)
end)

store  = Store.make
server = store.start('::1' 6379)
server.await
```

## What to Notice

**`self` must be captured before nested blocks.** This appears three times in the program: `sock = self` in `serve_client`, `recurse = self` inside `loop`, and `store = self` in `start:`. In each case, a nested block would shadow `self` with its own receiver. Capturing early is the standard pattern whenever `self` needs to outlive the block it was introduced in.

**`to\m` makes strings dispatchable.** `cmd.to\m` converts the wire protocol string `'GET'` to the message `GET:`, which `defcase` can route on. The conversion is trivial at runtime and it means the command routing table is just a `defcase`, consistent with how dispatch works everywhere else in Gab.

**The accept loop is a fiber, not a primitive.** There's no built-in server loop.`accept_loop` is a recursive function that calls `accept`, hands the connection off, and calls itself. The structure is identical to the store's command loop. The same pattern appears everywhere in Gab: a fiber owns a resource, loops by recursing, and delegates work to other fibers.

**One store, many clients.** Every connection fiber holds a reference to the same store channel.

**`rest*` absorbs noise.** Extra tokens in a command are silently ignored. Missing arguments arrive as `nil:`, which the store returns `none:` for, propagating back as `NONE`. The server never crashes on malformed input.
