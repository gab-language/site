## transduceable
```gab
[ transduce\wrap:, transduce\step: ]
```

  The `transduceable` protocol defines how a value serves as a *transducer*.

  *Reduce* means *to lead back*.
  Think of a reducer as a function which *leads* a sequence of values back towards a single value.

  *Transduce* is an invented word (by Rich Hickey afaik), and the root *trans* means *across*,
  changing the meaning of the word to *to bring across*. Think of a transducer as leading a
  sequence of values *across* or *through* some transformation.

  Therefore, a transducer's job is to *wrap* a reducer, and manipulate the values passed *through*
  to the reducer, without it ever having to know.

  The fundamental utility of a transducer is that it defines *when a reducing function is called*.

  For example, the `filter:` transducer ensures that the reducing function is only called when
  values meet a certain condition.

  To accomplish this, a transduceable must implement two messages, `wrap` and `step`.

  `transduce\wrap:` wraps the argument *reducing function* with the `self` transducer.

  This gives the transducer somewhere to *send* the values it brings across.

  In order to transduce values, the transducer should implement `transduce\step:`.

  This is conceptually similar to `reduce\step:` for the `reduceable:` protocol, but has a different signature.

  In addition to receiving an accumulator and tuple of values from the sequence, `transduce\step:` receives
  a *reduceable* and a *state* argument as well.
  

## transduce\wrap
```gab
transduceable.transduce\wrap: reducer reduceable: => reduceable:
```

  Wrap a `reduceable` with some behavior, returning a new `reduceable`.
  

## transduce\step
```gab
transduceable.transduce\step: (reducer reduceable:, accumulator unknown, sequence List[unknown], state unknown) => (state unknown, command next: | stop:, reducer reduceable:, accumulator unknown)
```

  Step the transducer. This may call the wrapped `reduceable` any number of times per step.
  
