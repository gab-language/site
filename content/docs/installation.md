+++
title = "Installation"
type = "chapter"
weight = 1
+++
This guide covers installing the gab language. This includes development files, as well as the binaries and builtin package.

## Choose your release

Pre-built binaries are available for every release on the [GitHub releases page](https://github.com/gab-language/cgab/releases). Links are provided below for your convenience.
Download the archive that matches your platform:

| Platform | Architecture | File |
|---|---|---|
| macOS | Apple Silicon (M1/M2/M3) | [gab-aarch64-macos](https://github.com/gab-language/cgab/releases/latest/download/gab-release-aarch64-macos-none) |
| macOS | Intel | [gab-x86_64-macos](https://github.com/gab-language/cgab/releases/latest/download/gab-release-x86_64-macos-none) |
| Linux | x86_64 | [gab-x86_64-linux](https://github.com/gab-language/cgab/releases/latest/download/gab-release-x86_64-linux-gnu) |
| Linux | ARM64 | [gab-aarch64-linux](https://github.com/gab-language/cgab/releases/latest/download/gab-release-aarch64-linux-gnu) |

> Windows support is planned for a future release.

> [!WARNING]
> The executable you just downloaded (`gab-release-<your_target>`) won't be in your path, so you'll need to invoke it directly. On some platforms you may need to mark it as executable, with `chmod +x <gab-release-your_target>`.
> Later, Gab will recommend how to update your PATH as part of installation. Ultimately, this is up to you!

## Install

### Test the downloaded binary

From this point forward lets refer to your downloaded binary as simply `gab`, just to make things easier.
Now, you should be able to run Gab.
```bash
# Try this:
gab

# Or this:
gab help
```
You should see a generic help message, summarazing the commands available to you.
However, at this point trying to run any real code will fail - Gab's core modules still need to be installed. Lets verify this with `gab info`.

### Check your Gab installations

```bash
gab info

# At the end of the output, you should see something like:
<version> TARGETS
        x64 linux | not installed
        x64 macos | not installed
      x64 windows | not installed
        arm linux | not installed
        arm macos | not installed
      arm windows | not installed
```
Aha! No installations were found. Lets go ahead and complete your installation by downloading the core modules
that Gab requires.

### Download Gab's development files and builtin package

```bash
# Gab makes this easy:
gab get
```
This command downloads the gab binary, development files (for embedding Gab in other programs), and the builtin `gab-language/cgab` package.

### Complete the installation

Lastly, complete your installation as instructed by the message in your terminal.

> [!NOTE]
> `gab` calls out to the operating system for `curl` and `tar` in order to perform this installation. They should be widely available by default on most machines,
> including any Windows machine with Windows 10 or later. However, you may see an error message indicating that one of the two is unavailable - in that case installation will fail.

Running `gab info` again should show that you've installed the appropriate target. You *can* install the same development files and package for any platform that you like - this is actually how Gab supports cross compilation!

And thats it - Gab is now installed and ready to go on your system. If you're new to Gab, start with the [gabonomicon](/docs/gabonomicon). Get hacking!

## Embedding Gab

Gab is designed to be embedded in larger C applications. When you install Gab, you also get:

- `gab.h` — the complete C API, documented in a single header file
- `libcgab.a` — a static library to link against

To embed Gab, include `gab.h` and link with `libcgab.a`. The C API gives you full control: you can evaluate Gab source, call Gab functions from C, and expose C functions to Gab code.

To write a **native module** (a C library that Gab code can `use`), you only need `gab.h` — no linking required, since the Gab runtime that loads your module already carries the necessary symbols.

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
