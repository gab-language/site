### dbrow
```gab
Box[dbow]
```

  A connection to a row-based database. This implementation wraps sqlite.
  

### eval
```gab
dbrow.eval: string :: (success ok: | failure (status err:, message string))
```

  Evaluate the sql string argument against the database `self`.
  
