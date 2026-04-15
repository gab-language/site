## reduceable
```gab
[ reduce\step:, reduce\done: ]
```

  The `reduceable` protocol allows a value to serve as a reducing function.

  Send `reduce\step:` to a reduceable, with an accumulator and any values:

  ```gab
    (cmd r acc) = reduceable.reduce\step(acc, args)
  ```

  Reducers can terminate a sequence before the seqable runs out of values.
  This is determined by the cmd, which can be `next:` or `stop:`.

  The second return value `r` is a new reduceable to use for the next step of the sequence. This is because some reduceables are *stateful*, and need to change as values arrive over the sequence.

  For example, something like `drop:` needs to keep track of the number of values it has dropped.

  The third return value `acc` is the new value for the accumulator. This is standard for reducing.

  Once a reduceable is done (ie: the stream has returned `none:`), send `reduce\done:` in case the reduceable has any work it needs to do in order to finalize the accumulated value.

  In many cases, `reduce\done:` just forwards the accumulator as it received it.

  ```gab
    acc = reduceable.reduce\done acc
  ```

  With these two messages, it is possible to define a message which recursively process a seqable with a reduceable.

  In this example, `seq\i` and `seq\v` are used as naming conventions for the sequence's invariant and variant respectively.

  The *invariant* is the value which **doesn't** change over the course of iterating the sequence. This is typically the seqable itself.

  The *variant* is the value which **does** change over the course of iteration. This is the `key` as described in the `seqable` module.
  ```gab
    doreduce: .defcase {
      # The sequence continues
      ok: (seq\i, seq\v, acc, r, xs) => do
        # Apply the reducer
        (cmd, r, acc) = r.reduce\step(acc, xs*)
        # proceed to the next sep
        cmd.doreduce(seq\i, seq\v, acc, r)
      end

      # The sequence is done
      none: (seq\i, seq\v, acc, r) => do
        r.reduce\done(acc)
      end

      # The reducer continues
      next: (seq\i, seq\v, acc, r) => do
        # Apply the producer resolving new values for the next step
        (ok, seq\v, xs*) = seq\i .seq\next seq\v
        # Tailcall to the next step
        ok.doreduce(seq\i, seq\v, acc, r, xs)
      end

      # The reducer is done
      stop: (seq\i, seq\v, acc, r) => do
        r.reduce\done(acc)
      end
    }

    # Initialize the seq
    (ok, seq\v, xs*) = self.seq\init
    # Tail recursive algorithm with `doreduce:`
    ok.doreduce(self, seq\v, acc, r, xs)
  ```
  

## reduce\step
```gab
reduceable.reduce\step: (accumulator unknown, sequence_args *unknown) => (command next: | stop:, reducer reduceable, accumulator unknown)
```
Performs one step of reducing work.

## reduce\done
```gab
reduceable.reduce\done: accumulator unknown => accumulator unknown
```
Finish reducing work. Perform any final computation the reducer needs to do in order to produce a final accumulated value.
