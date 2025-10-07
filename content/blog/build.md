+++
date = '2025-10-02T14:55:44-04:00'
draft = false
title = 'Build'
+++
## Why it matters
Deploying and distributing apps in dynamic languages can be a pain. How are packages and dependencies managed?
What if the user has a different version of the interpreter? What if we can't expect the user to have the interpreter at all?

Compiled languages get to distrubute a single static binary, runnable on any matching os/arch system. This is vastly more simple and after all -
[just give me an .EXE](https://github.com/twitter/the-algorithm/issues/1999).

What if there was a way that dynamic languages could bundle not just the users code, but *the interpreter itself and all the native modules*? Its possible! And its a feature coming to Gab.

### Prior Art
This feature is inspired by the way the Lua Game Engine [Love2D](https://www.love2d.org/) recommends developers package up their games.
It uses a technique involving **zip archives**.

The neat thing about the zip file format is that the metadata about the files in the archive is stored at the **end** of the file.
In Love2d, the developer creates a distrubutable game by zipping up all their code into a single zip archive, and concatenating it onto the back of the
love binary itself.

Part of the love binaries behavior is that under some condition (I'm not quite sure what) it will check if the binary being executed (ie, itself)
is a valid zip archive. If it is, it **unzips itself into memory**, and executes the game code! When I discovered this was how it worked my mind
was kinda blown. And I immediately though this would be an incredibly useful way to allow users to build distributable Gab binaries of their own.

### The Gab Toolchain
This is the first blog post about a feature of the Gab Toolchain, not the implementation of cgab, or a native module.
The toolchain is a first-class concern to me as a language creator. I want the Gab CLI to be a batteries-included tool
which can do everything a developer might need to write, run, test, download, install, and build Gab code.

This is another step in that direction. Lets dive into the implementation!
### When to unzip?
Under certain conditions, the Gab binary needs to determine that there is a zip archive at the end of itself. Then it needs
to unzip said archive into memory, and allow the Gab runtime to see the archive when looking for modules. That leads us on a little
side tangent:

> How does the Gab runtime find modules?

Here is the snippet of c code in the Gab CLI which initializes the gab engine when you type something like `gab run myapp`.
```c
  union gab_value_pair res = gab_create(
      (struct gab_create_argt){
        // Various flags which determine some minor behaviors within the engine.
          .flags = flags,
        // The number of worker threads the Gab runtime should spawn.
          .jobs = jobs,
        // A list of modules to require upon startup. Think of them as pre-loaded
          .len = nmodules,
          .modules = modules,
        // Roots are starting points where the engine will search for modules.
        // The engine will search each root *with each resource*, and check the roots in reverse order.
          .roots =
              (const char *[]){
                  gab_osprefix(GAB_VERSION_TAG "." GAB_TARGET_TRIPLE), "./",
                  nullptr, // List terminator.
              },
        // Resources describe a prefix (from any of the above roots)
        // and a suffix (a file ending, or maybe more path *and then* a file ending)
        // Each resource provides two callback functions:
        //   One determines if the module *exists* at the given path
        //     Since these resources check against the user's filesystem, that callback just determines if the file exists.
        //   The other *loads* the module at the given path.
        //     There are two implementations for this function, depending on whether or not the file is a Gab source file or a native module.
          .resources =
              (struct gab_resource[]){
                  {"mod/", GAB_DYNLIB_FILEENDING, gab_use_dynlib, file_exister},
                  {"", GAB_DYNLIB_FILEENDING, gab_use_dynlib, file_exister},
                  {"", "/mod.gab", gab_use_source, file_exister},
                  {"mod/", ".gab", gab_use_source, file_exister},
                  {"", ".gab", gab_use_source, file_exister},
                  {}, // List terminator.
              },
      },
      &gab);
```
Hopefully the comments are self explanatory, but the gist is that the user registers paths and callbacks which the Gab engine uses to
search for modules. We will hook into this later!
### When to unzip: for real
How does the Gab executable know when to try and unzip itself? The solution is relatively simple:
```c
// main.c
...
  if (check_not_gab(argv[0])) {
    if (check_valid_zip()) {
      return run_app(argv[0]);
    }
  }
...
```
`check_not_gab` is relatively simple - it just checks if `argv[0]` is exactly `gab`. This is a good-enough fast check for the general case.
`check_valid_zip` does some more work. It uses the library `miniz.c` to try and unzip the binary:
```c
bool check_valid_zip() {
  // Get the file path for the currently-executing binary
  const char *path = gab_osexepath();

  // 'zip' is a top-level variable here.
  mz_zip_zero_struct(&zip);

  assert(&zip);
  assert(path);

  // Initialize the zip-reader to read said file
  if (!mz_zip_reader_init_file(&zip, path, 0)) {
    mz_zip_error e = mz_zip_get_last_error(&zip);
    return false;
  }

  // If the archive unzips to at least one file, return true
  size_t files = mz_zip_reader_get_num_files(&zip);

  return files;
}
```
This snippet is also relatively simple. The `miniz.c` is a fantastic, single-file library with an intuitive api.
If we get to `run_app`, that means we have successfully unzipped the executing binary as a zip-archive into memory, and saw at least one file.
Lets take a look at how the Gab engine is initialized there.
```c
  union gab_value_pair res = gab_create(
      (struct gab_create_argt){
          .len = ndefault_modules,
          .modules = default_modules,
          .roots =
        // When running a built-app, we only need a single empty root.
              (const char *[]){
                  "",
                  nullptr,
              },
        // When running a built-app, we don't want to hit the user's file system at all.
        // The only 'exister' checks if the path exists in the zip archive.
        // There are still two loaders, one for native modules and one for source files.
        // They both load the file from the archive, instead of the filesystem.
          .resources =
              (struct gab_resource[]){
                  {"mod/", GAB_DYNLIB_FILEENDING, gab_use_zip_dynlib,
                   zip_exister},
                  {"", GAB_DYNLIB_FILEENDING, gab_use_zip_dynlib, zip_exister},
                  {"", "/mod.gab", gab_use_zip_source, zip_exister},
                  {"mod/", ".gab", gab_use_zip_source, zip_exister},
                  {"", ".gab", gab_use_zip_source, zip_exister},
                  {},
              },
      },
      &gab);
```
The existers and loaders for zip archives are a little bit more involved, and can be omitted here. Feel free to explore the source code on Github if you're curious.
With this, we can run built gab-apps when we detect that the program is run as `myapp` instead of `gab`. We unzip the archive, and run the `myapp` module after installing
the zip-loader hooks. Yay!

> But how do we *get* a built-app in the first place?
### Introducing `gab build`
Here lies the magic of `gab build`. Lets take a look at an example:
```bash
gab build -m tests,cgui test
```
See `gab help build` for more information. In summary, the `-m` option appends the comma-separated list to the builtin list of modules to be bundled into the build. The final argument
`test` defines the _entrypoint_ of the bundle. This module will be included in the bundle, determine the name of the final `exe`, and will be invoked when the user runs the executable.

This is neat, but not the whole story. `gab build` actually lets you build executables for *any* of Gab's supported platforms! That means I can run:
```bash
gab build -p aarch64_macos_none -m tests,cgui test
```
and get an equivalent macos arm64 executable - even though I'm on an intel chip, running Linux! Gab does this by downloading the Gab runtime and modules for the appropriate platform, and using these to
build the bundle. This makes distributing native binaries a breeze!

Here is a final code snippet, which creates the bundlefile. Again, the fantastatic API of miniz makes this so easy.
```c
// ...
  FILE *bundle_f = fopen(bundle, "w");

  if (!bundle_f) {
    clierror("Failed to open bundle file '%s' to write.\n", bundle);
    return 1;
  }

/* Copy the gab exe to the beginning of this bundle file */
  copy_file(exe, bundle_f);

/* Begin appending the zip archive */

  mz_zip_archive zip_o = {0};

  if (!mz_zip_writer_init_cfile(&zip_o, bundle_f, 0)) {
    mz_zip_error e = mz_zip_get_last_error(&zip_o);
    const char *estr = mz_zip_get_error_string(e);
    clierror("Failed to initialize zip archive: %s.\n", estr);
    return 1;
  }

/* Default modules */
  for (int i = 0; i < ndefault_modules_deps; i++)
    v_s_char_push(&args->modules, s_char_cstr(default_modules_deps[i]));

/* Given bundle module */
  v_s_char_push(&args->modules, s_char_cstr(module));

/* Any -m modules */
  for (int i = 0; i < args->modules.len; i++)
    if (!add_module(&zip_o, roots, resources,
                    v_s_char_val_at(&args->modules, i)))
      return 1;

/* Finalize and write the archive! */
  if (!mz_zip_writer_finalize_archive(&zip_o)) {
    mz_zip_error e = mz_zip_get_last_error(&zip_o);
    const char *estr = mz_zip_get_error_string(e);
    clierror("Failed to finalize zip archive: %s.\n", estr);
    mz_zip_writer_end(&zip_o);
    return 1;
  }

  if (!mz_zip_writer_end(&zip_o)) {
    mz_zip_error e = mz_zip_get_last_error(&zip_o);
    const char *estr = mz_zip_get_error_string(e);
    clierror("Failed to cleanup zip archive: %s.\n", estr);
    return 1;
  }
// ...
```
