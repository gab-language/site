### to\http
```gab
http\response | http\request.as\http: () :: binary
```

  Construct a binary http request or response. `gab/binary` is the chosen type because the body of a request/response can be an arbitrary encoding, not strictly utf8.
  

### as\http
```gab
binary.as\http: () :: (success (status ok:, value http\request | http\response) | failure (status err:, message nil:))
```

  Attempt to parse a binary as an HTTP request *or* response.

  Implemented for binaries, because a request or response body *may not be* valid utf8.
  

### to\http\code
```gab
http\status.to\http\code: () :: int
```

  Return the integer status code corresponding to `self`.
  

### to\http\status
```gab
http\status.to\http\status: () :: string
```

  Return the string representation of the status.
  

### request
```gab
[ http\method:, http\endpoint:, http\headers:, http\body: ]
```

  An HTTP request. See `as\http`, as well as `method`, `endpoint`, `headers`, and `body`.
  

### response
```gab
[ http\status:, http\headers:, http\body: ]
```

  An HTTP request. See `status`, `headers`, and `body`.
  

### status
```gab
http\CONTINUE: | http\SWITCHING_PROTOCOLS: | http\PROCESSING: | http\EARLY_HINTS: | http\RESPONSE_IS_STALE: | http\REVALIDATION_FAILED: | http\DISCONNECTED_OPERATION: | http\HEURISTIC_EXPIRATION: | http\MISCELLANEOUS_WARNING: | http\OK: | http\CREATED: | http\ACCEPTED: | http\NON_AUTHORITATIVE_INFORMATION: | http\NO_CONTENT: | http\RESET_CONTENT: | http\PARTIAL_CONTENT: | http\MULTI_STATUS: | http\ALREADY_REPORTED: | http\TRANSFORMATION_APPLIED: | http\IM_USED: | http\MISCELLANEOUS_PERSISTENT_WARNING: | http\MULTIPLE_CHOICES: | http\MOVED_PERMANENTLY: | http\FOUND: | http\SEE_OTHER: | http\NOT_MODIFIED: | http\USE_PROXY: | http\SWITCH_PROXY: | http\TEMPORARY_REDIRECT: | http\PERMANENT_REDIRECT: | http\BAD_REQUEST: | http\UNAUTHORIZED: | http\PAYMENT_REQUIRED: | http\FORBIDDEN: | http\NOT_FOUND: | http\METHOD_NOT_ALLOWED: | http\NOT_ACCEPTABLE: | http\PROXY_AUTHENTICATION_REQUIRED: | http\REQUEST_TIMEOUT: | http\CONFLICT: | http\GONE: | http\LENGTH_REQUIRED: | http\PRECONDITION_FAILED: | http\PAYLOAD_TOO_LARGE: | http\URI_TOO_LONG: | http\UNSUPPORTED_MEDIA_TYPE: | http\RANGE_NOT_SATISFIABLE: | http\EXPECTATION_FAILED: | http\IM_A_TEAPOT: | http\PAGE_EXPIRED: | http\ENHANCE_YOUR_CALM: | http\MISDIRECTED_REQUEST: | http\UNPROCESSABLE_ENTITY: | http\LOCKED: | http\FAILED_DEPENDENCY: | http\TOO_EARLY: | http\UPGRADE_REQUIRED: | http\PRECONDITION_REQUIRED: | http\TOO_MANY_REQUESTS: | http\REQUEST_HEADER_FIELDS_TOO_LARGE_UNOFFICIAL: | http\REQUEST_HEADER_FIELDS_TOO_LARGE: | http\LOGIN_TIMEOUT: | http\NO_RESPONSE: | http\RETRY_WITH: | http\BLOCKED_BY_PARENTAL_CONTROL: | http\UNAVAILABLE_FOR_LEGAL_REASONS: | http\CLIENT_CLOSED_LOAD_BALANCED_REQUEST: | http\INVALID_X_FORWARDED_FOR: | http\REQUEST_HEADER_TOO_LARGE: | http\SSL_CERTIFICATE_ERROR: | http\SSL_CERTIFICATE_REQUIRED: | http\HTTP_REQUEST_SENT_TO_HTTPS_PORT: | http\INVALID_TOKEN: | http\CLIENT_CLOSED_REQUEST: | http\INTERNAL_SERVER_ERROR: | http\NOT_IMPLEMENTED: | http\BAD_GATEWAY: | http\SERVICE_UNAVAILABLE: | http\GATEWAY_TIMEOUT: | http\HTTP_VERSION_NOT_SUPPORTED: | http\VARIANT_ALSO_NEGOTIATES: | http\INSUFFICIENT_STORAGE: | http\LOOP_DETECTED: | http\BANDWIDTH_LIMIT_EXCEEDED: | http\NOT_EXTENDED: | http\NETWORK_AUTHENTICATION_REQUIRED: | http\WEB_SERVER_UNKNOWN_ERROR: | http\WEB_SERVER_IS_DOWN: | http\CONNECTION_TIMEOUT: | http\ORIGIN_IS_UNREACHABLE: | http\TIMEOUT_OCCURED: | http\SSL_HANDSHAKE_FAILED: | http\INVALID_SSL_CERTIFICATE: | http\RAILGUN_ERROR: | http\SITE_IS_OVERLOADED: | http\SITE_IS_FROZEN: | http\IDENTITY_PROVIDER_AUTHENTICATION_ERROR: | http\NETWORK_READ_TIMEOUT: | http\NETWORK_CONNECT_TIMEOUT:
```

  An HTTP status code. These are defined as `http\<HTTP STATUS>`.
  
  ```gab
  http\OK:        # The '200 OK' status.
  http\NOT_FOUND: # The '404 NOT FOUND' status.
  ```
  

### method
```gab
DELETE: | GET: | HEAD: | POST: | PUT: | CONNECT: | OPTIONS: | TRACE: | COPY: | LOCK: | MKCOL: | PROPFIND: | PROPPATCH: | SEARCH: | UNLOCK: | BIND: | REBIND: | ACL: | REPORT: | MKACTIVITY: | CHECKOUT: | MERGE: | MSEARCH: | NOTIFY: | SUBSCRIBE: | UNSUBSCRIBE: | PATCH: | PURGE: | MKCALENDAR: | LINK: | UNLINK: | SOURCE: | PRI: | DESCRIBE: | ANNOUNCE: | SETUP: | PLAY: | PAUSE: | TEARDOWN: | GET_PARAMETER: | SET_PARAMETER: | REDIRECT: | RECORD: | FLUSH: | QUERY:
```

  An HTTP method, as a message.
  

### endpoint
```gab
string
```

  An HTTP path.
  

### headers
```gab
Dict[string, string]
```

  A record of HTTP header -> value.

  HTTP headers must contain only ASCII characters. For this reason, we choose the string type over binary.
  

### body
```gab
binary
```

  The body of an HTTP request or response. Opaque bytes.
  
