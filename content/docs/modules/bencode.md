### to\bencode
```gab
unknown.to\bencode: () :: string
```

  Convert a value into a bencode string.
  

### as\bencode
```gab
string.as\bencode: () :: (success (status ok:, value unknown) | failure (status err:, message string))
```

  Try to parse a string as a bencode value.
  
