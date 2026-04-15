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
  

## make
```gab
io\socket:.make: protocol (TCP tcp: | UDP udp: | TCP with TLS tcp\tls: | UDP with TLS udp\tls:) => socket socket
```

  Create a socket with the given protocol.
  

## accept
```gab
socket.accept: () => (success (status ok:, value socket) | failure (status err:, message string))
```

  Accept a client connection on a listening server socket.
  

## listen
```gab
socket.listen: max_connections int => (ok ok: | err err:)
```

  Begin listening for connections on a server socket.
  

## bind
```gab
socket.bind: (default (address string, port int) | tls (address string, port int, certificate binary, private_key binary)) => (success (status ok:, value nil:) | failure (status err:, message string))
```

  Bind a socket to a local address. This turns a socket into a server socket.
  

## connect
```gab
socket.connect: (default (address string, port int) | tls (address string, port int, certificate binary)) => (success (status ok:, value nil:) | failure (status err:, message string))
```

  Connect to an address. This turns a socket into a client socket.

  For ssl clients, Gab bundles a public mozilla client certificate chain, so the 'certificate'
  argument is optional.
  
