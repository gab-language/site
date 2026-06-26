## binary
```gab
binary
```

  A sequence of bytes, with no encoding.
  

## len
```gab
binary.len: () :: int
```

  Return the length of the binary, in bytes.
  

## as\string
```gab
binary.as\string: () :: (success (status ok:, value string) | failure (status err:, message string))
```

  Try to convert the binary to string. This will fail if the binary isn't valid UTF-8.
  
  This is only attempted once - the result of conversion is cached.
  

## at
```gab
binary.at: (default int | stepped (index int, step int)) :: binary
```

  Return the byte at index. If step is supplied, then treat the binary as an array of 'step' size binaries, instead of an array of bytes. 
  
