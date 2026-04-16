---
title: Blocks
weight: 6
---

A block is a closure — a function that captures its surrounding scope. Blocks are values: they can be stored, passed as arguments, and called.

```gab
square = (x) => x * x
square.(4)   # => 16
```

Every block has an implicit `self` binding. When a block is used as a message specialization via `def:`, `self` refers to the value that received the message. When called directly, `self` refers to the block itself.

## Variadic Bindings

There are two kinds of variadic binding, distinguished by whether the collected arguments are treated as a list or as a record.

### `*` — list binding

A `*` suffix on a binding name collects a run of positional arguments into a list. Its position in the binding list determines which arguments it absorbs — the other bindings around it claim their arguments first, and `*` takes the rest:

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

The `*` operator inverts this — it splats a list's values back out into a positional tuple:

```gab
args = [1, 2, 3]
args*   # => (1, 2, 3)
```

Together they let a block forward all its arguments unchanged:

```gab
forward_all = (args*) => args*
```

This is how `and:` is implemented for `true:` in the core library — it simply returns all its arguments as-is.

### `**` — record binding

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

### Keyword-style APIs

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

## Tuples and Multiple Return Values

Blocks return multiple values using a tuple expression — parentheses containing two or more values:

```gab
(ok: file.read)     # Two-value tuple
(err: 'not found')  # Two-value tuple
```

Commas inside a tuple terminate the preceding message send and begin a new element. They are only required where omitting them would cause an expression to be parsed as an argument to the previous send:

```gab
(1 + 2 3)    # => (3, 3): 2 is the argument to +, 3 is the second element
(1 +, 2 3)   # => Runtime Error: + has no0 second argument, so gab tries to add 1 and nil:
(ok: result) # => There is no send here, so no commas are needed.
```

Receiving multiple return values uses the same tuple syntax on the left side of an assignment:

```gab
(status, file) = IO.File.make('data.csv')
```

## Tuple Forwarding in Chains

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

## The `unwrap:` Pattern

A common use of tuple forwarding is `unwrap:`, which either returns the result value or panics with the error:

```gab
unwrap: .defcase {
  ok:  result => result
  err: msg    => 'Unwrap failed: $'.panicf(msg)
}

file = IO.File.make('data.csv').unwrap
```

`IO.File.make` returns `(ok:, file)` or `(err:, message)`. The tuple is forwarded directly to `.unwrap`, which dispatches on the first element.
