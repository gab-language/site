+++
date = '2025-02-07T16:06:50-05:00'
title = 'Strings'
weight = 2
+++
This chapter will discuss the four basic string-ish types. It is meaningful to group these four types together because they **share data in memory**.
The string `"true"` and the message `true:` all the share same four bytes of memory: `[ 't', 'r', 'u', 'e' ]`.
They differentiate their type by tagging the values slightly differently - but this is an implementation detail. The important note to take from this is that
converting these types into each other (eg: `'true'.messages\into`) is a constant-time operation. There is no copying, nor memory allocation.
## Strings
Strings are sequences of UTF8-encoded bytes. Single-quoted strings support some escape sequences, including unicode.
```gab
"Hello!"
"\tHello\n"
"Hello \u[2502]"
```
The `gab\string` type responds to messages respecting its UTF-8 Encoding. This means that some operations actually take linear time, when you may expect them to be constant time. For example,
slicing a UTF-8 string at a given index requires processing the string linearly - as UTF8 is a multi-byte character encoding and codepoints may be anywhere from one to four bytes long.
On the other hand, the `gab\binary` type is trivially convertible from `gab\string`, and respects bytes directly, without enforcing or respecting *any* encoding. Becaues of this, converting from a `gab\binary` to a `gab\string` can fail if the binary is not valid UTF-8.
```gab
smiley = '😀'

smiley.len
# => 1

smiley_bin = smiley.binaries\into
# => <gab\binary ...>

smiley_bin.len
# => 4
```
There is no syntax for string interpolation, but it is easy to construct strings out of other values using `make:`.
```gab
full_name = Strings.make("Ada" " " last_name)

# The fmt package also supplies the sprintf: message
'Format a value: $'.sprintf({ name: 'bob' })
# => 'Format a value: { name: bob }'
```
## Binaries
As mentioned above, the `gab\binary` allows for operating on bytes directly - there is no encoding enforced. This means indexing/slicing operations are constant time.
There is no syntax for constructing binary literals, but other types can be converted into binaries.
```gab
"This is a string" .slice(3 8) # Requires linearly scanning from the front of the string
"This will be a binary" .binaries\into .slice (3 8) # slices from the 3rd to 8th byte in constant time
Binaries.make('This is also makes a binary')
