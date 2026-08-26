---
title: 'Modules'
---

#

## What is a module?
A module is single file. Modules only exist in the context of *packages*: the folder which contains them.

{{< filetree/container >}}
  {{< filetree/folder name="my-package@0.1.0" >}}
    {{< filetree/file name="mod.gab" >}}
    {{< filetree/file name="app.gab" >}}
    {{< filetree/folder name="data" >}}
        {{< filetree/file name="some_data.json" >}}
    {{< /filetree/folder >}}
  {{< /filetree/folder >}}
{{< /filetree/container >}}

The above filetree describes *one package*: `my-package@0.1.0`. It contains several modules:
- The *entrypoint*, `mod.gab`
- A gab source file, `app.gab`
- A static json data file, `data/some_data.json`

These modules are written as:
- `my-package@0.1.0` (`mod.gab` is a special filename, it serves as the default when no module is specified)
- `my-package@0.1.0:app` (Specify the `app.gab` module)
- `my-package@0.1.0:some_data.json` (The `data` subfolder is checked for matches)

This section contains documentation for the various modules that ship with gab's builtin package.
Most of them are imported into the runtime for you automatically, and therefore do not requre a call to `use:`.

{{< cards cols="2">}}
    {{< card link="/docs/gabonomicon" title="Gabonomicon" icon="book-open" >}}
    {{< card link="/docs/gabonomicon/examples" title="Examples" icon="pencil" >}}
{{< /cards >}}
