---
title: "Key-Value Store"
weight: 1
---

This example builds an in-memory key-value store. It is a complete, useful program and demonstrates how Gab's core features compose in practice.

By the end you'll have a store that can be safely read and written from any number of fibers.

## The Design

The store is a single fiber. It owns a record which it privately threads through recursive calls. No other fiber can touch that record directly.

The store's public face is a **channel**. Callers send command tuples into it:

1. The store fiber reads commands off the channel
2. It processes each one
3. It then sends the result back on the reply channel included in the command

The command name comes first in the tuple so it can be forwarded directly as the receiver of `handle:`.

```
caller fiber                   store fiber
    |                               |
    |-- (store\set: reply k v) ---------> ch
    |                               |-- state = state.put(k, v)
    |                               |-- reply <! ok:
    | <----------- ok: ------------ |
```

Because all state lives inside one fiber, parallel callers are automatically serialised. The design makes races structurally impossible.

## The Store Actor

`make:` creates a channel, spawns the store fiber, and returns the channel directly. The store **is** the channel. Callers hold a channel value and send commands into it.

```gab
Stores = store:

make: .def (Stores, () => do
  ch = Channels.make

  loop = (state) => do
    (cmd, reply, args*) = ch >! .unwrap
    next_state = (cmd, reply, state, args*) .handle
    self.(next_state)
  end

  Fibers.make () => loop.({})

  ch
end)
```

The fiber loops by recursing with `self.(next_state)`. `self` is the `loop` block receiving the empty message. Each iteration receives the next command with `ch >! .unwrap`, destructures it, injects `state` after `reply`, then forwards the whole tuple to `handle:`. Because `cmd` is first, it becomes the receiver of `handle:` naturally via tuple forwarding — no explicit dispatch required.

The command handlers each receive `(reply, state, args*)` and return the next state:

```gab
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
```

`store\get:` forwards the result of `state.at` directly — if the key exists the caller receives `(ok: value)`, otherwise `(none: nil:)`. `store\set:` replies with `ok:` and returns the updated state. `store\delete:` replies with the same result as `at` — telling the caller what was there — then returns the state with the key removed via `take:`.

## Clean up the api

The module is defined on the channel type directly, since the store is a channel:

```gab
# Define the t: message on our Store module, as is convention.
# Because a store *is* a channel, we'll use Channels.t as the type.
t: .def (Stores, Channels.t)

# Define messages on our Store.t
[Stores.t] .defmodule {
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
}
```

`defmodule` attaches messages directly to the `Store.t` type, so `self` inside each method is the channel itself. Each method creates a reply channel, sends the command, and blocks on `reply >! .unwrap` until the store responds.

## Putting it together

Here is an example of how we'd expect to use this api:

```gab
store = Stores.make

# Set some values
store.store\set('name', 'Gab')
store.store\set('version', '0.0.5')

# Get a value
store.store\get('name')
  .then((val) => 'name is: $'.sprintf(val).println)
  .else(()    => 'not found'.println)
# => name is: Gab

# Overwrite
store.store\set('name', 'cgab')
store.store\get('name')
  .then((val) => val.println)
# => cgab

# Delete
store.store\delete('version')
store.store\get('version')
  .else(() => 'not found'.println)
# => not found

# Missing key
store.store\get('missing')
  .else(() => 'not found'.println)
# => not found
```

## Parallel access

The store is safe to use from any number of fibers simultaneously. Because all state is owned by the store fiber, and all access goes through the channel, operations are automatically serialised:

```gab
store = Stores.make

fibers = Ranges.make(0, 1000).map (i) => do
  Fibers.make () => do
    key = 'fiber-$'.sprintf(i)
    store.store\set(key, i)
    store.store\get(key)
      .then((val) => '$: $'.sprintf(key, val).println)
  end
end

fibers.each f => f.await

```

The store is the only path to the state. Serialisation is a consequence of the topology, not something enforced by the programmer.

## The full program

Here is a final, full example of our key-value store.

```gab
Stores = store:

make: .def (Stores, () => do
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

t: .def (Stores, Channels.t)

[Stores.t] .defmodule {
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
}

Stores
```
