---
title: Shapes
weight: 5
---

A shape describes the keys of a record, in order. It is the record's type. All records with the same keys in the same order share exactly one shape value.

```gab
a = { name: 'Joe' }
b = { name: 'Rich' }

a?          # => <gab\shape name:>
b?          # => <gab\shape name:>
(a?) == (b?)  # => true:
```

## Obtaining a shape

There are multiple ways to get a shape value.

**From a record**, using the `?` message:

```gab
Person = { name: '', age: 0 }?
# => <gab\shape name: age:>
```

**Directly**, using `Shapes.make:` with a list of keys, or the shape syntax:

```gab
Person = Shapes.make(name:, age:)
# => <gab\shape name: age:>
Person = \{ name: age: }
# => <gab\shape name: age:>
```

Both produce the same shape value. The `?` approach is convenient when you already have an example record; `Shapes.make` is useful when you want to define the shape without constructing a record first.

## Shapes as specialization targets

Shapes are most useful as receiver types in `def:`, `defcase:`, and `defmodule:`. All records with a matching shape will respond to the defined message:

```gab
Person = Shapes.make(name:, age:)

birthday: .def (Person, () => do
  'Happy Birthday, $!'.sprintf(self.name).println
  self.put(age: self.age + 1)
end)

bob = { name: 'bob', age: 44 }
bob = bob.birthday
# => Happy Birthday, bob!

bob.age   # => 45
```

## Shapes in dispatch

When Gab resolves a message send, the shape is checked as the **super type** before the record's base type (`gab\record`). This means shape-specialised messages take precedence over general record behaviour:

```gab
z: .def (\{ x: }, 'shape case')
z: .def (Records.t, 'record case')
z: .def 'general case'

{ x: 1 }.z          # => 'shape case'   (shape wins over general)
{ y: 1 }.z          # => 'record case'
'something else!'.z # => 'general case'
```

See [Messages — Dispatch Resolution Order](/docs/basic_types/messages#dispatch-resolution-order) for the full sequence.
