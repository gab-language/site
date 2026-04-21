---
date: '2026-04-20T10:00:44-04:00'
draft: false
title: 'Quirks'
weight: 1
---

Gab is a quirky language. It is probably similar to languages you've used in the past - but no matter where you come from (Python, Ruby, Elixir, Clojure, even Smalltalk),
you should see some similarities and some funny-looking differences. Lets take a glance at some of the things you may find a bit weird.

## Imports and Modules

To run code from another file, send the `use:` message to a string literal:

```gab
"github.com/gab-langue/cgab@0.0.5" .use
```

The string literal receiver here is the *package* name. On the right side of the `.use`, you can optionally include a *module* name. This looks for a specific
module within the given package. This is how we imported the builtin `Io` module earlier!

Gab searches known locations for a matching package folder. If the package is found, Gab searches the package for a matching module, loads it, and executes it.
If no module was specified, Gab searches for the default `mod.gab` module, and executes it.

## Messages

In Gab, the only way to *do* anything is to send a message. This looks like a method call or an operator.

```gab
1 + 2
# => 3

4 .+ 5
# => 20
```

Even control flow uses messages. You’ll learn more about `defcase`, `then:`, and `else:` later. Until then, here is a peek:

```gab
true: .then () => do
  "It’s true!" .println
end
# => It’s true!
```

Messages are also *values* in Gab. The funky syntax you see for `true:` above is actually a *message value*. This is how Gab implements, booleans and nil/null.

## Immutability

Gab values are immutable. To update a list value, send a message like `push:` and begin using the result. In the below example, `push:` returns a *new* list with the number 4 appended to the end.

```gab
x = [1 2 3]
y = x.push(4)

x.println # => [1, 2, 3]
y.println # => [1, 2, 3, 4]
```

Immutability forces programmers to write code which operates on values instead of state. This actually makes programming easier!

## Parallelism

Fibers are Gab’s lightweight, isolated threads of execution. You can spawn one with `Fibers.make`:

```gab
Fibers.make () => do
  "Running in a fiber!" .println
end
```

Fibers run cooperatively, and in parallel. That means long-running computations occasionally yield control to others. For example, at `Io` or `Channel` operations.

## Communication

Speaking of channels, lets talk about how fibers can talk to each other.

Channels let fibers exchange data. Create one with `Channels.make`, then use the send `<!` and receive `>!` messages:

```gab
ch = Channels.make

Fibers.make () => do
  ch <! "ping"
end

msg = ch >!
msg.println
# => ping
```

Channels are **unbuffered** and **rendezvous-based** — both sides must meet for a transfer to occur.

Channels can be closed with `close:` to cancel current operations and prevent future ones.

## Putting It All Together

Let’s combine what we’ve learned into a simple producer-consumer example. This is a common pattern you'll use in Gab programs.

```gab
# Imports excluded for brevity.
ch = Channels.make

# The producer iterates the range 1-5 and puts each number on the channel with a little tag (the num: message)
producer = Fibers.make () => do
  Ranges.make(1 5).each (i) => do
    ch <! (num: i)
  end

  ch.close
end

# The consumer then loops forever (calling itself). On each iteration, it takes from the channel
# checks the status of the take, and then prints the result.
consumer = Fibers.make () => do
  loop = () => do
    (status, kind, value) = ch >!

    status.ok.then () => do
      "Received: $ $".sprintf(kind, value).println
    end

    (status.ok & ch.is\open).then self
  end

  loop.()
end

# Map over a list consisting of the producer and consumer fibers, awaiting each of them.
# This prevents the program from terminating before the fibers are done producing and consuming.
[producer, consumer].each f => f.await
```

That’s it — you’ve written your first Gab program, used the REPL, spawned fibers, and passed messages through channels.
