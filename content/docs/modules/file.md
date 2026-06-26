## file
```gab
Box[io\file]
```

  A native file handle.
  

## make
```gab
io\file:.make: (path string, permissions string) :: file io\file
```

  Create a file.
  

## len
```gab
file.len: () :: int
```

  Returns the length of a file.
  

## stream\send
```gab
streamable.stream\send: bytes binary :: (success (status ok:, value nil:) | failure (status err:, message string))
```

  Write bytes to a file.

  See the streamable protocol for details.
  

## stream\recv
```gab
streamable.stream\recv: (n int | default nil:) :: (success (status ok:, value binary) | failure (status err:, message string))
```

  Read bytes from a file.

  If you omit 'amount', then will return whatever bytes are immediately available.

  Even for files on disk, `recv` with no `amount` isn't guaranteed to return the whole file.

  See the streamable protocol for details.
  
