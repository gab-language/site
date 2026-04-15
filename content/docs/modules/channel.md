## channel
```gab
Channel[predicate\unknown]
```

  Channels allow data to be shared between fibers.
  

## close
```gab
channel.close: () => ()
```

  Close a channel. Any fibers waiting to receive from this channel will receive `none:`.
  

## is\closed
```gab
channel.is\closed: () => boolean
```

  Return `true:` if a channel is closed, and `false:` otherwise.

  Keep in mind that a channel may be closed by another fiber at any time - 
  so the return value of this message may change unexpectedly.
  

## is\full
```gab
channel.is\full: () => boolean
```

  Return `true:` if a channel is occupied by a value, and `false:` otherwise.

  Keep in mind that a channel may be closed by another fiber at any time - 
  so the return value of this message may change unexpectedly.
  

## is\empty
```gab
channel.is\empty: () => boolean
```

  Return `true:` if a channel is *not* occupied by a value, and `false:` otherwise.

  Keep in mind that a channel may be closed by another fiber at any time - 
  so the return value of this message may change unexpectedly.
  

## <!
```gab
channel.<!: value unknown => ()
```

  Send a value into self. This is always a synchronization point - the sending
  fiber *will not progress* until the value has been **received** by another fiber.

  In the case that the channel is closed before a receiver arrives, this message
  does nothing.
  

## >!
```gab
channel.>!: value unknown => (some (status ok:, value unknown) | none none:)
```

  Receive a value from self. This is always a synchronization point - the receiving
  fiber *will not progress* until it has taken a value from another **sending** fiber.

  In the case that the channel is closed while waiting for a sending fiber, this message
  returns `none:`.
  
