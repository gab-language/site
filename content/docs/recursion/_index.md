+++
date = '2025-03-10T12:13:08-04:00'
draft = false
title = 'Recursion'
weight = 3
+++
Gab does not provide form of loop construct.
Instead, we use recursion and to perform the same work and rely on the cgab runtime to make it fast.
#### Investigation: reduce
To investigate this further, lets look at Gab's implementation of
a standard `reduce` function. In JS, it may look like this:
```javascript
function reduce(array, f, initial) {
    // Setup our mutating accumulator variable
    let acc = initial

    // Iterator our array for each index
    for (let i = 0; i < array.length; i++) {
        // Apply f to accumulator with current value
        acc = f(acc, array[initial])
    }

    return acc
}

sum = reduce([1 2 3 4], (acc, curr) => acc + cur, 0)
console.log(sum)
// => 10
```
To recreate this in gab:
```gab
# Our initial setup.
# Recursion often involves a light
# wrapper-function which initializes some state.
reduce: .def! (
    Records.t,
    (f, initial) => do
        # Begin iterating at 0th index
        i = 0
        # Dispatch to doreduce: depending on whether or not
        # we had 'i'
        self
            .has? i
            .doreduce(self, i, f, initial)
    end)

doreduce: .defcase! {
# If we had 'i', we:
#  - get the current value
#  - apply current value to accumulator via 'f'
#  - increment i to next index
#  - Dispatch to doreduce: depending on whether or not
#     we had 'next'
    true: (record, i, f, acc) => do
       curr = record.at! i
       acc  = f.(acc, curr)
       next = i + 1

       record
        .has? next
        .doreduce(record, next, f, acc)
    end

# If we didn't have 'i':
#  - our record is out of items and we can return 'acc'
    false: (record, i, f, acc) => acc
}

# Notice how we can pass the message '+:' directly, instead of
# an anonymous function which wraps it.
[1 2 3 4].reduce(+:, 0).println
# => 10

# The anonymous function still works of course.
[1 2 3 4].reduce((acc, cur) => acc + cur, 0).println
# => 10
```
The calls to `doreduce:` in `reduce:` and `doreduce:` itself are *tail calls*. 

> In computer science, a tail call is a special type of function call that occurs as the last operation in a function before it returns a result. Specifically, when a function calls another function as its final action (and does not need to perform any further work after that call), the call is considered a tail call.
>
> -- ChatGPT

In this context, cgab is able to optimize the calls to a special `MATCH_TAIL_SEND` op code.

#### A note on traditional recursion
In functional languages which rely on recursion (such as Elixir, for example) it is
common to implement recursive algorithms such as this by operating on the head of the list
and recursing over the tail. Something like [this](https://hexdocs.pm/elixir/recursion.html):
```elixir
# Directly from Elixir's introductory documentation
defmodule Math do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

IO.puts Math.sum_list([1, 2, 3], 0) #=> 6
```
In the above example the `[head | tail]` destructuring is implemented in one of two ways:
 - The array data structure is implemented with a *linked-list*. Popping the 
 head element off and continuing along the tail is a fast operation: But linked lists are slow
 because they don't store their elements contiguously in memory.
 - The array data structure is implemented with some sort of *immutable array*. This will store data contiguously which is great for your cpu cache, but
 will require copying a non-trivial amount of data on every `[head | tail]` operation, as well as allocating
 a new array for `tail`. 

Gab's approach is to recurse over incrementing indices instead of a shrinking tail. It is more verbose, but it is also more concious of whats happening under the hood.
Making N allocations in order to sum a list of size N is unnecessary.

> [!NOTE]
> This problem is not specific to Elixir at all, in fact it is a common pattern
> in a lot of functional languages. And it is equally possible to
> implement the reduce function in Gab's style. Gab just doesn't provide
> a more syntactically-pleasing alternative.
