---
weight: 7
---

#

## `gab\fiber`

Fibers are created with `Fibers.make:`, which takes a block and immediately queues it for execution. The fiber may run on any OS thread managed by gab's runtime.

```gab
Fibers.make () :: do
  'Hello from a fiber!'.println
end
```

This returns a *fiber value*. When printed, you'll see something like:
```
<gab\fiber 0x7fed60004770 : <gab\block gab\main:1 1>>
```

This describes:
- The message sent, `:` (The empty message)
- The receiver, a `gab\block`

You can spawn fibers which send any message to any value, and you can also add arguments!

```gab
Fibers.make (1 +: 1) .await
# ok: 2
```

>[!NOTE]
>Instead of just return `2`, the `await:` message returns a tuple.
>The first result is a status value, which will be `err:` if the fiber panicked.
