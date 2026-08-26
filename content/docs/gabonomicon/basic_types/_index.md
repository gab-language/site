---
weight: 3
---

#

## Builtin Types

gab has a small, fixed set of built-in types. This section serves a reference for each one.

| Type | Description |
|---|---|
| `gab\number` | IEEE 754 64-bit float |
| `gab\string` | UTF-8 encoded byte sequence |
| `gab\binary` | Raw, unencoded byte sequence |
| `gab\message` | A self-typed value |
| `gab\block` | A closure |
| `gab\record` | The only data structure — serves as both list and dictionary |
| `gab\shape` | Describes the keys of a record; the record's type |
| `gab\fiber` | A lightweight concurrent thread |
| `gab\channel` | A synchronised conduit between fibers |
| `gab\box` | An opaque wrapper around a native C value |

If you're looking for conceptual introductions to each of these types, check out the language tour. To see these types in use in small gab programs, check out the examples.

---

{{< cards cols="2">}}
  {{< card link="docs/tour" title="Language Tour" icon="academic-cap" >}}
  {{< card link="docs/gabonomicon/examples" title="Examples" icon="pencil" >}}
{{< /cards >}}
