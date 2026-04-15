## seqable
```gab
[ seq\init:, seq\next: ]
```

  The `seqable` protocol defines how a value can produce a lazy sequence of other values.

  To use the `seqable` protocol, begin by sending `seq\init`:

  ```gab
    (ok next values*) = ['1' '2' '3' '4'].seq\init
  ```

  *ok* will contain `ok:` or `none:`. This determines whether or not the sequence had an initial value.

  It follows that empty sequences return `none:` when `seq\init` is sent.

  Non-empty sequences will return `ok:`, followed by *next* (more on that later), followed by a run of values.

  The run of values can be any number of values. Records return `(value, key)`, so for the above example:

  ```gab
    ok     # => ok:
    next   # => 1
    values # => ['1', 0] (values collects the tuple into a list)
  ```

  The *next* value is a key which the user can pass to `seq\next:` to receive the *next* iteration in the sequence.

  This is what makes the sequence lazy - the user computes the next value only when they need it.

  ```gab
    (ok next values*) = ['1' '2' '3' '4'].seq\next 1

    ok     # => ok: 
    next   # => 2
    values # => ['2', 1]
  ```
  

## seq\init
```gab
seqable.seq\init: () => (next (status ok:, key unknown, values *unknown) | done none:)
```
Return the initial key and value which should begin the sequence.

## seq\next
```gab
seqable.seq\init: key unknown => (next (status ok:, key unknown, values *unknown) | done none:)
```
Given a key, return the next keys and values which would continue the sequence.
