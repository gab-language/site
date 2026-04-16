---
title: Fibers & Channels
weight: 7
---

For a conceptual introduction to fibers and channels, see [the Language Tour](/docs/tour/fibers-and-channels). This page covers the specifics.

## `gab\fiber`

Fibers are created with `Fibers.make:`, which takes a block and immediately queues it for execution. The fiber may run on any OS thread managed by Gab's runtime.

```gab
Fibers.make () => do
  'Hello from a fiber!'.println
end
```

Because all Gab values are immutable, a block passed to a fiber can safely capture any variables from its enclosing scope — no copying or synchronisation is required.

The only way for two fibers to exchange values at runtime is through a channel.

## `gab\channel`

Channels are created with `Channels.make`:

```gab
ch = Channels.make
```

**Send** a value with `<!`:

```gab
ch <! 'hello'
```

**Receive** a value with `>!`:

```gab
value = ch >!
```

Both operations are **blocking**: a send blocks until a receiver is ready, and a receive blocks until a sender is ready. A fiber waiting on a channel yields the CPU to other fibers rather than spinning, and retries when scheduled again.

Channels are unbuffered — there is no internal queue. Every send and receive are a direct handoff. This keeps communication explicit and eliminates an entire class of race conditions.

> Even `<!` must block until a receiver arrives. Because `gab\channel` is immutable, it cannot hold a reference to a queued value — every value must be handed directly from sender to receiver.

## Buffered Channels

Gab's channels are unbuffered — every send blocks until a receiver is ready. `Channels.buffered` provides N-slot buffering by spawning N slot fibers that each hold one value in transit between an input and output channel:

```gab
buffered: .def (Channels, (n) => do
  input  = Channels.make
  output = Channels.make

  Ranges.make(0, n).each () => do
    Fibers.make () => do
      input.each (val) => output <! val
    end
  end

  (input, output)
end)
```

```gab
(input, output) = Channels.buffered(10)
```

The sender writes to `input` and can race N values ahead before blocking. The consumer reads from `output`. The N slot fibers sit between them, each capable of holding one value in flight.

A relay chain — one fiber forwarding to the next — does not work: when fiber 1 blocks on its forward, fiber 0 also blocks, jamming the chain after a single value. Independent slot fibers sharing two channels are what produces genuine N-slot buffering.

## `each:`

`each:` reads values from a channel in a loop, calling a block for each one:

```gab
ch.each (msg) => msg.println
```

`each:` blocks until the channel is closed.

## Operator Precedence Note

`<!` and `>!` are operator sends. The `.` prefix is optional but changes precedence — named sends (`.name`) bind tighter than bare operators:

```gab
ch <! value       # operator form
ch.>! .println    # dot prefix — binds tighter, result chains into .println
```
