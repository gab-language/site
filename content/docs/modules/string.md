## string
```gab
string
```

  A valid UTF-8 encoded sequence of bytes.
  

## is\blank
```gab
string.is\blank: () => boolean
```

  Returns `true:` if the string contains only blank characters. Returns `false:` otherwise.
  

## split
```gab
string.split: delimiter string => tokens *string
```

  Split the receiving string on the given delimitier.
  

## has\sub
```gab
string.has\sub: substring string => boolean
```

  Returns `true:` if the receiver contains the argument string. 
  

## has\ending
```gab
string.has\ending: substring string => boolean
```

  Returns `true:` if the receiver ends with the argument string.
  

## has\beginning
```gab
string.has\beginning: substring string => boolean
```

  Returns `true` if the receiver string begins with the argument string.
  

## to\message
```gab
string.to\message: () => message
```

  Convert a string into a message.
  

## to\binary
```gab
string.to\binary: () => binary
```

  Convert a string into a binary.
  

## as\number
```gab
string.as\number: () => (success (status ok:, value float) | failure (status err:, message nil:))
```

  Try to convert a string into a number. If successful, return `ok:` and the number. Otherwise, return `err:`.
  

## len
```gab
string.len: () => int
```

  Return the length of the string. This does not count the bytes of the string - it returns the number of graphemes.
  

## at
```gab
string.at: index int => (some (status ok:, value string) | none none:)
```

  Return `ok:` and the grapheme at the given index. If none exists, return `none:`.
  

## slice
```gab
string.slice: (begin (some (status ok:, value int) | none none:), end (some (status ok:, value int) | none none:)) => string
```

  Return a substring of graphemes at the given indices. Will panic if indices are out of bounds.
  

## pop
```gab
string.pop: () => (some (status ok:, value (rest string, last string)) | none none:)
```

  Similar behavior to `pop:` on the records.
  

## trim
```gab
string.trim: trimset string => string
```

  Trim graphemes from the front and back of the string if they are within the arg 'trimset'.
  
