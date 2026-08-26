---
title:
---

#

## The *Gabonomicon* 
This section is the canonical gab handbook. It is the recommended starting-point for developers who want to learn gab.

Everything you need to get off the ground and writing gab lives in this section - it also includes some useful example programs to demonstrate
how you may use gab's features to build software.

{{< cards cols="2">}}
    {{< card link="/docs/gabonomicon" title="Gabonomicon" icon="book-open" >}}
    {{< card link="/docs/gabonomicon/examples" title="Examples" icon="pencil" >}}
{{< /cards >}}


## Modules

This section contains specifications for the modules that come with gab - specifically, all the modules in the `gab-language/cgab` package.
Such modules include [Number](/docs/modules/number), [String](/docs/modules/string), and [File](/docs/modules/file). Consider this gab's standard-library documentation.

These pages are generated from **Specs**, which is itself a builtin module for testing defining types.

{{< cards cols="2">}}
    {{< card link="/docs/modules" title="Modules" icon="cube" >}}
{{< /cards >}}

## Protocols
This section contains specifications for the protocols that are defined and used with the builtin `gab-language/cgab` package. Such protocols include [seqable](/docs/protocols/seqable) and [streamable](/docs/protocols/streamable), which
define interfaces for iterating and performing Io, respectively.

These pages are useful when defining your own types which fulfill these protocols, for use with messages from the builtin package such as *map* or *pipe*.

They are also generated from **Specs**. It is good practice to create specs when building your own protocols, for documentation and testing.

{{< cards cols="2">}}
    {{< card link="/docs/protocols/" title="Protocols" icon="cube" >}}
{{< /cards >}}
