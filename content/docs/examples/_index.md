---
title: Examples
weight: 4
---

The best way to understand a language is to read programs written in it. This section collects complete, working Gab programs — not contrived syntax demonstrations, but useful things you might actually build.

Each example is chosen to show how Gab's core features compose under real constraints. The language tour explains the pieces; these examples show what happens when you put them together.

## What you'll find here

**[Key-Value Store](/docs/examples/kv_store)** — A concurrent in-memory store built on the actor model. A single fiber owns all state; any number of fibers can read and write safely. A good first example of how channels and immutability replace synchronisation primitives in practice.

**[Networked Key-Value Store](/docs/examples/kv_store_networked)** — Extends the in-memory store with a TCP server. Each client connection is an independent fiber; all share the same store actor. Shows how Gab's concurrency model scales naturally from a single process to a networked service.

**[Pub/Sub Broker](/docs/examples/pubsub)** — A publish/subscribe message broker. Publishers send events to a topic; all subscribers receive them. Shows dynamic collections of channels, fire-and-forget fan-out, and how actor state can be a record of records.

## How to read these examples

Each example is structured the same way: the design comes first, then the implementation is built up in stages, and the full program appears at the end. Read the design section before the code — understanding *why* something is structured the way it is makes the *how* much easier to follow.

If you spot something that looks wrong, or have a question the example doesn't answer, the source is on [GitHub](https://github.com/gab-language/cgab).
