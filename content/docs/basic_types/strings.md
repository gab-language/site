+++
date = '2025-02-07T16:06:50-05:00'
title = 'Strings'
weight = 2
+++
This chapter will discuss the three basic string-ish types. It is meaningful to group these three types together because they **share data in memory**.
The string `"true"` and the message `true:` each share the same four bytes of memory in the heap: `[ 't', 'r', 'u', 'e' ]`.
The values differentiate their type by tagging themeselves slightly differently - but this is an [implementation detail](/site/blog/values). The important note to take from this is that
converting these types into each other (eg: `'true'.messages\into`) is a constant-time operation. There is **no copying, nor memory allocation**.
## Strings
Strings are sequences of UTF8-encoded bytes. Single-quoted strings support some escape sequences, while double-quoted strings do not.
```gab
"Hello!"
'\tHello\n'
'Hello \u[2502]'
```
The `gab\string` type *respects* its UTF-8 Encoding. Operations that would be constant time fora `gab\binary` may actually be linear time for a `gab\string`. For example,
slicing a UTF-8 string at a given index requires processing the string linearly. This is because UTF8 is a multi-byte character encoding and codepoints may be anywhere from one to four bytes long.

On the other hand, the `gab\binary` type is trivially convertible from `gab\string`, and respects bytes directly, without enforcing or respecting *any* encoding. Becaues of this, converting from a `gab\binary` to a `gab\string` can fail if the binary is not valid UTF-8.
```gab
smiley = '😀'

smiley.len
# => 1

smiley_bin = smiley.to\b
# => <gab\binary ...>

smiley_bin.len
# => 4
```
There is no syntax for string interpolation, but it is easy to construct strings out of other values using `make:` or `sprintf:`.
```gab
full_name = Strings.make("Ada" " " last_name)

'Format a value: $'.sprintf({ name: 'bob' })
# => 'Format a value: { name: bob }'
```
## Binaries
As mentioned above, the `gab\binary` operates on bytes directly - there is no encoding enforced. This means indexing/slicing operations are constant-time.
There is no syntax for constructing binary literals, but other types can be converted into binaries.
```gab
# Requires linearly scanning from the front of the string
"This is a string".slice(3 8)

# slices from the 3rd to 8th byte in constant time
"This will be a binary".to\b.slice(3 8)
```
