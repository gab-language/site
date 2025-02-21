+++
date = '2025-02-07T16:07:28-05:00'
title = 'Records'
weight = 2
+++
Records are collections of key-value pairs. They are ordered and structurally typed.
### Dictionaries
 Between the curly brackets `{}`, expressions are expected in key-value pairs.
Any expression is allowed as a key or value.
```gab
a_record = { key: 'value' }

a_record .key                    # => 'value'

another_record = { key: 'value', 'another_key' 10 } 

another_record .at 'another_key' # => (ok: '10)
```
Records, like all values in Gab, are **immutable**. This means that setting values in records returns a *new record*.
```gab
a_record = { key: 'value' }

a_record = a_record .key 'another value'   # => When an argument is provided, this message serves as a 'set' instead of a 'get'.

a_record                                   # => { key:  'another value' }

a_record = a_record .put (key: 'something else')

a_record                                   # => { key: 'something else' }
```
### Lists
Lists are constructed with the square brackets `[]`, and any number of expressions are allowed inside.
Lists are a special kind of record - one in which all they keys are ascending integers, starting from 0.
```gab
a_list = [1 2 3] 

a_list # => [1, 2, 3]

a_list = { 0 1, 1 2, 2 3 }

a_list # => [1, 2, 3]
```
### Records
Both **Dictionaries** and **Lists** use the same underlying datastructure, `gab\record`. In order to make these immutable data structures fast, records are implemented with a **bit partitioned vector trie**.
Gab's implementation is very much inspired by clojure's immutable vectors.
Records are able to *share memory* under the hood, to avoid copying large of data for a single key-value mutation. This is called structural sharing,
and is a common optimization in immutable data structures.

As seen above, `gab\record` implements some useful messages `put:` and `at:`.
```gab
some_record .at key: # => (ok:, 'value')
```
### Shapes
All records have an underlying shape. They determine the available keys, and their order - think of them as an implicit class.
Records with the same keys in the same order *share the same shape*.
```gab
some_record = { x: 1 y: 2 }

shape_x_y = some_record ? # => <gab.shape x: y:>

({ x: 2 y: 3 } ?) == shape_x_y # => true:
```
Shapes are useful for defining methods. When resolving which specialization to use for a given value, Gab checks in the following order:

 - If the value has a **super type**, and it has an available specialization, use it.
 - If available, use the **type's** specialization.
 - If available, use the **property**.
 - If available, use the **general** specialization.
 - No specialization found.

For example: `{ x: 1 }` has a **super type** of `<gab\shape x:>`, and a **type** of `gab\record`.
```gab
# Define the message y: in the general case.
y: .def! 'general case'

# Define the message z: in the case of <gab.shape x:>
z: .def! (
    Shapes.make x:,
    'shape case')

{ x: 1 } .x # => 2

{ x: 1 } .y # => 'general case'

{ x: 1 } .z # => 'shape case'
```
