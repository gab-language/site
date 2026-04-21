---
title: Messages
weight: 3
---

A message is a unique value whose type is itself.

## `gab\message`

Messages values are a name or operator ending with a `:`.

```gab
+:
true:
<=!=>:

ok:?      # => ok:
```

Messages are used as record keys, as sentinel/enum values, and as the mechanism for polymorphism. They are Gab's implementation of booleans, nil, and result values — there are no built-in keywords for any of these.

## Defining specializations

Messages responds to `def:`. This adds a new **specialization** of that message for a specific receiver type:

```gab
greet: .def (Strings.t, () => do
  'Hello, $!'.sprintf(self).println
end)

'Alice'.greet   # => Hello, Alice!
```

There are multiple ways to define messages, and it is commonplace to create your own.

### `def:`

Defines a single specialization for a single type:

```gab
birthday: .def (Person, () => do
  self.put(age: self.age + 1)
end)
```

If you omit the type, you create a *general* specialization. Think of this as a fallback implementation which will run if nothing more specific exists.

### `defcase:`

Defines multiple specializations for one message at once, using a record. Each key-value pair in the record is used to create a new type-specialization.

```gab
describe: .defcase {
  ok:   result => 'Success: $'.sprintf(result).println
  err:  msg    => 'Error: $'.sprintf(msg).println
  nil:          => 'Nothing here.'.println
}
```

Each key in the record is a receiver type; each value is the block to call when that type receives the message. Values alone (without a block) are also valid — they are returned directly.

### `defmodule:`

Defines multiple messages for multiple receiver types at once:

```gab
[Point, Vector] .defmodule {
  scale: (factor) => self.put(x: self.x * factor, y: self.y * factor)
  zero:  ()       => self.put(x: 0, y: 0)
}
```

## Dispatch resolution order

When a message is sent to a value, Gab resolves the specialization in this order:

1. **Super type** — if the value's type (e.g. a `gab\shape`) has a specialization, use it.
2. **Type** — use the specialization defined for the value's `gab\` type (e.g. `gab\record`).
3. **Property** — if the receiver is a record and the message name matches one of its keys, return that value. This is how field access works: `{ name: 'bob' }.name` returns `'bob'` without any explicit `def:`.
4. **General** — use a specialization defined with no specific type.

```gab
y: .def 'general case'

z: .def (Shapes.make(x:), 'shape case')

{ x: 1 }.y   # => 'general case'  (general)
{ x: 1 }.z   # => 'shape case'    (super type — the shape <x:>)
{ x: 1 }.x   # => 1               (property)
```

## `and:` `or:` `then:` `else:`

These messages are defined on `true:` and `false:` in the core library. Their semantics differ in one important way:

`and:` and `or:` accept **values**. The argument is always evaluated before the message is sent:

```gab
true:  .and 2    # => 2
false: .and 2    # => false:
false: .or  2    # => 2
true:  .or  2    # => true:
```

`then:` and `else:` accept **blocks**. Only the appropriate branch is invoked:

```gab
true: .then  () => 'yes'.println   # => yes
true: .else  () => 'no'.println    # (block is never called)
```

## `nil:` `none:`

`nil:` is the value Gab binds to names that have no corresponding value. This may occur if, for example,  a binding list is longer than the tuple being destructured:

```gab
(a, b) = 1   # a => 1, b => nil:
```

`none:` is used by certain APIs to signal the absence of a result (as opposed to an error). Both are `nil:` and `none:` are just plain messages.
