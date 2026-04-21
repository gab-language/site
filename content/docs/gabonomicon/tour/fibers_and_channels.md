---
title: Fibers & Channels
weight: 4
---

Parallelism is not an add-on in Gab. It is a first-class feature of the language and runtime. Two foundational primitives are provided: **fibers** and **channels**.

## Fibers

A fiber is a lightweight unit of execution, similar to a goroutine in Go or a process on the BEAM (Erlang/Elixir). Fibers are cheap: Gab's runtime is designed to support hundreds of thousands of them running concurrently.

You spawn a fiber by passing a block to `Fibers.make`:

```gab
Fibers.make () => do
  'Hello from a fiber!'.println
end
```

The block runs concurrently. The fiber is scheduled by Gab's runtime — you don't manage threads or thread pools.

Here's a more complete example that spawns 20,000 fibers:

```gab
spawn_task = (i) => do
  Fibers.make () => do
    'Hello from fiber $!'.sprintf(i).println
  end
end

Ranges.make(0, 20000).each spawn_task
```

## Channels

Fibers communicate with each other through **channels**. A channel is the *only* way for two fibers to exchange data, or synchronize.

Create a channel with `Channels.make`:

```gab
ch = Channels.make
```

**Send** a value into a channel with the `<!` operator:

```gab
ch <! 'a message'
```

**Receive** a value from a channel with the `>!` operator:

```gab
value = ch >!
```

Gab's channels are **unbuffered**: a send blocks until a receiver is ready, and a receive blocks until a sender is ready.
This keeps communication explicit and synchronised.

>[!NOTE]
>Channels actually accept *tuples* instead of just single values. You can send as many values as you want, and they will be transferred as a group.

## Putting it together

Here is a pipeline where many fibers produce values, and a single consumer reads them all:

```gab
print_chan = Channels.make

Ranges.make(0, 10000).each i => do
  Fibers.make () => do
    print_chan <! 'Hello from fiber $!'.sprintf(i)
  end
end

print_chan.each (msg) => msg.println
```

Each fiber sends one message into the channel, then exits. The `each` message reads values from the channel and passes each one to the block.

## Zero-copy message passing

A common cost in concurrent systems is **copying**: when you send data to another thread, the runtime must copy it to keep both sides safe. Gab eliminates this cost.

Because all of Gab's data structures are immutable, a value cannot change after it is created. This means it is always safe to share a reference to a value across fiber boundaries — no copying is needed. In practice, passing a large record between 10,000 fibers is no more expensive than passing an integer.

This is a deliberate design choice that makes Gab's concurrency both safe and fast.

## Channels are immutable too

Even `gab\channel` is immutable. A channel reference can be passed freely between fibers without any synchronisation overhead. The runtime handles the scheduling of sends and receives internally.

## Atoms: safe shared state

Channels and fibers are sufficient to implement any concurrency abstraction you might need.
Here is a sample implementation of an **atom**. Think of this as a value that can be read and updated safely from any fiber, similar to Clojure's `atom`.

The design: a dedicated fiber holds the current state privately in its own local scope.
Other fibers send commands to it over a channel, where each command is a tuple of a reply channel and a function to apply.
The atom fiber applies the function, sends the new state back on the reply channel, and recurses with the updated state.
Because all reads and writes go through a single fiber, no two updates can race.

```gab
Atom = gab\atom:

make: .def (Atom, (initial) => do
  ch = Channels.make

  loop = (state) => do
    (reply, f) = ch >!
    new_state   = f.(state)
    reply <! new_state
    self.(new_state)
  end

  Fibers.make () => loop.(initial)

  { chan: ch }
end)

t: .def (Atom, () => { chan: nil: }?)

[Atom.t] .defmodule {
  deref: () => do
    reply = Channels.make
    self.chan <! (reply, (x) => x)
    reply >!
  end

  swap: (f) => do
    reply = Channels.make
    self.chan <! (reply, f)
    reply >!
  end

  reset: (val) => self.swap(() => val)
}
```

Usage:

```gab
counter = Atom.make(0)

counter.deref         # => 0

counter.swap((n) => n + 1)
counter.swap((n) => n + 1)

counter.deref         # => 2

counter.reset(100)
counter.deref         # => 100
```

A few things worth noting in the implementation:

**Recursive blocks via `self`.** `loop` calls `self.(new_state)` to recurse. When a block is invoked directly rather than as a message specialization, `self` refers to the block itself — making this a clean tail-recursive loop with no stack growth.

**Tuples over channels.** `ch <! (reply, f)` sends both the reply channel and the function as a single tuple. The atom fiber receives and destructures them in one step with `(reply, f) = ch >!`.

**`t:` provides the shape for `defmodule`.** `Atom.t` returns the shape of atom records — `<gab\shape chan:>` — so that `defmodule` has a concrete type to attach messages to. `self.chan` inside the module accesses the channel field via property dispatch.

**`deref` is just `swap` with the identity function.** There's no separate read mechanism — the same serialised path handles both reads and writes, which guarantees that a `deref` sees all preceding `swap!` calls.
