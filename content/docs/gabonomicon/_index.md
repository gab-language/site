---
date: '2025-03-10T07:07:42-04:00'
draft: false
---

#

## The *Gabonomicon*

Welcome to gab's playfully-nicknamed documentation. This book should serve as your arcane guide to understanding gab and its inner-workings.
It targets readers new to **gab**, with some prior experience writing code.

For more of a technical and in-depth exploration of `cgab` itself the official gab compiler and runtime,
check out the blog.

{{< callout type="warning" >}}
While the language is relatively stable, gab's runtime and libraries are still under construction.
Expect bugs and the occasional api change as things settle down. Additionally, documentation and developer tooling are works-in-progress.
{{< /callout >}}

### Installation

If you haven't installed gab yet, take a look at the [installation](/docs/installation) page first. Once you're up and running, pick it back up here.

## Your First Project

Woohoo! gab is now installed on your system. You can now begin writing your first gab programs!

### Creating a package

First, you need to create what gab calls a 'package'. This is just a folder in your project! Let's call it `hello`, and add a special file `mod.gab`.

{{< filetree/container >}}
  {{< filetree/folder name="hello" >}}
    {{< filetree/file name="mod.gab" >}}
  {{< /filetree/folder >}}
{{< /filetree/container >}}

Let's add some content to `mod.gab`:

```gab
'Hello, world!'.println
```

And you run it with:

```sh
gab run hello

# Hello, world!
```

### Using the REPL

Running packages from the command line is useful, but not the best way to develop iteratively. gab's REPL can be an improvement!

Try it with:

```bash
gab repl
```

Inside the REPL, try typing the same code:

```bash
gab repl
  ________   ___  |
 / ___/ _ | / _ ) |   v: <version>
/ (_ / __ |/ _  | |  on: x86_64-linux-gnu
\___/_/ |_/____/  |  in: release

>>> 'Hello, world!'.println
Hello, world!
ok:
```

Use this to tweak and iterate.

>[!NOTE]
>Editor tooling for gab is a WIP. There are plans to build both an LSP and an nREPL server for integrating with multiple clients.

## Building a Standalone Executable

When you're ready to ship, `gab build` compiles your project into a single, self-contained executable — including the entire gab runtime. You can even cross-compile for other platforms from your current machine:

```sh
# Build for arm macOS
gab build -t aarch64-macos-none -m my,deps my_project

# Build for Linux x86_64, from any supported platform
gab build -t x86_64-linux-gnu -m my,deps my_project
```

The resulting binary can be sent to any machine of the target platform and run directly, without installing anything on the host.

For a quick bit of fun, let's compile your `hello` package to an executable. Simply run:
```bash
gab build -m github.com/gab-language/cgab@<version> hello
```

This produces a file `hello.cgab-<version>-<target>.exe`. gab chooses this name because it is cross-platform, and including the cgab version and compilation target is a hygenic practice.
The only mandatory element in the name is that it begins with `hello` - this is how the executable determines which module to use as the *entrypoint* of the application.

That being said, this is an executable you can just run!
```bash
./hello.cgab-<version>-<target>.exe
# Hello, world!
```

>[!NOTE]
>The `-m` flag adds a dependency to include in the final executable. gab doesn't make any assumptions when compiling binaries - you must define everything you want to include.

Congratulations! You've run some gab code and made your own first package - even compiled a binary for distributing.

Continue in the Gabonomicon to learn more deeply about the language.
