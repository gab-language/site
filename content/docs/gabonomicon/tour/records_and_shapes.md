---
title: Records & Shapes
weight: 2
---

## Records

Gab has one compound data structure: `gab\record`. Both Lists and Dictionaries are built on top of it. This constraint is intentional and furthers Gab's focus on minimalism.

### Dictionaries

Curly bracket syntax creates dict-style records. The values between the `{}` are treated as alternating keys and values.

```gab
bob = { name: 'bob', age: 44 }
```

Access values using message sends:

```gab
bob.name  # => 'bob'
bob.age   # => 44
```

If the message doesn't exist as a key in the record, Gab will panic with `MISSING SPECIALIZATION`. If you're not sure the key exists, try:

```gab
(ok, is_hungry) = bob.at(hungry:)
```

If the key exists, `ok` will be `ok:`, and `is_hungry` will have the value in the record. Otherwise, ok will be `none:`. More on this pattern in the section on [error handling](/docs/gabonomicon/tour/error_handling).
### Lists

Square-bracket syntax creates **list-style** records, where the keys are implicit integer indices:

```gab
colors = ['red', 'green', 'blue']
colors.at(0).unwrap  # => 'red'
```

Both *Dictionaries* and *Lists* share the `gab\record` type.

## Immutability

All records in Gab are **immutable** - You cannot change a record in place. Instead, messages like `put` return a new record with the updated value, leaving the original value untouched:

```gab
bob = { name: 'bob', age: 44 }

alice = bob.put(name: 'alice')

bob    # => { name: 'bob', age: 44 }
alice  # => { name: 'alice', age: 44 }
```

Gab's immutable record is implemented as a Hash-Array-Mapped Trie, a persistent data structure used by many functional languages. `put` operations essentially create **diffs**, which allow records to share the data that didn't change.

## Shapes

Records are especially unique for their type. Before we can discuss what this means and why its important, lets get a baseline to compare to.

Every value in Gab has a **type**, which you can inspect with the `?` message. For most values, `?` returns a string describing the type:

```gab
'hello' ?  # => 'gab\string'
44 ?       # => 'gab\number'
```

Message values are their own type — `?` on a message returns the message itself:

```gab
ok: ?  # => ok:
```

A record's type is its **shape**. This is a separate value that describes the record's keys:

```gab
{ name: 'bob', age: 44 } ?
# => <gab\shape name: age:>

['red', 'green', 'blue'] ?
# => <gab\shape 0: 1: 2:>
```

All records with the same keys in the same order share the same shape. It follows that any two records with the same shape therefore *have the same type*.

### Defining messages for shapes

This is where shapes become powerful. When you define a message, you specialize it for a particular type. Typically, this is either a builtin type via `<Module>.t`, a message,  or a **shape**.

```gab
# Capture the shape of a "Person-like" record
Person = { name: 'bob', age: 0 } ?
# Or construct a shape from keys directly
Person = Shapes.make(name: age:)

birthday: .def (Person, () => do
  'Happy Birthday, $!'.sprintf(self.name).println
  self.put(age: self.age + 1)
end)
```

Here `birthday:` is a **message value** — the trailing colon is part of the value, not punctuation. Sending `def:` to `birthday:` registers a new specialization: whenever a record with the `Person` shape receives `birthday:`, call this method.

It is a convention in Gab to define a `t:` message on your own modules that returns the type others should specialize against. For built-in types, the standard library already follows this convention — `Strings.t` returns the string type, so you never need to write a bare type name directly.

Now any record with the keys `name:` and `age:` responds to `birthday:`:

```gab
bob = { name: 'bob', age: 44 }
bob = bob.birthday
# => Happy Birthday, bob!

bob.age  # => 45
```

Notice that `birthday` returns a new record (with `age` incremented) — it doesn't mutate `bob` in place. To "update" bob, you simply rebind the name.

### Types

Types in Gab dictate how values respond to messages. This is a powerful tool for creating intuitive interfaces.

```gab
Point   = { x: 0, y: 0 } ?

+: .def (Point, (dx, dy) => do
    { x: (self.x + dx), y: (self.y + dy) }
end)

p = { x: 10 y: 10 }
p = p + (5, 15)
# => { x: 15, y: 25 }
```
