---
title:
---

> [intransitive verb] — to talk in a rapid or thoughtless manner

# Programming systems, not systems programming

**Gab** is a small, dynamic language built for writing concurrent systems.
Gab gives you the minimal set of abstractions that actually matter, and gets out of your way.

{{< cards >}}
  {{< card link="docs/intro" title="Install Gab" icon="download" >}}
  {{< card link="docs/tour" title="Gabonomicon" icon="book-open" >}}
{{< /cards >}}


## Simple

Gab has one mechanism for control flow: sending messages. No `if`. No `for`. No `while`. No special forms to memorise.

```gab
welcome = ['Hello', ' ', 'world!']
welcome.join.println
# => Hello world!
```

This isn't a constraint to work around, it's a feature of the language. When everything is a message send, there's nothing hidden in the language. Behaviour you don't understand is behaviour you haven't read yet.

## Concurrent.

Gab's runtime supports hundreds of thousands of concurrent fibers. Fibers are lightweight and far cheaper than OS threads. They communicate between each other exclusively through channels.

```gab
print_chan = Channels.make

Ranges.make(0, 10000).each i => do
  Fibers.make () => do
    print_chan <! 'Hello from fiber $!'.sprintf(i)
  end
end

print_chan.each (msg) => msg.println
```

Because all values in Gab are immutable, passing data between fibers requires **no copying**. A large record sent across a channel costs the same as sending an integer.

## Immutable.

Every value in Gab is immutable. You never update a value in place, you produce a new one.

```gab
bob   = { name: 'bob',   age: 44 }
alice = bob.put(name: 'alice')

bob    # => { name: 'bob',   age: 44 }
alice  # => { name: 'alice', age: 44 }
```

For concurrent code, immutability isn't a trade-off — it's the only sensible default. Share anything, anywhere, safely.

## Ship anywhere.

Build a standalone executable for any supported platform — from any other:

```sh
gab build -p aarch64-macos-none -m my,deps my_project
# => my_project  (runs on Apple Silicon, no Gab installation required)

gab build -p x86_64-linux-gnu -m my,deps my_project
# => my_project  (runs on Linux x86_64, no Gab installation required)
```

The output is a single file containing your code, your dependencies, and the entire Gab runtime. Send it to a server, bundle it in a container, hand it to a colleague — it just runs.

## Embeddable.

Gab is designed to live inside larger applications. A stable C API (`gab.h`) and a static library (`libcgab.a`) are provided with every release. Call Gab from C, expose C functions to Gab, or write native modules.

If Lua is your current scripting layer, Gab is a direct, concurrent-ready alternative.

{{< cards >}}
  {{< card link="docs/intro" title="Install Gab" icon="download" >}}
  {{< card link="https://github.com/gab-language/cgab" title="View on GitHub" icon="github" >}}
{{< /cards >}}
