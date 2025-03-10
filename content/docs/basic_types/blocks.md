+++
date = '2025-03-10T10:06:10-04:00'
draft = false
title = 'Blocks'
weight = 3
+++
Blocks are simply functions, as seen before. But there are some additional, useful tidbits to cover:
### Multiple return values
Blocks can return multiple values, similar to golang or lua.
Here, `open:` returns two values. One signals the status of the operation, and another providing value or an error.
```gab
IO.open('my_data.csv')
# => ok: <gab\box io\stream ...>
# => err: File does not exist
```
The group of values *passed to* and *return from* a block is called a **tuple**. They can be unpacked like this:
```gab
# Unpack the tuple here with parentheses ().
# This is called 'destructuring'
(status, stream) = IO.open('my_data.csv')

status.ok?.then () => do
    # Do something with stream here.
end

# Alternatively, we can unwrap our stream:
# This will crash if the first element in the tuple isn't ok:
stream = IO
    .open('my_data.csv')
    .unwrap!
```
Tuples are used heavily, and preferred to records wherever possible.
While records allocate memory, tuples use the stack and require *zero* allocation.
### Tuples
Now that we've been introduced to tuples, there are a few rules about them to learn.
```gab
# Messages are sent to the FIRST element of the tuple.
# Heres some funky syntax you *could* write:

(1 2) +
# => 3

(1 2) + 3
# Syntax error
```
When the left-hand side of a send is a tuple and the right-hand side is empty, Gab emits a send to the **whole** left-hand tuple.
When the right-hand side is **not** empty, Gab will emit an error.

This behavior means that you can forward the **whole** tuple returned by a block into another send, without any intermediate allocation.
In fact, this is how `unwrap!:` is implemented!
```gab
unwrap!: .defcase! {
    # If the receiver (first element of tuple) was ok:
    #   return the result
    ok:  (result) => result
    # If the receiver was err:
    #   panic!
    err: (err) => 'Unwrap Failed: $'.sprintf(err).panic!
}

# open: returns a tuple (ok: <gab\box io\stream ...>)
# This tuple is forwarded to .unwrap!
stream = IO
    .open('my_data.csv')
    .unwrap!
```
