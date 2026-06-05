### uri
```gab
[ uri\scheme:, uri\authority:, uri\path:, uri\query:, uri\fragment: ]
```

  A fully-parsed uri. See `scheme`, `authority`, `path`, `query`, and `fragment` for more details on these components.
  

### as\uri
```gab
string.as\uri: () :: (success (status ok:, value [ uri\scheme:, uri\authority:, uri\path:, uri\query:, uri\fragment: ]) | failure (status err:, message string))
```

  Parse a string as a URI.

  Returns an error if parsing fails. This can happen if the URI is poorly formed, or if percent-decoding fails.
  For details on percent-decoding, see `as\uri\encoded`.
  

### to\uri
```gab
uri.to\uri: () :: string
```

  Convert a uri into its string form. Performs percent-encoding on each component.
  
  Neither the uri conversion nor the percent-encoding can fail in this direction.
  

### to\uri\encoded
```gab
string.to\uri\encoded: () :: string
```

  URI-encodes the string.

  URI encoding is necessary as some characters are *reserved* in URIs, such as `/`, `@`, `:` and others, which carry structural meaning within a URI.
  
  Percent encoding allows these characters to appear in segments of a URI by including a `%` character, followed by a two-character hexadecimal corresponding to the
  ASCII value of the percent-encoded character. Here is a simple example:
  
  ```
  /path with spaces/a/b/c
  ```

  Spaces and other whitespace/control-characters must be encoded when they appear as data within a URI. The above URI will `uri\encode` as:

  ```
  /path%20with%20spaces/a/b/c
  ```

  The ` ` characters are replaced with the percent encoding `%20` (A `%`, followed by the ASCII value of a space, `20`).
  

### as\uri\encoded
```gab
string.as\uri\encoded: () :: (success (status ok:, value string) | failure (status err:, message string))
```

  URI-decodes a string.

  Will fail if an invalid percent-encoded value is encountered.

  An invalid percent-encoded value is defined as a `%` followed by two non-hexadecimal characters.

  ```gab
  '%20'.as\uri\encoded # :: (ok: ' ')
  '%zz'.as\uri\encoded # :: (err: 'Invalid hexadecimal value')
  ```

  The `z` character cannot represent a hexadecimal value (valid characters are 0-9, a-f, A-F).

  If there are fewer than two characters after the `%`, decoding will also fail.
  

### scheme
```gab
string
```

  A URI scheme. Common examples are `http` or `file`.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
  ^^^^^
  ```
  

### authority
```gab
[ uri\host:, uri\port:, uri\username:, uri\password: ]
```

  The authority portion of a URI can have up to four components:
  
  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
          ^^^^^^^^^^^^^^^^^^^
  ```

  uri\authority is a record containing any combination of these keys.
  See `host`, `port`, `username`, and `password`.
  

### path
```gab
List[string]
```

  A list of segments from the path portion of a URI.

  Each segment is separated by a '/' character.
  
  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
                              ^^^^^^^^^^^^^^^^^
  ```
  

### query
```gab
Dict[string, string]
```

  A record of the query parameters from the URI.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true&new=false#whatever
                                                ^^^^^^^^^^^^^^^^^^^
  ```

  This record will contain the key-value present in the URI. Both keys and values are strings.
  

### fragment
```gab
string
```

  A URI fragment.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true&new=false#whatever
                                                                    ^^^^^^^^
  ```
  

### host
```gab
string
```

  The host in the uri authority, if present.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
                 ^^^^^^^
  ```
  

### port
```gab
string
```

  The port in the uri authority, if present.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
                         ^^^^
  ```
  

### username
```gab
string
```

  The username in the uri authority, if present.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
          ^^
  ```
  

### password
```gab
string
```

  The password in the uri authority, if present.

  ```
  https://me:psk@abc.com:8080/path/to/somewhere?sort=true#whatever
             ^^^
  ```
  
