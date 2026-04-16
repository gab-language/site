---
date: '2025-03-10T07:07:42-04:00'
draft: false
---
# The *Gabonomicon* {{< icon "book-open">}}

Welcome to Gab's playfully-nicknamed documentation. This book should serve as your arcane guide to understanding Gab and its inner-workings.
It targets readers new to **Gab**, with some prior experience writing code.

For more of a technical and in-depth exploration of `cgab` itself the official Gab compiler and runtime,
check out the blog.

{{< callout type="warning" >}}
While the language is relatively stable, Gab's runtime and libraries are still under construction.
Expect bugs and the occasional api change as things settle down. I wouldn't consider Gab production-ready just yet.
Additionally, documentation and developer tooling are works-in-progress. The language may be hard to use until these become more
mature.
{{< /callout >}}

## Your First Gab Program

Welcome! Let's write and run your first Gab program. This short tutorial will show you how to use the Gab runtime, REPL,
and some of the language’s most important ideas: message sends, immutability, fibers, and channels.

### 1. Creating Your First File

Create a new file named `hello.gab`:

```gab
# hello.gab
"Hello, world!" .println
# => Hello, world!
````

To run this program, use:

```bash
gab run hello
```

The `.run` command automatically searches for a file named `hello.gab` in the current directory and runs it.
You’ll see the output printed directly to your terminal.

---

## 2. Using the REPL

You can also experiment interactively using Gab’s REPL:

```bash
gab repl
```

Inside the REPL, try typing the same code:

```gab
"Hello, world!" .println
# => Hello, world!
```

Gab evaluates eagerly, so every message send executes immediately.

---

## 3. Messages Everywhere

Gab doesn’t have statements or operators — everything is a **message send**. That means you can do arithmetic like this:

```gab
1.+ 2
# => 3

4.* 5
# => 20
```

Even control flow uses messages. You’ll learn more about `defcase`, `then:`, and `else:` later — but here’s a sneak peek:

```gab
true: .then () => do
  "It’s true!" .println
end
# => It’s true!
```

---

## 4. Imports and Modules

To use code from another file, send the `use:` message to a string literal:

```gab
"math".use
```

Gab searches known locations (such as `./mod/`) for a matching file named `math.gab`, loads it, and executes it.
This makes sharing code between files simple and explicit.

---

## 5. Immutability by Default

Gab values are immutable. Reassigning creates new data instead of mutating existing state:

```gab
x = [1 2 3]
y = x.append(4)

x.println # => [1, 2, 3]
y.println # => [1, 2, 3, 4]
```

Lists and records use **structural sharing**, so updates are efficient — even though data never changes in place.

---

## 6. Fibers: Lightweight Concurrency

Fibers are Gab’s lightweight, isolated threads of execution. You can spawn one with `Fibers.make`:

```gab
Fibers.make () => do
  "Running in a fiber!" .println
end
```

Fibers run cooperatively. That means long-running computations should occasionally yield control (for example, through I/O or channel operations).

---

## 7. Channels: Communicating Between Fibers

Channels let fibers safely exchange data. Create one with `Channels.make`, then use the send (`<!`) and receive (`>!`) messages:

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
Closing a channel with `ch.close` simply prevents further sends.

---

## 8. Putting It All Together

Let’s combine what you’ve learned into a simple producer-consumer example:

```gab
ch = Channels.make

producer = Fibers.make () => do
  Ranges.make(1 5).each (i) => do
    ch <! (num: i)
  end

  ch.close
end

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

[producer, consumer].each await:
```

This example spawns two fibers:

* The **producer** sends numbers 1–5 through the channel.
* The **consumer** receives and prints them.

Because Gab’s fibers and I/O are non-blocking, both can run efficiently in parallel without OS threads.

---

That’s it — you’ve written your first Gab program, used the REPL, spawned fibers, and passed messages through channels.
You’re now ready to learn **how Gab thinks**.
