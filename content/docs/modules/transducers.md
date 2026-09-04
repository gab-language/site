## map
```gab
transducer:.map: f unknown :: unknown :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which maps tuples from `(x) => (y)` via `f`.

  ```gab
  nums := [ 1,2,3,4 ]

  # Calling your transducer 'xf', short for 'transformer' is a common convention.
  # Create a transducer which transforms the values it sees by squaring them.
  xf   := Transducers.map(x :: x * x)

  squared_nums := nums.collect(xf)
  ```
  

## filter
```gab
transducer:.filter: f unknown :: boolean :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which filters values via the predicate `f`.

  ```gab
  nums := [ 1,2,3,4 ]

  # Create a transducer which filters out the odd numbers
  xf   := Transducers.filter(x :: x.is\even)

  even_nums := nums.collect(xf)
  ```
  

## mapfilter
```gab
transducer:.mapfilter: f unknown :: predicate\boolean: unknown :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which both maps *and* filters values by the block `f`.

  ```gab
  nums := [ 1,2,3,4 ]

  # Create a transducer which filters out the odd numbers, and squares the remaining ones.
  xf   := Transducers.mapfilter(x :: (x.is\even, x * x))

  squared_even_nums := nums.collect(xf)

  # This could also be accomplished by composing the map and filter transducers:
  xf   := Transducers.filter(x :: x.is\even)
          |> Transducers.map(x :: x * x)

  squared_even_nums := nums.collect(xf)
  ```
  

## reduce
```gab
transducer:.reduce: (initial unknown, f unknown :: predicate\boolean: unknown) :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which yields each accumulator value as it applies the reducing block `f`

  ```gab
  nums := [ 1,2,3,4 ]

  # Create a transducer which accumulates values into a list.
  # Each intermediate value is passed through.
  xf   := Transducers.reduce([], (list, x) :: list.cons x)

  lists := nums.collect(xf)
  # [ [1], [1, 2], [1, 2, 3], [1, 2, 3, 4] ]
  ```
  

## transduce
```gab
transducer:.transduce: (initial unknown, f unknown :: predicate\boolean: unknown, xf [ transduce\wrap:, transduce\step: ]) :: transducer [ transduce\wrap:, transduce\step: ]
```

  Like reduce, except it accepts a transducer *and* a reducer, and first wraps the reducer with the transducer.

  ```gab
  nums := [ 1,2,3,4 ]

  # Create a transducer which accumulates values into a list.
  # Each intermediate value is passed through.
  xf   := Transducers.transduce([], (list, x) :: list.cons x, Transducers.map(square))

  lists := nums.collect(xf)
  # [ [1], [1, 4], [1, 4, 9], [1, 4, 9, 16] ]
  ```
  

## deduce
```gab
transducer:.deduce: (initial unknown, f unknown :: predicate\boolean: unknown) :: transducer [ transduce\wrap:, transduce\step: ]
```

  A more interesting version of reduce. Explanation TBD.
  

## tap
```gab
transducer:.tap: f unknown :: predicate\boolean: unknown :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which applies a side-effect to each value.

  ```gab
  nums := [ 1,2,3,4 ]

  xf   := Transducers.tap(num :: num.println)

  same_nums := nums.collect([] xf)
  # 1
  # 2
  # 3
  # 4
  ```
  

## skip
```gab
transducer:.skip: f unknown :: () :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which skips values based on the predicate `f`. Consider `skip` the inverse of `filter`.

  ```gab
  nums := [ 1,2,3,4 ]

  xf   := Transducers.skip(num :: num.is\even)

  odd_nums := nums.collect([] xf)
  ```
  

## take
```gab
transducer:.take: n int :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which accepts up to `n` values.

  ```gab
  nums := [ 1,2,3,4,5 ]

  xf   := Transducers.take 2

  two_nums := nums.collect([] xf)
  # [1, 2]
  ```
  

## drop
```gab
transducer:.drop: n int :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which ignores up to `n` values, then accepts the rest.

  ```gab
  nums := [ 1,2,3,4,5 ]

  xf   := Transducers.drop 2

  three_nums := nums.collect([] xf)
  # [3, 4, 5]
  ```
  

## take_while
```gab
transducer:.take_while: f unknown :: boolean :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which accepts values while `f` returns `true:` - then ignores the rest.

  ```gab
  nums := [ 1,2,3,4,5 ]

  xf   := Transducers.take_while(x :: x <= 2)

  two_nums := nums.collect([] xf)
  # [1, 2]
  ```
  

## take_until
```gab
transducer:.take_until: f unknown :: boolean :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which accepts values until `f` returns `true:` - then ignores the rest.

  ```gab
  nums := [ 1,2,3,4,5 ]

  xf   := Transducers.take_until(x :: x == 3)

  two_nums := nums.collect([] xf)
  # [1, 2]
  ```
  

## drop_while
```gab
transducer:.drop_while: f unknown :: boolean :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which ignores values while `f` returns `true:` - then accepts the rest.

  ```gab
  nums := [ 1,2,3,4,5 ]

  xf   := Transducers.drop_while(x :: x < 3)

  three_nums := nums.collect([] xf)
  # [3, 4, 5]
  ```
  

## count
```gab
transducer:.count: () :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which appends the number of seen values so far to the tuple

  ```gab
  nums := [ 1,2,3 ]

  xf   := Transducers.count |> Transducers.map((x idx) :: [x idx])

  two_nums := nums.collect([] xf)
  # [ [1, 0] [2, 1] [3, 2] ]
  ```
  

## interpose
```gab
transducer:.interpose: () :: transducer [ transduce\wrap:, transduce\step: ]
```

  Create a transducer which inserts a separator between each value it sees.

  ```gab
  nums := [ 1,2,3 ]

  xf   := Transducers.interpose 'hello!'

  three_nums := nums.collect([] xf)
  # [ 1 'hello!' 2 'hello!' 3 ]
  ```
  
