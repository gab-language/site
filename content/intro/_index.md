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
### Downloading binaries from releases
CGab provides pre-built cross-platform binaries upon [releases](https://github.com/gab-language/cgab/releases).
They are available in both debug and release flavors. If any weird behavior or segmantation faults occur, please recreate with the debug build before filing an issue.

### Installation
ALl that is needed to complete the installation is this downloaded binary!
The binary freshly downloaded from **Github** won't be marked as executable. On Unix systems, we'll need to fix that:
```bash
chmod +x <your_downloaded_binary>
```
From this point forward lets refer to your downloaded binary as simply `gab`, just to make things easier.
Now, you should be able to run Gab. Try:
```bash
./gab
```
You should see a generic help message, summarazing the commands available to you. Lets go ahead and complete your installation by downloading the core modules
that Gab requires. This is easy to do with:
```bash
./gab get
```
This command downloads the gab binary and modules to Gab's installation prefix on your machine. You should see some logs detailing this process.
Lastly, complete your installation as instructed by the message in your terminal.

**Note:** `gab` calls out to the operating system for `curl` and `tar` in order to perform this installation. They should be widely available by default on most machines,
including any Windows machine with Windows 10 or later. However, you may see an error message indicating that one of the two is unavailable - in that case installation will fail.

#### Windows
Unforunately, windows is not supported at the moment. There is currently a [bug](https://github.com/ziglang/zig/issues/18799) in `zig cc` causing miscompilations on Windows which break the **c abi**. The features of c which cause this bug to appear
are used heavily in cgab. Until this bug is fixed in `zig`, Gab will not support windows. 

### Compiling From Source
CGab is a c project built with Zig's c-compiler toolchain.
#### Unix Systems
To manage the various useful scripts in the repo, cgab takes advantage of [clide](https://github.com/TeddyRandby/clide).
After installing `clide`, building cgab from source is as simple as running:

    clide build

Alternatively, `zig cc` can be invoked manually as below for Windows.
**Note:** The additional flags `-DGAB_PLATFORM_UNIX` and `-D_POSIX_C_SOURCE=200809L` are required for unix builds.

#### Windows Systems
Clide relies on bash scripts written in the `.clide/` directory, and therefore will not work on windows.
On Windows, `zig cc` should be invoked manually.

    zig cc -O3 -std=c23 -fPIC -Wall --target=native -o gab -Iinclude -Ivendor -DNDEBUG -DGAB_PLATFORM_WIN src/**/*.c
