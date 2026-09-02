## sinkable
```gab
[ <!: ]
```

  The `sinkable` protocol defines how a value should consume other values.

  Typically, sinks perform some side-effect with each value.
  
  Here is an example implementation of `sinkable` for files.

  ```gab
    <!: .def (Files.t, (line) => self.stream\send(line + '\n'))
  ```
  

## sink
```gab
sinkable.<!: datum unknown :: (success (status ok:, value unknown) | error (status err:, message string))
```

  Perform some side-effecting action to consume a datum.
  
  Since a side-effect is performed (which may fail or present no data), this message returns a result.
  
