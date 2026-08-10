## shape
```gab
shape
```

  An immutable set of keys.
  

## len
```gab
shape.len: unknown :: int
```

  Return the numbers of keys in the shape.
  

## seq\init
```gab
seqable.seq\init: () :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Begin iterating the keys in the shape.

  See the seqable protocol for details.
  

## seq\next
```gab
seqable.seq\next: key unknown :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Continue iterating the keys in the shape.

  See the seqable protocol for details.
  
