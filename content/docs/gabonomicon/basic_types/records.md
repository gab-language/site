---
title: Records
weight: 3
---

Records are the only data structure in Gab. They serve as both dictionareis and lists.

## `gab\record`

### Dictionaries

Dictionary-style records allow arbitrary keys. They are constructed with `{}`, with keys and values in pairs:

```gab
a_record = { name: 'bob', age: 44 }
another  = { key: 'value', 'another_key' 10 }
```

>[!NOTE]
>Note that keys can be any value. Messages and strings are the most common, but numbers, blocks, channels, even other records are all valid keys.

### Lists

List-style records use increasing integer keys starting from zero. They are constructed with `[]`:

```gab
a_list = [1 2 3]
a_list   # => [1, 2, 3]
```

A list can also be constructed using explicit integer keys in dictionary syntax. Gab recognises the shape and still displays it as a list:

```gab
a_list = { 0 1, 1 2, 2 3 }
a_list   # => [1, 2, 3]
```

The `is\list:` message is used to determine if a given record is a list.

```gab
[1 2].is\list # => true:
{ name: 'Rich' }.is\list # => false:
```

>[!NOTE]
>The empty record `{}` is a list, whether you write it like `[]` or like `{}`.

## List-to-dictionary transitions

Adding a non-integer key to a list produces a dictionary:

```gab
a_list = [1 2 3]
a_list = a_list.put(name: 'bob')
# => { 0: 1, 1: 2, 2: 3, name: 'bob' }
```
