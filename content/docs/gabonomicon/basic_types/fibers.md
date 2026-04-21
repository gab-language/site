---
title: Fibers & Channels
weight: 7
---

For a conceptual introduction to fibers and channels, see [the Language Tour](/docs/gabonomicon/tour/fibers_and_channels). This page covers the specifics.

## `gab\fiber`

Fibers are created with `Fibers.make:`, which takes a block and immediately queues it for execution. The fiber may run on any OS thread managed by Gab's runtime.

```gab
Fibers.make () => do
  'Hello from a fiber!'.println
end
```
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

In Gab, channels are unbuffered. Practically, this means that Both operations are **blocking**: a send blocks until a receiver is ready, and a receive blocks until a sender is ready.
For this reason, channels serve as both a primitive for sharing data, and way to *synchronize* fibers.

>[!NOTE]
>For a comprehensive example of synchronizing fibers with channels, see the [pub/sub broker example](/docs/gabonomicon/examples/pubsub).

## Buffered channels

While synchronization is useful, it can sometimes be a bottleneck for performance. If producers outpace consumers, then channels may become backed-up as producers
have to block and wait for consumers.

In this scenario it is better to use a *buffered* channel, which can hold up to a certain number of values before producers have to begin blocking.

Lets build this with the primitives Gab gives us!

```gab
buffered: .def (Channels, (n) => do
  input  = Channels.make
  output = Channels.make

  Ranges.make(0 n).each () => do
    # Spawn n fibers to perform buffering.
    Fibers.make () => do
        # Take out of input channel, and forward it to the output channel.
        output <! (input >!)
        # Loop by calling self
        self.()
    end
  end

  (input, output)
end)
```

```gab
(input, output) = Channels.buffered(10)
```

The sender writes to `input` and can race N values ahead before blocking. The consumer reads from `output`. The N slot fibers sit between them, each capable of holding one value in flight.

## Note: operator precedence

`<!` and `>!` are operator sends. The `.` prefix is optional but changes the precedence. Named sends (`.name`) bind tighter than bare operators.

```gab
ch <! value       # operator form
ch.>! .println    # dot prefix — binds tighter, result chains into .println
```
