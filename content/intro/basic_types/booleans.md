+++
date = '2025-02-07T16:06:29-05:00'
title = 'Booleans'
weight = 2
+++
Booleans are implemented with messages - they are not built-in keywords like in other languages!
```gab
true:
false:
```
There is no `if` in gab. Typically, a `defcase` is used instead:
```gab
my_message: .defcase! {
    true: (args) => do
        # Do something with args in the truthy case
    end
    false: (args) => do
        # Do something with args in the falsey case
    end
}

some_condition .my_message args
```
For simple use cases, there are messages `and:`, `or:`, `then:` and `else:` defined in the core library.
```gab
# Lifted from gab's core library.

truthy_values .defmodule! {
  and: (alt[]) => alt**
  or: _ => self

  then: f => f. self
  else: _ => self
}

falsey_values .defmodule! {
    and: _ => self
  or: (alt[]) => alt**

  then: _ => self
  else: f => f. self
}
```
The `and:` and `or:` messages do what you expect for the most part, except they *don't short circuit*. This means the value on the right is *always evaluated*.
```gab
true: .and 2  # 2
false: .and 2 # .false
false: .or 2  # 2
true: .or 2   # .true
```
The `then:` and `else:` messages **do** short circuit, by accepting *blocks* instead of values.
```gab
true: .then () => do
    # Do something in the truthy case
end
false: .else () => do
    # Do something in the falsey case
end
```
