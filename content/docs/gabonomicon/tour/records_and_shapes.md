---
title: Records & Shapes
weight: 2
---

Gab has exactly one data structure: `gab\record`. Everything else — lists, named objects, tuples — is built on top of it. This constraint is intentional: a single data structure means a single hot path to optimize, and a single mental model to carry around.

## Records

A record is a collection of key-value pairs. You create one using curly braces:

```gab
bob = { name: 'bob', age: 44 }
```

Access values using dot notation and a message:

```gab
bob.name  # => 'bob'
bob.age   # => 44
```

Square-bracket syntax creates **list-style** records, where the keys are implicit integer indices:

```gab
colors = ['red', 'green', 'blue']
colors.at(0)  # => 'red'
```

Both forms are the same underlying type.

## Immutability

All records in Gab are **immutable**. You cannot change a record in place. Instead, messages like `put` return a new record with the updated value, leaving the original untouched:

```gab
bob = { name: 'bob', age: 44 }

alice = bob.put(name: 'alice')

bob    # => { name: 'bob', age: 44 }
alice  # => { name: 'alice', age: 44 }
```

This is not a limitation — it's what makes concurrent programming in Gab safe. When values can never change, two fibers sharing a value is always safe. No locks, no races.

Gab's immutable record is implemented as a Hash-Array-Mapped Trie, the same persistent data structure used by Clojure. `put` operations share structure with the original, so they are efficient even on large records.

## Types and Shapes

Every value in Gab has a **type**, which you can inspect with the `?` message. For most values, `?` returns a string describing the type:

```gab
'hello' ?  # => 'gab\string'
44 ?       # => 'gab\number'
```

Message values are their own type — `?` on a message returns the message itself:

```gab
ok: ?  # => ok:
```

For records, the type is their **shape** — a value that describes the record's keys:

```gab
{ name: 'bob', age: 44 } ?
# => <gab\shape name: age:>

['red', 'green', 'blue'] ?
# => <gab\shape 0: 1: 2:>
```

Two records have the same type (the same shape) if and only if they have the same keys, regardless of their values.

## Defining Messages for Shapes

This is where shapes become powerful. When you define a message, you specialize it for a particular type — either a built-in type via `Module.t`, or a shape you've captured with `?`:

```gab
# Capture the shape of a "Person-like" record
Person = { name: 'bob', age: 0 } ?

birthday: .def (Person, () => do
  'Happy Birthday, $!'.sprintf(self.name).println
  self.put(age: self.age + 1)
end)
```

Here `birthday:` is a **message value** — the trailing colon is part of the value, not punctuation. Sending `def:` to `birthday:` registers a new specialization: whenever a record with the `Person` shape receives `birthday:`, this block runs.

It is a convention in Gab to define a `t:` message on your own modules that returns the type others should specialize against. For built-in types, the standard library already follows this convention — `Strings.t` returns the string type, so you never need to write a bare type name directly.

Now any record with the keys `name:` and `age:` responds to `birthday:`:

```gab
bob = { name: 'bob', age: 44 }
bob = bob.birthday
# => Happy Birthday, bob!

bob.age  # => 45
```

Notice that `birthday` returns a new record (with `age` incremented) — it doesn't mutate `bob` in place. To "update" bob, you simply rebind the name.

## Shapes as Types

You can think of shapes the way you'd think of types or interfaces in other languages — but without a separate type declaration syntax. The shape of a record *is* its type, and it falls out naturally from the keys you give it.

This means:
- No `class` declarations.
- No `interface` definitions.
- No `struct` boilerplate.

You define a record with the right keys, capture its shape, and define messages for that shape. That's the full pattern.

```gab
Point   = { x: 0, y: 0 } ?
Circle  = { center: {x:0, y:0}, radius: 0 } ?

area: .def (Circle, () => do
  3.14159 * self.radius * self.radius
end)

c = { center: { x: 10, y: 20 }, radius: 5 }
c.area
# => 78.53975
```
