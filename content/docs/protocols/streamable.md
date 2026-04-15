## streamable
```gab
[ stream\send:, stream\recv: ]
```

  The `streamable` protocol defines an interface for a value to stream bytes in or out as a **side effect**.

  A file handle or socket connection are examples of devices which could serve as `streamable`.
  

## stream\send
```gab
streamable.stream\send: bytes binary => (success (status ok:, value nil:) | failure (status err:, message string))
```

  Send the binary argument through the device. This API is synchronous (IE, the operation is guranteed to be completed when this message returns.)

  Returns `ok:` on success, or `err:` if an error occurred.
  

## stream\recv
```gab
streamable.stream\recv: (n int | default nil:) => (success (status ok:, value binary) | failure (status err:, message string))
```

  When `arg` is not `nil:`, perform a blocking wait for `arg` bytes on the device, and return them. Otherwise, don't block and return as many bytes as are available.
  
