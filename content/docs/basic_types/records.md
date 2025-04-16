+++
date = '2025-02-07T16:07:28-05:00'
title = 'Records'
weight = 5
+++
Records are collections of key-value pairs. They are ordered and structurally typed. In Gab they come in two flavors - Dictionaries and Lists.
### Dictionaries
Dictionaries are Gab records which allow arbitrary values as keys. They are denoted with `{}`.

Between the curly brackets, expressions are expected in key-value pairs.
Any expression is allowed as either a key or value.
```gab
a_record = { key: 'value' }

a_record .key                    # => 'value'

another_record = { key: 'value', 'another_key' 10 } 

another_record .at 'another_key' # => (ok: '10)
```
### Lists
Lists are records which allow only monotonically-increasing-integer values as keys. This is some fancy talk for saying it only allows for keys `0-n`.

Lists are constructed with the square brackets `[]`, and any number of expressions are allowed inside.
```gab
a_list = [1 2 3] 

a_list # => [1, 2, 3]

a_list = { 0 1, 1 2, 2 3 }

a_list # => [1, 2, 3]
```
> Note - you can construct a list with the same syntax as a dictionary by typing in those integer keys yourself.
> Gab will still consider it a list-type record.

While you *are* allowed to set any key on a list, keep in mind that Gab will transition the list *into* a dictionary.
```gab
a_list = [1 2 3]
# => [1, 2, 3]

a_list = a_list.put(name: 'bob')
#=> { 0 1, 1 2, 2 3, name: bob }
```
### Records
The rest of this chapter is about `gab\record` itself, and therefore applies to both dictionary and list flavors.

Records, like all values in Gab, are **immutable**. This means that setting values in records returns a *new record*.
```gab
a_record = { key: 'value' }

a_record                                   # => { key:  'another value' }

a_record = a_record .put (key: 'something else')

a_record                                   # => { key: 'something else' }
```
Both **Dictionaries** and **Lists** use the same underlying datastructure, `gab\record`. In order to make these immutable data structures fast, records are implemented with a **bit partitioned vector trie**.
Gab's implementation is very much inspired by clojure's immutable vectors.
Because of this implementation, records are able to *share memory* under the hood, to avoid copying large of data for a single key-value mutation. This is called structural sharing,
and is a common optimization among immutable data structures.

As seen above, `gab\record` implements some useful messages `put:` and `at:`.
```gab
some_record .at key: # => (ok:, 'value')
```
### Shapes
All records have an underlying shape. Shapes determine what the available keys are, and their order. It might be useful to think of shapes as an implicit class.
Records with the same keys in the same order *share the same shape*.
```gab
some_record = { x: 1 y: 2 }

shape_x_y = some_record? # => <gab\shape x: y:>

({ x: 2 y: 3 }?) == shape_x_y # => true:
```
Shapes are useful for defining specializations. When resolving which specialization to use for a given value, Gab checks in the following order:

 - If the value has a **super type**, and said **super type** has an available specialization, use it.
 - If available, use the **type's** specialization.
 - If available, use the **property**.
 - If available, use the **general** specialization.
 - No specialization found.

For example: `{ x: 1 }` has a **super type** of `<gab\shape x:>`, and a **type** of `gab\record`.
```gab
# Define the message y: in the general case.
y: .def 'general case'

# Define the message z: in the case of <gab\shape x:>
z: .def (
    Shapes.make x:,
    'shape case')

{ x: 1 }.x # => 1

{ x: 1 }.y # => 'general case'

{ x: 1 }.z # => 'shape case'
```
