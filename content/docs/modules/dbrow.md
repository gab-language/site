## dbrow
```gab
Box[db\row]
```

  A connection to a row-based database. This implementation wraps sqlite.
  

## stmt
```gab
Box[db\row\stmt]
```

  A compiled sql statement.

  Implements the seqable protocol.
  

## query
```gab
dbrow.query: string :: (success ok: | failure (status err:, message string))
```

  Compile the input query (really, this can be any statement).

  Returns an error if compilation fails.
  

## eval
```gab
dbrow.eval: string :: (success ok: | failure (status err:, message string))
```

  Evaluate the sql string argument against the database `self`.
  
