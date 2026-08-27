## atom
```gab
Channel[predicate\unknown]
```

  An atom is simply a channel. It holds values over time.
  

## make
```gab
atom.make: () :: atom
```
Create an atom

## atom\deref
```gab
atom.atom\deref: () :: unknown
```

  Retrieve the value in the atom.
  

## atom\swap
```gab
atom.atom\swap: unknown :: unknown :: unknown
```

  Atomically update the value in the atom with an update-block.
  

## atom\reset
```gab
atom.atom\reset: () :: ()
```

  Atomically reset the value in the atom to a given value.
  
