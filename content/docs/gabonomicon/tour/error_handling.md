---
title: Error Handling
weight: 5
---

Gab does not have exceptions. There is no `try/catch`, no `throw`, and no stack unwinding. Instead, operations that can fail **return their errors as values**. You handle errors the same way you handle any other result: by sending messages.

## Errors as Return Values

A message that can fail returns multiple values. The first is a status — either `ok:` or `err:` — and the second is either the result or an explanation of what went wrong.

```gab
(status, file) = IO.File.make('my_file.txt')
```

If the file is opened successfully, `status` is `ok:` and `file` is a `gab\box IO.File` you can read from or write to.

If something went wrong — the file doesn't exist, permissions are denied — `status` is `err:` and `file` is a string describing the error.

## Handling the Result

Because `ok:` and `err:` are just values, you handle them with messages. The verbose approach binds each return value and branches explicitly:

```gab
(status, file) = IO.File.make('my_file.txt')

status
  .then(() => file.read.println)
  .else(() => 'Failed to open file: $!'.sprintf(file).println)
```

But recall how message chaining works with multiple return values: when you chain a message after a call that returns multiple values, the first return value becomes the receiver and the rest become arguments. This means you can write the same thing as a single chain:

```gab
IO.File.make('my_file.txt')
  .then((file) => file.read.println)
  .else((msg)  => 'Failed to open file: $!'.sprintf(msg).println)
```

`ok:` and `err:` respond differently to `then:` and `else:` — `ok:` calls its `then:` block and passes the file through; `err:` calls its `else:` block and passes the error message through. The branching is built into the types, not into special syntax.

This is the same branching mechanism used everywhere in Gab. There is no special syntax for error handling — the language stays consistent.

## Why Not Exceptions?

Exceptions make control flow invisible. An exception thrown inside a deeply nested call can unwind the entire stack, landing in a `catch` block far removed from where the problem occurred. This makes programs harder to reason about, and harder to write reliable concurrent code with.

Returning errors as values keeps the failure path explicit. When a message can fail, its type signature says so. You can't accidentally ignore the error and proceed as if everything succeeded — the status value is right there in the binding.

This approach is familiar if you've used Go, Rust's `Result` type, or Erlang's `{:ok, value} | {:error, reason}` convention. Gab follows the same discipline.

## Propagating Errors

If you want to pass an error up to the caller, return a tuple:

```gab
read_config: .def (gab\string, () => do
  IO.File.make(self)
    .then((file) => (ok: file.read))
    .else((msg)  => (err: 'Could not open config: $!'.sprintf(msg)))
end)
```

No comma is needed between `ok:` and `file.read` — a message literal like `ok:` doesn't consume the next expression as an argument, so the parser correctly treats `file.read` as the second tuple element. The caller receives `ok:` and the file contents, or `err:` and an error string — and can chain or bind those values however it likes.
