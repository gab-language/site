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
cgab provides pre-built cross-platform binaries upon [releases](https://github.com/gab-language/cgab/releases).
They are available in both debug and release flavors. Select a pre-built binary that matches your system. If you don't see one,
feel free to create a Github Issue or build cgab yourself.
> [!NOTE]
> The executable you just downloaded (`gab`) won't be in your path. You'll need to invoke it directly.
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
This command downloads the gab binary and modules to Gab's installation prefix on your machine. You should see some logs detailing this process.
Lastly, complete your installation as instructed by the message in your terminal.

> [!NOTE]
> `gab` calls out to the operating system for `curl` and `tar` in order to perform this installation. They should be widely available by default on most machines,
> including any Windows machine with Windows 10 or later. However, you may see an error message indicating that one of the two is unavailable - in that case installation will fail.

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
    zig cc -O3 -std=c23 -fPIC -Wall --target=native -o gab -Iinclude -Ivendor -DNDEBUG -DGAB_PLATFORM_WIN src/**/*.c
```
