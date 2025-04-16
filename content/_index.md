+++
title = "Gab"
type = "home"
+++
> [intransitive verb]
>
> to talk in a rapid or thoughtless manner, ie: chatter

## Programming systems, not systems programming.
**Gab** is a dynamic and high-level programming language which takes inspiration from all manners of languages and paradigms. 
It does so with a single goal in mind: to *make building systems easier*. Gab provides the minimal set of abstractions necessary for building
a modern concurrent system.

Below you'll find a list of principles core to the language which help to achieve this goal.
If you like what you see, head to the docs to get started. 

## Simplicity is a feature.
The syntax of the language is minimal *by design* - it can be learned within an hour.
This is emphasized by the fact that there is only one mechanism for control flow: *sending messages*.
```gab
welcome_message = ['Hello', ' ',  'world!']

welcome_message.join.println
# => Hello world!
```
Say goodbye to `if`, `for`, and `while`! ( we promise you won't miss them )
## Concerned with concurrency.
Gab's custom runtime environment supports hundreds of thousands of concurrent fibers. Fibers communicate with each other throuch channels - 
another core datatype to the language. Unlike Go and other implementations of CSP, Gab channels are *always unbuffered*. They serve as a synchronization point, as well as a way to pass around data. Which, by the way, is done with **zero copying** in Gab.
```gab
print_chan = Channels.make

Ranges.make(0, 10000).each i => do
    Fibers.make () => do
        print_chan <! 'Hello, from fiber $!'.sprintf(i)
    end
end

print_chan.each println:
```
## Immutable always.
All of Gab's data structures are immutable (Yes, even `gab\channel`). For languages focused on multithreaded programming, immutability is the *only sensible option*.
Gab's immutable record is implemented with a custom Hash-Array-BitMapped-Vector-Trie, heavily inspired by clojure's persistent vector. In truth, `gab\record` is the *only data structure* in the language.
Traditional square-bracket `[]` lists use the same data structure (and `gab\shape` principle - more on that later).
```gab
bob = { name: 'bob', age: 44 }
# => { name: 'bob' age: 44 }

alice = bob.put(name: 'alice')
# => { name: 'alice' age: 44 }

bob
# => { name: 'bob' age: 44 }
```
## Designed for performance.
Many of todays dynamic or interpreted languages made decisions early in their design which have left them difficult to make fast. This is a tradeoff - these choice make the languages more
convenient, or maybe served a purpose that has become obsolete. Gab has constrained itself in order to make competetive performance easier to achieve.
Said tradeoffs:

- No global variables.
- No implicit conversions.
- `gab\channel` is always unbuffered.
- No control flow other than sending messages.
- Only one data structure, `gab\record`.

Gab's small surface area also plays a part here. Since Gab only has one mechanism for control flow (messages) and one data-structure (`gab\record`),  that leaves only two hot code-paths in cgab's implementation.
All optimization efforts can focus on improving either message dispatch or record operations.
