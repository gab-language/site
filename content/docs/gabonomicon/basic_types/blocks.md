---
title: Blocks
weight: 6
---

A block is a function that captures its surrounding scope. Blocks are values: they can be stored, passed as arguments, and respond to messages.

## `gab\block`

```gab
square = (x) => x * x
square.(4)   # => 16
```

>[!NOTE]
>Every block has an implicit `self` binding. When a block is used as a message specialization via `def:`, `self` refers to the value that received the message. When called directly, `self` refers to the block itself.

## Variadic bindings

There are two kinds of variadic binding, distinguished by whether the collected arguments are treated as a list or as a record.

### List binding with `*`

A `*` suffix on a binding name collects a run of positional arguments into a list.
Its position in the binding list determines which arguments it absorbs.
The other bindings around it claim their arguments first, and `*` takes the rest:

```gab
first_and_rest = (first, rest*) => do
  'First: $'.sprintf(first).println
  'Rest: $'.sprintf(rest).println
end

first_and_rest.(1, 2, 3, 4)
# => First: 1
# => Rest: [2, 3, 4]
```

Because position determines what `*` absorbs, it can appear anywhere in the binding list:

```gab
(a*, b) = (1, 2, 3, 4)
# a => [1, 2, 3],  b => 4

(a, b*) = (1, 2, 3, 4)
# a => 1,  b => [2, 3, 4]
```

The `*` message inverts this — it splats a list's values back out into a positional tuple:

```gab
args = [1, 2, 3]
args*   # => (1, 2, 3)
```

Together they compose to forward all of a block's arguments, unchanged.

```gab
forward_all = (args*) => args*
```

This is how `and:` is implemented for `true:` in the core library — it simply returns all its arguments as-is.

### Dictionary binding with `**`

A `**` suffix collects a run of positional arguments and interprets them as **alternating keys and values**, constructing a record. Like `*`, it is positionally aware and can appear anywhere in the binding list:

```gab
(first, kwargs**, last) = (1, name: 'bob', age: 44, 99)
# first  => 1
# kwargs => { name: 'bob', age: 44 }
# last   => 99
```

The `**` operator on a record is the inverse — it splats a record's key-value pairs back out as a positional sequence of alternating keys and values:

```gab
{ a: 'b', c: 'd' } **   # => (a: 'b', c: 'd')
```

>[!NOTE]
>This message still works on list-like records. The keys will be the integer indices.

### Keyword-style apis

The `**` binding is what makes keyword-argument-style APIs possible in Gab. At the call site, you write alternating message keys and values as positional arguments:

```gab
MyType.some_api(positional, argument, flag: true:)
```

The definition collects those trailing arguments into a record with `**`:

```gab
some_api: .def (MyType, (positional, argument, kwargs**) => do
  # kwargs => { flag: true: }
  positional.println
  kwargs.at(flag:).println
end)
```

There are no keyword arguments in Gab — only positional ones. The record is constructed from the raw argument sequence by the `**` binding. This means you can place a `**` binding anywhere, not just at the end, and it will absorb whichever positional arguments fall to it.

## Tuples and multiple return values

Blocks may return multiple values using a tuple expression like we've seen before

```gab
(ok: file.read)     # Two-value tuple
(err: 'not found')  # Two-value tuple
```

Receiving multiple return values uses the same tuple syntax on the left side of an assignment:

```gab
(status, file) = IO.File.make('data.csv')
```

## Tuple forwarding in chains

When a message is chained after a call that returns multiple values, Gab forwards the entire tuple into the next send: the first value becomes the receiver, the rest become arguments.

```gab
IO.File.make('data.csv').then(file => file.read.println)
```

Is exactly equivalent to:

```gab
(status, file) = IO.File.make('data.csv')
status.then(() => file.read.println)
```

This allows the result of a multi-value return to be routed directly into a `defcase`-style dispatch without any intermediate binding.

## The `unwrap:` pattern

A common use of tuple forwarding is `unwrap:`, which either returns the result value or panics with the error:

```gab
unwrap: .defcase {
  ok:  result => result
  err: msg    => 'Unwrap failed: $'.panicf(msg)
}

file = IO.File.make('data.csv').unwrap
```

`IO.File.make` returns `(ok:, file)` or `(err:, message)`. The tuple is forwarded directly to `.unwrap`, which dispatches on the first element.
