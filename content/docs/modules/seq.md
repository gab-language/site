## defseq
```gab
seqable.defseq: () :: ()
```

  Types that implement the `seqable` protocol may use `defseq` to implement a slew of useful messages.

  ```gab
  [my_type] .defmodule {
    seq\init: ...some_impl
    seq\next: ...some_impl
  }

  # Now send defseq to implement the useful messages
  my_type.defseq
  ```
  

## reduce
```gab
seqable.reduce: (initial unknown, f predicate\unknown: unknown :: unknown) :: unknown
```

  Eagerly consume the values in `seqable` and reduce applying `f`, starting with `initial`.

  ```gab
  nums := [ 1,2,3,4,5 ]

  sum := nums.reduce(0 (x y) :: x + y)
  ```
  

## transduce
```gab
seqable.transduce: (initial unknown, f predicate\unknown: unknown :: unknown, xf [ transduce\wrap:, transduce\step: ]) :: unknown
```

  Eagerly consume the values in `seqable` like `reduce`, but first wrap reducer `f` with transducer `xf`.

  ```gab
  nums := [ 1,2,3,4,5 ]

  sum := nums.transduce(0 (x y) :: x + y, Transducers.map(x :: x++))
  # 20 instead of 10
  ```
  

## each
```gab
seqable.each: f () :: () :: ()
```

  Eagerly consume the tuples in `seqable`, calling `f` with each tuple.

  ```gab
  nums := [ 1,2,3,4,5 ]

  nums.each(x :: x.println)
  # 1
  # 2
  # 3
  # 4
  # 5
  ```
  

## map
```gab
seqable.map: f unknown :: unknown :: List[unknown]
```

  See Transducers/map
  

## filter
```gab
seqable.filter: f unknown :: boolean :: List[unknown]
```

  See Transducers/filter
  

## mapfilter
```gab
seqable.filter: f unknown :: (should_include boolean, values unknown) :: List[unknown]
```

  See Transducers/mapfilter
  

## skip
```gab
seqable.skip: f unknown :: boolean :: List[unknown]
```

  See Transducers/skip
  

## every
```gab
seqable.every: f unknown :: boolean :: boolean
```

  Eagerly consumes all values in seq until `f` returns `false:`.

  Returns `true:` if `f` returned `true:` for all values in the seq, and `false:` otherwise.
  

## any
```gab
seqable.any: f unknown :: boolean :: boolean
```

  Eagerly consumes all values in seq until `f` returns `true:`.

  Returns `true:` if `f` returned `true:` for any value in the seq, and `false:` otherwise.
  

## join
```gab
seqable.join: (initial unknown, xf [ transduce\wrap:, transduce\step: ]) :: unknown
```

  Eagerly consumes all values in seq, appending them to `initial` with `+:`.

  ```gab
  words := [ 'hello' 'world,' 'my' 'name' 'is' 'Joe']
  
  message := words.join('')
  # 'helloworld,mynameisJoe'

  # Use transducers to interpose a space, making a nice looking sentence!
  message := words.join('', Transducers.interpose ' ')
  # 'hello world, my name is Joe'
  ```
  

## collect
```gab
seqable.collect: (initial unknown, xf [ transduce\wrap:, transduce\step: ]) :: unknown
```

  Eagerly consumes all values in seq, appending them to `initial` with `cons:`.

  ```gab
  word := 'helloworld'
  
  letters := word.collect [] 
  # ['h' 'e' 'l' 'l' 'o' 'w' 'o' 'r' 'l' 'd']
  ```
  

## zip
```gab
seqable.zip: (initial unknown, xf [ transduce\wrap:, transduce\step: ]) :: unknown
```

  Eagerly consumes all values in seq, appending them to `initial` with `put_via:`.

  ```gab
  ch := Channels.make

  Fibers.make () :: do
    ch <! (dog: red: 'clifford')
    ch <! (dog: blue: 'bluey')
    ch.close
  end

  animals := ch.zip {}
  # { dog: { red: 'clifford' blue: 'bluey } } 
  ```
  

## pipe
```gab
seqable.pipe: (initial unknown, xf [ transduce\wrap:, transduce\step: ]) :: unknown
```

  Eagerly consumes all values in seq, appending them to `initial` with `<!:`.

  ```gab
  nums := [ 1 2 3 4 5 ]
  
  # Put nums onto channel, but use a transducer to only bring the even ones across.
  nums.pipe(some_channel, Transducers.filter(x :: x.is\even))
  ```
  
