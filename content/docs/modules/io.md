## file
```gab
Box[io\file]
```

  A native file handle.
  

## file\make
```gab
io\file.make: (path string, permissions string) :: file io\file
```

  Create a file.
  

## file\len
```gab
io\file.len: () :: int
```

  Returns the length of a file.
  

## file\stream\send
```gab
streamable.stream\send: bytes binary :: (success (status ok:, value nil:) | failure (status err:, message string))
```

  Write bytes to a file.

  See the streamable protocol for details.
  

## file\stream\recv
```gab
streamable.stream\recv: (n int | default nil:) :: (success (status ok:, value binary) | failure (status err:, message string))
```

  Read bytes from a file.

  If you omit 'amount', then will return whatever bytes are immediately available.

  Even for files on disk, `recv` with no `amount` isn't guaranteed to return the whole file.

  See the streamable protocol for details.
  

## file\sourceable\source
```gab
sourceable.>!: () :: (success (status ok:, value unknown) | error (status err:, message string) | none none:)
```

  Files implement the `sourceable` protocol.

  They yield each byte of the file sequentially using `stream\recv`.

  See the sourceable protocol for details.
  

## file\sinkable\sink
```gab
sinkable.<!: datum unknown :: (success (status ok:, value unknown) | error (status err:, message string))
```

  Files implement the `sinkable` protocol.

  The first argument is converted to a binary, and then written
  to the file with `stream\send`.

  See the sinkable protocol for details.
  

## file\seqable\seq\init
```gab
seqable.seq\init: () :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Files implement the `seqable` protocol.

  This is implemented using the `seqable` protocol, like so:

  ```gab
    [Io.Files.t] .defmodule {
      seq\init: _ :: do
        (ok, xs*) := self >!
        (ok, nil:, xs*)
      end
    }
  ```

  See the seqable protocol for details.
  

## file\seqable\seq\next
```gab
seqable.seq\next: key unknown :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Files implement the `seqable` protocol.

  This is implemented using the `seqable` protocol, like so:

  ```gab
    [Io.Files.t] .defmodule {
      seq\next: _ :: do
        (ok, xs*) := self >!
        (ok, nil:, xs*)
      end
    }
  ```

  See the seqable protocol for details.
  

## socket
```gab
Box[io\socket]
```

  A native socket handle.

  Implements the `streamable` protocol.

  When creating a socket, the user must choose a `protocol`. The options are:
  - `tcp:`
  - `udp:`
  - `tcp\tls:`
  - `udp\tls:`

  The latter two include transport-layer-security. Sockets with and without `tls:` require different
  arguments to messages such as `connect:` or `bind:`. See their definitions for details.
  

## socket\make
```gab
io\socket.make: protocol (TCP tcp: | UDP udp: | TCP with TLS tcp\tls: | UDP with TLS udp\tls:) :: socket io\socket
```

  Create a socket with the given protocol.
  

## socket\accept
```gab
io\socket.accept: () :: (success (status ok:, value io\socket) | failure (status err:, message string))
```

  Accept a client connection on a listening server socket.
  

## socket\listen
```gab
io\socket.listen: max_connections int :: (ok ok: | err err:)
```

  Begin listening for connections on a server socket.
  

## socket\bind
```gab
io\socket.bind: (default (address string, port int) | tls (address string, port int, certificate binary, private_key binary)) :: (success (status ok:, value nil:) | failure (status err:, message string))
```

  Bind a socket to a local address. This turns a socket into a server socket.
  

## socket\connect
```gab
io\socket.connect: (default (address string, port int) | tls (address string, port int, certificate binary)) :: (success (status ok:, value nil:) | failure (status err:, message string))
```

  Connect to an address. This turns a socket into a client socket.

  For ssl clients, Gab bundles a public mozilla client certificate chain, so the 'certificate'
  argument is optional.
  

## socket\stream\send
```gab
streamable.stream\send: bytes binary :: (success (status ok:, value nil:) | failure (status err:, message string))
```

  Write bytes to a socket.

  This is part of the `streamable` protocool.
  

## socket\stream\recv
```gab
streamable.stream\recv: (n int | default nil:) :: (success (status ok:, value binary) | failure (status err:, message string))
```

  Read 'amount' bytes from a socket.

  If you omit 'amount', then will return whatever bytes are immediately available.

  This is part of the `streamable` protocool.
  

## socket\sourceable\source
```gab
sourceable.>!: () :: (success (status ok:, value unknown) | error (status err:, message string) | none none:)
```

  Sockets implement the `sourceable` protocol.

  They yield each byte of the socket sequentially using `stream\recv`.

  See the sourceable protocol for details.
  

## socket\sinkable\sink
```gab
sinkable.<!: datum unknown :: (success (status ok:, value unknown) | error (status err:, message string))
```

  Sockets implement the `sinkable` protocol.

  The first argument is converted to a binary, and then written
  to the socket with `stream\send`.

  See the sinkable protocol for details.
  

## socket\seqable\seq\init
```gab
seqable.seq\init: () :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Sockets implement the `seqable` protocol.

  This is implemented using the `seqable` protocol, like so:

  ```gab
    [Io.Sockets.t] .defmodule {
      seq\init: _ :: do
        (ok, xs*) := self >!
        (ok, nil:, xs*)
      end
    }
  ```

  See the seqable protocol for details.
  

## socket\seqable\seq\next
```gab
seqable.seq\next: key unknown :: (next (status ok:, key unknown, values *unknown) | done none:)
```

  Sockets implement the `seqable` protocol.

  This is implemented using the `seqable` protocol, like so:

  ```gab
    [Io.Sockets.t] .defmodule {
      seq\next: _ :: do
        (ok, xs*) := self >!
        (ok, nil:, xs*)
      end
    }
  ```

  See the seqable protocol for details.
  
