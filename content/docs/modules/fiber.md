## fiber
```gab
fiber
```

  Fibers execute gab code.
  

## await
```gab
fiber.await: () => ()
```

  Blocks the running fiber while self is not done.

  Returns the result of self.
  

## is\done
```gab
fiber.is\done: () => boolean
```

  Returns `true:` if self has completed execution.
  
