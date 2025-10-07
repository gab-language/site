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

# Why Gab?
There are countless options when choosing a programming language today. What does Gab offer that makes it unique?
- The language is simple.
- Concurrent from the start.
- Fast and small.
- Cross-platform distribution.

## Simple.
Gab is objectively simple because it objectively has few features. There is a single method for control flow: sending messages.
```gab
welcome_message = ['Hello', ' ',  'world!']

welcome_message.join.println
# => Hello world!
```
Say goodbye to `if`, `for`, and `while`! ( we promise you won't miss them )
## Concurrent.
Gab's custom runtime environment supports hundreds of thousands of concurrent fibers. Fibers are small units of execution - similar to processes on the BEAM, goroutines in Go.
Fibers communicate with each other throuch channels - another core datatype to the language.
They are the sole way that fibers can communicate with one another. Golang also has channels, and the BEAM has mailboxes where processes receive messages.
In both of these implementations, messages are **copied** from the sender into the receiver.
Gab is designed such that messages can be sent between fibers **without copying**.
```gab
print_chan = Channels.make

Ranges.make(0, 10000).each i => do
    Fibers.make () => do
        print_chan <! 'Hello, from fiber $!'.sprintf(i)
    end
end

print_chan.each println:
```
## Immutable.
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
## Performant.
Many of todays dynamic or interpreted languages made decisions early in their design which have left them difficult to make fast. This is a tradeoff - these choice make the languages more
convenient, or maybe served a purpose that has become obsolete. Gab has constrained itself in order to make competetive performance easier to achieve.
Said tradeoffs include:

- No global variables.
- No implicit conversions.
- `gab\channel` is unbuffered.
- No control flow other than sending messages.
- Only one data structure, `gab\record`.

Gab's small surface area also plays a part here. Since Gab only has one mechanism for control flow (messages) and one data-structure (`gab\record`),  that leaves only two hot code-paths in cgab's implementation.
All optimization efforts can focus on improving either message dispatch or record operations.
## Distrubition.
Trivial cross-platform distribution is a principle for Gab. Gab's build system allows the programmer to build standalone executables for *any supported platform from any other*. All of Gab's builtin modules support
all of Gab's platforms out of the box (and they always will.) This means that distributing your Gab app is as simple as:
```bash
gab build -t aarch_64-macos-none <my_project>

file my_project.exe
#> my_project.exe: Mach-O 64-bit arm64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|NO_REEXPORTED_DYLIBS|PIE>

gab build -t x86_64-linux-gnu <my_project>

file my_project.exe
#> my_project.exe: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.
#  so.2, for GNU/Linux 2.0.0, with debug_info, not stripped
```
This single file includes the entire gab runtime, as well as all dependencies necessary to run your project.
