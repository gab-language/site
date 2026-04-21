---
title: Develop and Distribute with Gab
---

**Gab** is a small, dynamic language designed for building highly parallel, interactive systems.
With gab, you'll build composable, resilient programs almost by accident.

{{< cards >}}
  {{< card link="docs/intro" title="Install Gab" icon="download" >}}
  {{< card link="docs/tour" title="Gabonomicon" icon="book-open" >}}
{{< /cards >}}


## Simple

Gab's syntax is minimal - learn the whole language in an afternoon.

```gab
welcome = ['Hello', ' ', 'world!']
welcome.join.println
# => Hello world!
```

## Parallel

Gab's runtime is built on units of execution fibers. Fibers are lightweight and far cheaper than OS threads - make as many as you like. Gab will schedule them across all your cores, and run them in parallel.

```gab
print_chan = Channels.make

Ranges.make(0, 10000).each i => do
  Fibers.make () => do
    print_chan <! 'Hello from fiber $!'.sprintf(i)
  end
end

print_chan.each (msg) => msg.println
```

## Immutable

Every value in Gab is immutable. This makes thinking in parallel easier than ever.

```gab
bob   = { name: 'bob',   age: 44 }
alice = bob.put(name: 'alice')

bob    # => { name: 'bob',   age: 44 }
alice  # => { name: 'alice', age: 44 }
```

## Embeddable

Gab is designed to live inside larger applications. A stable C API (`gab.h`) and a static library (`libcgab.a`) are provided with every release. Call into Gab from C, or write native modules.

If you're looking for a scripting layer in your application, Gab is a fantastic option.

## Ship anywhere

Build a standalone executable for any supported platform — from any other:

```sh
gab build -t aarch64-macos-none -m my,deps my_project
# => my_project  (runs on Apple Silicon, no Gab installation required)

gab build -t x86_64-linux-gnu -m my,deps my_project
# => my_project  (runs on Linux x86_64, no Gab installation required)
```

The output is a single file containing your code, your dependencies, and the entire Gab runtime. Send it to a server, bundle it in a container, hand it to a colleague or user — it just works.
