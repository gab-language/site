## file
```gab
Box[io\file]
```

  A native file handle.

  Implements the `streamable` protocol.
  

## make
```gab
io\file:.make: (path string, permissions string) => file file
```

  Create a file.
  

## len
```gab
file.len: () => int
```

  Returns the length of a file.
  
