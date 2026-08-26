---
weight: 3
---

#

Records are the only data structure in gab. They serve as both dictionaries and lists.

## `gab\record`

### Dictionaries

Dictionary-style records allow arbitrary keys. They are constructed with `{}`, with keys and values in pairs:

```gab
a_record := { name: 'bob', age: 44 }
another  := { key: 'value', 'another_key' 10 }
```

>[!NOTE]
>Keys can be any value. Messages and strings are the most common, but numbers, blocks, channels, even other records are all valid keys.

### Lists

List-style records use increasing integer keys starting from zero. They are constructed with `[]`:

```gab
a_list := [1 2 3]
a_list   # :: [1, 2, 3]
```

A list can also be constructed using explicit integer keys in dictionary syntax. gab recognises the shape and still displays it as a list:

```gab
a_list := { 0 1, 1 2, 2 3 }
a_list   # :: [1, 2, 3]
```

The `is\list:` message is used to determine if a given record is a list.

```gab
[1 2].is\list # :: true:
{ name: 'Rich' }.is\list # :: false:
```

>[!NOTE]
>The empty record `{}` is a list, whether you write it like `[]` or like `{}`.

## Transitioning between Lists and Dictionaries

Adding an out-of-order or non-integer key to a list transforms it into a dictionary:

```gab
a_list := [1 2 3]
a_list := a_list.put(name: 'bob')
# :: { 0: 1, 1: 2, 2: 3, name: 'bob' }
```

Conversely, *removing* such a key transforms the dictionary back into a list (if all the remaining keys are now properly list-like)

```gab
a_dict := { 0 1, 1 2, 2 3, name: 'bob']
a_list := a_dict.take(name:)
# [1 2 3]
```
