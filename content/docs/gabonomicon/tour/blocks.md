---
title: Blocks
weight: 3
---

A **block** is Gab's name for a closure - an anonymous function that can capture values from its surrounding scope. Blocks are values: you can store them in records, pass them as arguments to messages, and call them.

## Block syntax

The `=>` operator creates a block. The left-hand side is the **binding** (the parameter list), and the right-hand side is the **expression** that becomes the return value.

```gab
double = (x) => x * 2

double.(5)
# => 10
```

Blocks are called with an **empty message send**. This is a bare `.` followed by any arguments.

For multi-line blocks, use `do ... end` on the right-hand side. A `do ... end` expression evaluates to the last expression before the `end`:

```gab
describe = (name, age) => do
  line1 = 'Name: $!'.sprintf(name)
  line2 = 'Age: $!'.sprintf(age)
  Strings.make(line1 '\n' line2)
end

describe.('Alice', 30).println
# => Name: Alice
# => Age: 30
```

## Blocks with no parameters

If a block takes no arguments, use an empty tuple as the **binding**.

```gab
greet = () => 'Hello!'.println

greet.()
# => Hello!
```

## Blocks as arguments

Blocks are commonly passed as arguments to messages. You've already seen this with boolean branching:

```gab
(temperature > 80)
  .then(() => 'Too hot!'.println)
  .else(() => 'Just right.'.println)
```

Blocks are also useful as arguments to messages like `each` and `map`:

```gab
['alice', 'bob', 'carol'].each (name) => do
  'Hello, $!'.sprintf(name).println
end

# => Hello, alice
# => Hello, bob
# => Hello, carol
```

## Multiple return values

Blocks can return more than one value using a **tuple**.

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

### A note on commas
Commas are whitespace in Gab. Most of the time they are purely visual, to help us distiguish key-value pairs in a dictionary.
However, sometimes whitespace *does* have syntactic meaning. Take a look at the below example.

```gab
(1 + 2 3)   # => (3, 3)  — `2` is the argument to `+`, `3` is the second element
(1 +, 2 3)  # => Error   — the comma cuts off `+` before it gets an argument
```

This doesn't just happen with commas - gab treats commas, semi-colons, and new-lines all identically.

---

Multiple return values become especially important when combined with message chaining. When you chain a message send, **all return values** from the left side are forwarded as the receiver and arguments of the next message. Given:

```gab
IO.File.make(self).my_message
```

This is exactly equivalent to:

```gab
(status, file) = IO.File.make(self)
status.my_message(file)
```

The first return value becomes the receiver; subsequent return values become arguments. This is why the error-handling pattern in Gab is so fluid — `ok:` and `err:` can each respond differently to the same chained message, routing the remaining values accordingly. You'll see this in detail in [Error Handling](/docs/tour/error_handling).

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

## Blocks and fibers

A block is the unit of work you hand to a fiber. When you spawn a fiber, you give it a block to execute. The block runs parallel in its own lightweight thread of execution. See [Fibers & Channels](/docs/tour/fibers_and_channels) for the full picture.
