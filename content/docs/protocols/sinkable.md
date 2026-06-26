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
  
