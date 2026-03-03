+++
title = "Introduction"
type = "chapter"
weight = 1
+++
Welcome!
This guide will teach you about Gab's fundamentals.
We will discuss the basic types and ideas of the language.
First, lets install the language itself.
## Installing the language
#### 1. Downloading binaries from releases
Pre-built binaries are available for every release on the [GitHub releases page](https://github.com/gab-language/cgab/releases). Download the archive that matches your platform:

| Platform | Architecture | File |
|---|---|---|
| macOS | Apple Silicon (M1/M2/M3) | [gab-aarch64-macos](https://github.com/gab-language/cgab/releases/latest/download/gab-release-aarch64-macos-none) |
| macOS | Intel | [gab-x86_64-macos](https://github.com/gab-language/cgab/releases/latest/download/gab-release-x86_64-macos-none) |
| Linux | x86_64 | [gab-x86_64-linux](https://github.com/gab-language/cgab/releases/latest/download/gab-release-x86_64-macos-none) |
| Linux | ARM64 | [gab-aarch64-linux](https://github.com/gab-language/cgab/releases/latest/download/gab-release-aarch64-linux-gnu) |

> Windows support is planned for a future release.

> [!NOTE]
> The executable you just downloaded (`gab`) won't be in your path. You'll need to invoke it directly. You may also need to mark it as executable.
> Later, Gab will recommend how to update your PATH as part of installation. Ultimately, this is up to you!
#### 2. Install via binary
**All** that is needed to complete the installation is this downloaded binary!
From this point forward lets refer to your downloaded binary as simply `gab`, just to make things easier.
Now, you should be able to run Gab.
```bash
# Try this:
gab

# Or this:
gab help
```
You should see a generic help message, summarazing the commands available to you.
However, at this point trying to run any real code will fail - Gab's core modules still need to be installed.
Lets go ahead and complete your installation by downloading the core modules
that Gab requires.
```bash
# Gab makes this easy:
gab get
```
This command downloads the gab binary and built-in modules (like `IO`, `Fibers`, `Channels`, `Strings`, `Ranges`, and more) to Gab's installation prefix on your machine. You should see some logs detailing this process.
Lastly, complete your installation as instructed by the message in your terminal.

> [!NOTE]
> `gab` calls out to the operating system for `curl` in order to perform this installation. It should be widely available by default on most machines,
> including any Windows machine with Windows 10 or later. However, you may see an error message indicating that one of the two is unavailable - in that case installation will fail.

## Your First Program

Create a file called `hello.gab`:

```gab
'Hello, world!'.println
```

Run it:

```sh
gab run hello.gab
```

That's it. No boilerplate, no imports, no entry-point ceremony.

---

## The REPL

Gab ships with an interactive REPL for exploring the language. Start it with:

```sh
gab repl
```

You'll get a prompt where you can type expressions and see their results immediately. This is a great way to experiment with messages, records, and shapes before committing them to a file.

---

## Building a Standalone Executable

When you're ready to ship, `gab build` compiles your project into a single, self-contained executable — including the entire Gab runtime. You can even cross-compile for other platforms from your current machine:

```sh
# Build for Apple Silicon macOS
gab build -p aarch64-macos-none -m my,deps my_project

# Build for Linux x86_64, from any supported platform
gab build -p x86_64-linux-gnu -m my,deps my_project
```

The resulting binary can be sent to any machine of the target platform and run directly — no Gab installation required on the target.

---

## Embedding Gab

Gab is designed to be embedded in larger C applications. When you install Gab, you also get:

- `gab.h` — the complete C API, documented in a single header file
- `libcgab.a` — a static library to link against

To embed Gab, include `gab.h` and link with `libcgab.a`. The C API gives you full control: you can evaluate Gab source, call Gab functions from C, and expose C functions to Gab code.

To write a **native module** (a C library that Gab code can `use`), you only need `gab.h` — no linking required, since the Gab runtime that loads your module already carries the necessary symbols.

You can generate full API documentation from the header with:
## Windows
Unforunately, windows is not supported at the moment. There is currently a [bug](https://github.com/ziglang/zig/issues/18799) in `zig cc` causing miscompilations on Windows which break the **c abi**. The features of c which cause this bug to appear
are used heavily in cgab. Until this bug is fixed in `zig`, Gab will not support windows. 

## Compiling From Source
cgab is a C project built with Zig's c-compiler toolchain. `zig cc` is chosen specifically for its cross-compiling superpowers. This enables
linux developers to cross-compile for Windows and run via `wine`, among other amazing things. As a result, a limitation placed on `cgab` is that there
shall be **no runtime dependencies other than libc**. This constraint is what makes the cross compilation possible. This goes for any c modules as well - there
may be *NO* runtime dependencies. Any 3rd party code necessary for c modules shall be kept in git-submodules, and if it must be linked, then linked statically.

#### Unix Systems
To manage the various useful scripts in the repo, cgab takes advantage of [clide](https://github.com/TeddyRandby/clide).
After installing `clide`, building cgab from source is as simple as running:
```bash
    clide build
```
Clide will prompt you to select a build type and installation target. For details on how to use clide, check its readme.

#### Manual Build
Alternatively, `zig cc` can be invoked manually. Check `.clide/../build.sh` for an example of how to invoke `zig cc`, and build the appropriate artifacts.

> [!NOTE]
> The additional flags `-DGAB_PLATFORM_UNIX` and `-D_POSIX_C_SOURCE=200809L` are required for unix builds.
> Clide relies on bash scripts written in the `.clide/` directory, and therefore will not work on windows.
> On Windows, `zig cc` should be invoked manually. The following is an example, but will not fully build cgab.
```bash
    zig cc -Os -std=c23 -fPIC -Wall --target=native -o gab -Iinclude -Ivendor -DNDEBUG -DGAB_PLATFORM_WIN src/**/*.c
```
