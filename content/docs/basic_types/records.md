---
title: Records
weight: 3
---

`gab\record` is the only data structure in Gab. It serves as both a dictionary and a list. All records are immutable.

## Lists

List-style records use integer keys starting from zero. They are constructed with `[]`:

```gab
a_list = [1, 2, 3]
a_list   # => [1, 2, 3]
```

A list can also be constructed using explicit integer keys in dictionary syntax — Gab recognises the shape and displays it as a list:

```gab
a_list = { 0 1, 1 2, 2 3 }
a_list   # => [1, 2, 3]
```

## Dictionaries

Dictionary-style records allow arbitrary keys. They are constructed with `{}`, with keys and values in pairs:

```gab
a_record = { name: 'bob', age: 44 }
another  = { key: 'value', 'another_key' 10 }
```

## Accessing Values

Record keys that are message values can be accessed directly as a message send. This works through the property step of dispatch resolution — no `def:` required:

```gab
{ name: 'bob' }.name   # => 'bob'
```

For keys that are not message values, or when you need a safe access that won't crash on a missing key, use `at:`:

```gab
record.at(key:)   # => (ok:, 'value')  or  (none:, nil:)
```

Direct property access on a missing key will raise an error. `at:` returns a tuple and lets you handle the missing case explicitly.

## Immutability and `put:`

Records cannot be modified in place. `put:` returns a new record with the given key set to the given value:

```gab
bob   = { name: 'bob',   age: 44 }
alice = bob.put(name: 'alice')

bob    # => { name: 'bob',   age: 44 }
alice  # => { name: 'alice', age: 44 }
```

Records are implemented as a **bit-partitioned vector trie**, inspired by Clojure's persistent data structures. This means `put:` uses **structural sharing** — the new record shares most of its memory with the original, so large records can be updated efficiently without copying all their data.

## List-to-Dictionary Transitions

Adding a non-integer key to a list produces a dictionary:

```gab
a_list = [1, 2, 3]
a_list = a_list.put(name: 'bob')
# => { 0: 1, 1: 2, 2: 3, name: 'bob' }
```

The transition is explicit and immediate — the shape changes and the value is no longer displayed as a list.
