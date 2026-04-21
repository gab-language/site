---
title: Types
weight: 3
---

Gab has a small, fixed set of built-in types. This section is a reference for each one.

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

For a conceptual introduction to these types, see the [Language Tour](/docs/tour).
