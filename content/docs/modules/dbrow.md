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
dbrow\stmt.>!: () :: (some (status ok:, value unknown) | none none:)
```

  Lazily produce the next row from the query.

  See the sourceable protocol.
  

## stmt\seq\init
```gab
dbrow\stmt.seq\init: () :: (some (status ok:, value unknown) | none none:)
```

  Begin iterating the result rows of a query. Lazily produces rows as requested.

  Implemented using the sourceable protocol.

  See the seqable protocol.
  

## stmt\seq\next
```gab
dbrow\stmt.seq\next: () :: (some (status ok:, value unknown) | none none:)
```

  Continue iterating the result rows of a query. Lazily produces rows as requested.

  Implemented using the sourceable protocol.

  See the seqable protocol.
  

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

  Does this by creating a query and sending `collect` to it. Will panic if the query fails to create.
  
