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
  

## stmt\source
```gab
sourceable.>!: () :: (success (status ok:, value unknown) | error (status err:, message string) | none none:)
```

  Lazily produce the next row from the query.

  See the sourceable protocol.
  

## stmt\seq\init
```gab
seqable.seq\init: () :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Begin iterating the result rows of a query. Lazily produces rows as requested.

  Implemented using the sourceable protocol.

  See the seqable protocol.
  

## stmt\seq\next
```gab
seqable.seq\init: () :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Continue iterating the result rows of a query. Lazily produces rows as requested.

  Implemented using the sourceable protocol.

  See the seqable protocol.
  

## query
```gab
dbrow.query: string :: (success (status ok:, value *unknown) | failure (status err:, message string))
```

  Compile the input query (really, this can be any statement).

  Returns an error if compilation fails.
  

## eval
```gab
dbrow.eval: string :: (success ok: | failure (status err:, message string))
```

  Evaluate the sql string argument against the database `self`.

  Does this by creating a query and sending `collect` to it. Will panic if the query fails to create.
  
