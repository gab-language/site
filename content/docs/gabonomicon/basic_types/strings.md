---
title: Strings & Binaries
weight: 2
---

Gab has two string-like types: `gab\string` and `gab\binary`. A third type, `gab\message`, also belongs to this family. All three **share their character data in memory** — the bytes `[ 't', 'r', 'u', 'e' ]` are stored once on the heap, shared between the string `"true"` and the message `true:`. Converting between these types is therefore a constant-time operation with no allocation.

## `gab\string`

Strings are UTF-8 encoded byte sequences. Single-quoted strings support escape sequences; double-quoted strings do not.

```gab
"Hello!"
'\tHello\n'
'Hello \u[2502]'
```

Because Gab respects UTF-8 encoding, operations that are trivial on raw bytes may be linear-time on strings. Slicing a string at a given index requires scanning from the start, since utf8 codepoints are 1–4 bytes wide.

```gab
smiley = '😀'

smiley.len    # => 1  (one codepoint)
```

**Constructing strings:**

```gab
Strings.make('Ada', ' ', last_name)

'Format a value: $'.sprintf({ name: 'bob' })
# => 'Format a value: { name: bob }'
```

`sprintf` replaces each `$` in the format string with the corresponding argument, in order.

## `gab\binary`

`gab\binary` operates on raw bytes with no encoding enforced. Indexing and slicing are constant-time because there are no multi-byte codepoints to account for.

There is no literal syntax for binaries. Convert a string with `to\b`:

```gab
smiley     = '😀'
smiley_bin = smiley.to\b

smiley.len      # => 1  (codepoints)
smiley_bin.len  # => 4  (bytes)
```

Slicing a binary is constant-time:

```gab
"This is a string".slice(3, 8)        # Linear — scans from start
"This is a string".to\b.slice(3, 8)   # Constant time — byte offset
```

Converting a binary back to a string can fail if the bytes are not valid UTF-8:

```gab
(status, str) = some_binary.as\s
```

## Shared memory with `gab\message`

Because `gab\string`, `gab\binary`, and `gab\message` all share the same underlying character data, converting between them is zero-cost. The string `'true'` and the message `true:` occupy the same bytes — they differ only in their type tag.

```gab
'true'.to\m   # => true:   (no allocation)
true:.to\s    # => 'true'  (no allocation)
```

This design means message values are just as efficient as strings in any context where they appear as keys or identifiers.
