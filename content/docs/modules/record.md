## record
```gab
record
```

  An immutable set of key,value pairs. This is the core datastructure of the language.

  In addition to the builtin messages defined in this module, records also respond to their *keys* as messages.
  

## len
```gab
record.len: () => int
```

  Return the number of key-value pairs in the record.

  ```gab
  [1 2 3].len # => 3
  ```
  

## at
```gab
record.at: unknown => (some (status ok:, value unknown) | none none:)
```

  Check for a value at the given key. 

  Returns a tuple with the result of the check, and the value if it was found.
  ```gab
  (ok value) = { name: 'John Doe' } .at (name:)

  ok    # => ok:
  value # => 'John Doe'

  (ok value) = { name: 'John Doe' } .at (age:)

  ok    # => none:
  value # => nil:
  ```
  

## put
```gab
record.put: (key unknown, value unknown) => record
```

  Return a new record with the additional key-value pair, or an updated value for an existing key.

  ```gab
  person = { name: 'John Doe' }

  person = person.put(age: 30)

  person.name # => 'John Doe'
  person.age  # => 30
  ```
  

## put_via
```gab
record.put_via: (key_path *unknown, value unknown) => record
```

  Traverse nested records with the given `key_path`, eventually performing a final put.

  ```gab
  person = {
    mother: = {
      name: 'Jane Doe' 
    }
  }

  person = person.put_via(mother: age: 60)

  person.mother.age # => 60
  ```

  This message will create records along the path where none exist.

  ```gab
  {}.put_via(mother: sister: daugher: relation: 'cousin')

  # => { mother: { sister: { daughter: { relation: 'cousin' } } } }
  ```
  

## at_via
```gab
record.at_via: key_path *unknown => (some (status ok:, value unknown) | none none:)
```

  Get a value by traversing nested maps with the given `key_path`.
  If any key along the path is missing, returns `none:`

  ```gab
  (ok, value) = record.at_via(a: long: run: of: keys:)
  ```
  

## put_by
```gab
record.put_by: (key unknown, f is\block:) => record
```

  Apply a function to the value at key, returning a new record with the returned value from that function at key.

  ```gab
  person = { age: 30 }

  person = person.put_by(age: age => age + 1)

  person.age # => 30
  ```

  If the key does not exist in the record, then the argument to the block will be `nil:`.
  

## put_via_by
```gab
record.put_via_by: (key_path *unknown, f is\block:) => record
```

  Apply a function to the value at `key_path`, returning a new record with the returned value from that function at key_path.

  Combines the behavior of `put_via:` and `put_by:`.
  

## push
```gab
record.push: unknown => record
```

  Return a new record with the given value at the *end* of the record. The key will be the length of the record *before* inserting.

  ```gab
  arr = [1 2 3] .push 4

  arr # => [1 2 3 4]
  ```
  

## pop
```gab
record.pop: () => (some (status ok:, value (record record, popped_value unknown, popped_key unknown)) | none none:)
```

  Return a new record without the *last* key-value pair in the record.

  ```gab

  (ok rec val key) = [1 2 3 4].pop

  ok  # => ok:
  rec # => [1 2 3]
  val # => 4
  key # => 3
  ```

  If the record was empty, returns `none:` and an empty record.
  ```gab
  [].pop # => none: []
  ```
  

## is\record
```gab
unknown.is\record: () => boolean
```

  Returns `true:` if the receiver is a record, and `false:` otherwise.
  

## keys
```gab
record.keys: () => List[unknown]
```

  Return a list of all the keys in the record, in order.
  

## vals
```gab
record.vals: () => List[unknown]
```

  Return a list of all the values in the record, in order.
  

## 
```gab
record.: unknown => unknown
```

  Return the value at the key given by the argument. If the key doesn't exist, panic.

  ```gab
  map = { 'id' 1234 }

  map.('id') # => 1234

  map.('name') # => panic
  ```

  This allows for records to serve as functions of their keys.
  
