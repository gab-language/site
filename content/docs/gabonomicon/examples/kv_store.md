---
title: "Key-Value Store"
weight: 1
---

This example builds a concurrent in-memory key-value store. It is a complete, useful program and demonstrates how Gab's core features compose in practice.

By the end you'll have a store that can be safely read and written from any number of concurrent fibers.

## The Design

The store is a single fiber. It owns a record which it privately threads through recursive calls. No other fiber can touch that record directly.

The store's public face is a **channel**. Callers send command tuples into it; the store fiber reads them, processes each one, and sends the result back on a reply channel included in the command. The command name comes first in the tuple so it can be forwarded directly as the receiver of `handle:`.

```
caller fiber                   store fiber
    |                               |
    |-- (store\set: reply k v) ---------> ch
    |                               |-- state = state.put(k, v)
    |                               |-- reply <! ok:
    | <----------- ok: ------------ |
```

Because all state lives inside one fiber, concurrent callers are automatically serialised. The design makes races structurally impossible. There is nowhere for two fibers to conflict.

## The Store Actor

`make:` creates a channel, spawns the store fiber, and returns the channel directly. The store **is** the channel. Callers hold a channel value and send commands into it.

```gab
Store = store:

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

## The Public API

The module is defined on the channel type directly, since the store is a channel:

```gab
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
}
```

`t:` returns `Channels.t` — the store type is the channel type. `defmodule` attaches messages directly to that type, so `self` inside each method is the channel itself. Each method creates a reply channel, sends the command, and blocks on `reply >! .unwrap` until the store responds.

## Putting it Together

Here is an example of how we'd expect to use this api:

```gab
store = Store.make

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

## Concurrent Access

The store is safe to use from any number of fibers simultaneously. Because all state is owned by the store fiber, and all access goes through the channel, operations are automatically serialised:

```gab
store = Store.make

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

## The Full Program

Here is a final, full example of our key-value store.

```gab
Store = store:

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
}

Store
```

---

## What to Notice

**The store is a channel.** `make:` returns `ch` directly — there is no wrapper record. This means the store participates in the channel type system naturally. Any message defined on channels is available on the store, and the store can be passed anywhere a channel is expected.

**State is never stored in a variable.** It exists only as an argument threaded through recursive calls. There is no mutable global, no shared reference — just a value flowing forward through each iteration of the loop.

**Tuple forwarding eliminates dispatch boilerplate.** Placing the command name first in every tuple means `(cmd, reply, state, args*) .handle` routes itself. No `if`/`switch`, no explicit pattern match on the command. The structure of the data is the dispatch.

**The store is open for extension.** `handle:` is a message like any other — new command types can be added by defining new specializations anywhere, without touching the store's core loop. A `keys:` command that returns all keys, a `flush:` command that clears the store — all are one `defcase` entry away.

**If the store fiber crashes, state is lost.** The store holds no persistent state. This is appropriate for an in-memory cache, but worth knowing if you build on this pattern for something that needs durability.

**Error handling is consistent.** Every operation returns `(ok:, ...)` or `(none:, ...)`, following the same conventions as the rest of Gab's standard library. Callers chain `.then` and `.else` without any special syntax.
