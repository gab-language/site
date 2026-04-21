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

# Installation

If you haven't installed Gab yet, take a look at the [installation](/docs/installation) page first. Once you're up and running, pick it back up here.

---

# Your First Project

Woohoo! Gab is now installed on your system. We can now begin writing our first Gab programs!

## Creating a package

First, we need to create what Gab calls a 'package'. This is just a folder in your project! Lets call it `hello`, and add a special file `mod.gab`.

{{< filetree/container >}}
  {{< filetree/folder name="hello" >}}
    {{< filetree/file name="mod.gab" >}}
  {{< /filetree/folder >}}
{{< /filetree/container >}}

Lets add some content to `mod.gab`:

```gab {filename="mod.gab"}
'github.com/gab-language/cgab@0.0.5' .use 'Io'

'Hello, world!'.println
```

And we run it with:

```sh
gab run hello

# Hello, world!
```

## Using the REPL

Running packages from the command line is useful, but not the best way to develop iteratively. Gab's REPL can be an improvement!

Try it with:

```bash
gab repl
```

Inside the REPL, try typing the same code:

```bash
gab repl
  ________   ___  |
 / ___/ _ | / _ ) | v0.0.5
/ (_ / __ |/ _  | |  on: x86_64-linux-gnu
\___/_/ |_/____/  |  in: release

>>> 'github.com/gab-language/cgab@0.0.5'.use 'Io'
io:
>>> 'Hello, world!'.println
Hello, world!
ok:
```

Use this to tweak and iterate.

>[!NOTE]
>Editor tooling for Gab is a WIP. We plan to build both an LSP and an nREPL server for integrating with multiple clients.

## Building a Standalone Executable

When you're ready to ship, `gab build` compiles your project into a single, self-contained executable — including the entire Gab runtime. You can even cross-compile for other platforms from your current machine:

```sh
# Build for arm macOS
gab build -t aarch64-macos-none -m my,deps my_project

# Build for Linux x86_64, from any supported platform
gab build -t x86_64-linux-gnu -m my,deps my_project
```

The resulting binary can be sent to any machine of the target platform and run directly, without installing anything on the host.

For a quick bit of fun, lets compile our `hello` package to an executable. Simply run:
```bash
gab build -m github.com/gab-language/cgab@0.0.5 hello
```

This produces a file `hello.cgab-<version>-<target>.exe`. Gab chooses this name because it is cross-platform, and including the cgab version and compilation target is a hygenic practice.
The only mandatory element in the name is that it begins with `hello` - this is how the executable determines which module to use as the *entrypoint* of the application.

That being said, this is an executable you can just run!
```bash
./hello.cgab-<version>-<target>.exe
# Hello, world!
```

>[!NOTE]
>The `-m` flag adds a dependency to include in the final executable. Gab doesn't make any assumptions when compiling binaries - you must define everything you want to include.

---

Congratulations! You've run some Gab code and made your own first package - even compiled a binary for distributing.

Continue in the Gabonomicon to learn more deeply about the language.
