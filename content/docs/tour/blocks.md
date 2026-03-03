---
title: Blocks
weight: 3
---

A **block** is Gab's name for a lambda — an anonymous function that can capture values from its surrounding scope. Blocks are values: you can store them in records, pass them as arguments to messages, and call them.

## Block Syntax

The `=>` operator creates a block. The left-hand side is the **binding** (the parameter list), and the right-hand side is the **expression** that becomes the return value.

```gab
double = (x) => x * 2

double.(5)
# => 10
```

Blocks are called with an **empty message send** — a bare `.` followed by the argument list in parentheses. This is consistent with how all message sending works in Gab: `.` followed by a name is a named send; `.` alone is an anonymous send that invokes a block.

For multi-line blocks, use `do ... end` on the right-hand side. A `do ... end` evaluates to its last expression:

```gab
describe = (name, age) => do
  line1 = 'Name: $!'.sprintf(name)
  line2 = 'Age: $!'.sprintf(age)
  Strings.make(line1, '\n', line2)
end

describe.('Alice', 30).println
# => Name: Alice
# => Age: 30
```

## Blocks with No Parameters

If a block takes no arguments, use empty parentheses on both sides — in the definition and in the call:

```gab
greet = () => 'Hello!'.println

greet.()
# => Hello!
```

## Blocks as Arguments

Blocks are most commonly passed as arguments to messages. This is how all control flow is expressed in Gab. You've already seen this with boolean branching:

```gab
(temperature > 100)
  .then(() => 'Too hot!'.println)
  .else(() => 'Just right.'.println)
```

Collection messages like `each` and `map` also take blocks:

```gab
['alice', 'bob', 'carol'].each (name) => do
  'Hello, $!'.sprintf(name).println
end

# => Hello, alice
# => Hello, bob
# => Hello, carol
```

## Multiple Return Values

Blocks can return more than one value using a **tuple expression** — parentheses containing two or more values:

```gab
minmax = (a, b) => do
  (a < b)
    .then(() => (a, b))
    .else(() => (b, a))
end

(lo, hi) = minmax.(7, 3)

lo  # => 3
hi  # => 7
```

The comma between `a` and `b` is required here — without it, `a b` would be parsed as sending message `b` to `a`. In general, a comma inside a tuple terminates the preceding message send and starts a new element. This makes commas meaningful rather than decorative:

```gab
(1 + 2 3)   # => (3, 3)  — `2` is the argument to `+`, `3` is the second element
(1 +, 2 3)  # => Error   — the comma cuts off `+` before it gets an argument
```

Multiple return values become especially important when combined with message chaining. When you chain a message send, **all return values** from the left side are forwarded as the receiver and arguments of the next message. Given:

```gab
IO.File.make(self).my_message
```

This is exactly equivalent to:

```gab
(status, file) = IO.File.make(self)
status.my_message(file)
```

The first return value becomes the receiver; subsequent return values become arguments. This is why the error-handling pattern in Gab is so fluid — `ok:` and `err:` can each respond differently to the same chained message, routing the remaining values accordingly. You'll see this in detail in [Error Handling](/docs/tour/error-handling).

## Closures

Blocks close over their surrounding scope. Any name visible where the block is defined is accessible inside it:

```gab
prefix = 'Hello'

greet = (name) => do
  '$!, $!'.sprintf(prefix, name).println
end

greet.('world')
# => Hello, world
```

The block captures `prefix` at the time it is defined. If you rebind `prefix` later, the block still holds onto the original value — Gab's immutability makes this safe and predictable.

## Blocks and Fibers

A block is the unit of work you hand to a fiber. When you spawn a fiber, you give it a block to execute. The block runs concurrently in its own lightweight thread of execution. See [Fibers & Channels](/docs/tour/fibers-and-channels) for the full picture.
