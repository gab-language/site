---
title: "Pub/Sub Broker"
weight: 3
---

This example builds a publish/subscribe message broker. Publishers send events to a topic; all subscribers to that topic receive them. The broker is a single actor fiber — the same pattern as the key-value store, with more interesting state.

---

## The Design

The broker owns a record mapping topic names to subscriber lists. Each subscriber list is a record used as a growable list of channels.

```
state = {
  news:  [ chan_a, chan_b ],
  sport: [ chan_c ]
}
```

Three commands:

- **`broker\subscribe:`** — add a channel to a topic's subscriber list
- **`broker\unsubscribe:`** — remove a channel from a topic's subscriber list
- **`broker\publish:`** — send an event to every subscriber on a topic

Fan-out spawns one fiber per subscriber, so a slow subscriber never stalls the broker or other subscribers.

## The Broker Actor

The broker channel carries `(cmd, args*)` tuples. No reply channel is needed since callers don't wait for a result from any of the three commands.

```gab
Broker = broker:

make: .def (Broker, () => do
  ch = Channels.make

  loop = (state) => do
    (cmd, args*) = ch >! .unwrap
    next_state = (cmd, state, args*) .handle
    self.(next_state)
  end

  Fibers.make () => loop.({})

  ch
end)
```

## The Command Handlers

**`broker\subscribe:`** uses `put_via_by:` to append the new channel to the topic's subscriber list with `cons:`. If the topic doesn't exist yet, `put_via_by:` initialises it automatically.

**`broker\unsubscribe:`** checks the topic exists with `at:`, then uses `put_by:` with a transformation block to rebuild the subscriber list in place. `filter:` keeps every channel where `c == ch !` is true (the `!` negates, so channels that are *not* `ch` are kept). `.or(state)` returns `state` unchanged if the topic doesn't exist.

**`broker\publish:`** iterates over subscribers and spawns a fiber per delivery. `state` is returned unconditionally after the `then:` chain.

```gab
handle: .defcase {
  broker\subscribe: (state, topic, ch) => do
    state.put_via_by(topic subs => subs.cons ch)
  end

  broker\unsubscribe: (state, topic, ch) => do
    state.at(topic)
      .then(() => do
        after = state.put_by(topic, subs => subs.filter(c => c == ch !))
        after
      end)
      .or(state)
  end

  broker\publish: (state, topic, event) => do
    state.at(topic)
      .then(subs => do
        subs.each sub => do
          Fibers.make () => sub <! event
        end
      end)

    state
  end
}
```

## The Public API

All three methods are fire-and-forget. `broker\unsubscribe:` takes both the topic and the channel. The topic is needed to locate the subscriber list.

```gab
t: .def (Broker, Channels.t)

[Broker.t] .defmodule {
  broker\subscribe: (topic, ch) => do
    self <! (broker\subscribe: topic ch)
  end

  broker\unsubscribe: (topic, ch) => do
    self <! (broker\unsubscribe: topic ch)
  end

  broker\publish: (topic, event) => do
    self <! (broker\publish: topic event)
  end
}
```

## Putting it Together

Because the broker processes commands asynchronously, subscribers must confirm they have registered before the publisher starts sending, and the publisher must wait for unsubscription to complete before sending to a topic the subscriber has left. A shared `done` channel coordinates all of this:

```gab
broker = Broker.make
done   = Channels.make

Fibers.make () => do
  inbox = Channels.make
  broker.broker\subscribe(news: inbox)

  done <!         # signal: subscribed

  inbox.each (event) => do
    'NEWS: $'.sprintf(event).println
  end
end

done >!           # wait for news subscriber

Fibers.make () => do
  inbox = Channels.make
  broker.broker\subscribe(sport: inbox)

  done <!         # signal: subscribed

  inbox.each (event) => do
    'SPORT: $'.sprintf(event).println

    broker.broker\unsubscribe(sport: inbox)
    done <!       # signal: unsubscribed
  end
end

done >!           # wait for sport subscriber

broker.broker\publish(news:  'Gab 1.0 released')
broker.broker\publish(sport: 'Final score: 3-1')
broker.broker\publish(news:  'Another story')

done >!           # wait for sport subscriber to unsubscribe

# This event has no subscribers — the sport listener
# unsubscribed itself after receiving the first event.
broker.broker\publish(sport: 'Final score: 6-7')
```

The sport subscriber unsubscribes after receiving its first event, then signals `done` to tell the main fiber it is safe to send the second sport event. The final publish is silently dropped — no subscribers remain on the `sport:` topic.

## The Full Program

The full broker module is below.

```gab
Broker = broker:

make: .def (Broker, () => do
  ch = Channels.make

  loop = (state) => do
    (cmd, args*) = ch >! .unwrap
    next_state = (cmd, state, args*) .handle
    self.(next_state)
  end

  Fibers.make () => loop.({})

  ch
end)

handle: .defcase {
  broker\subscribe: (state, topic, ch) => do
    state.put_via_by(topic subs => subs.cons ch)
  end

  broker\unsubscribe: (state, topic, ch) => do
    state.at(topic)
      .then(() => do
        after = state.put_by(topic, subs => subs.filter(c => c == ch !))
        after
      end)
      .or(state)
  end

  broker\publish: (state, topic, event) => do
    state.at(topic)
      .then(subs => do
        subs.each sub => do
          Fibers.make () => ok = sub <! event
        end
      end)

    state
  end
}

t: .def (Broker, Channels.t)

[Broker.t] .defmodule {
  broker\subscribe: (topic, ch) => do
    self <! (broker\subscribe: topic ch)
  end

  broker\unsubscribe: (topic, ch) => do
    self <! (broker\unsubscribe: topic ch)
  end

  broker\publish: (topic, event) => do
    self <! (broker\publish: topic event)
  end
}

Broker
```
