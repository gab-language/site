+++
date = '2025-02-07T12:49:57-05:00'
title = 'Basic Types'
weight = 2
+++
In this chapter, we will learn more about Gab's basic types. At the core of any language is its values - Gab is no different. In fact - values are almost *all* there is in Gab's syntax.
This introduction will build the foundation of how to think and program in Gab.
### Numbers
Numbers are represented by IEEE 64-bit floating point values. There is no distinct integer type.
```gab
1
-42
0.2 ? # => gab\number
```
> [!NOTE]
> Numbers less than one **require** a leading zero, as shown below.
>
> This is because the plain `.` would conflict with another element of Gab's syntax (a message send).
### Strings
Strings are a sequence of bytes. They are UTF8-encoded. For working with raw un-encoded bytes, Gab provides `gab\binary`.
```gab
"gab"
"what type am I?" ?
# => gab\string

'Single quoted strings support escaping!\n'
```
> [!NOTE] As seen above, the operator for inspecting the type of a value is the question mark.
### Blocks
Blocks are Gab's closures or functions. They use the familiar `=>` syntax:
```gab
square = (x) => x * x
# => <gab\block ...>

square.(2)
# => 4
```
Blocks always have an implicit **self** local. On their own, it isn't very useful. It will become useful later for defining message *specializations*.
```gab
get_me = () => self
# => <gab\block ...>

get_me.()
# => <gab\block ...>
```
### Messages
Messages are another obscure concept, also to be explored later. In this context, think of them as *atoms* or *keywords* - values which represent themselves. Gab takes this a step further:
the type of a message is *also itself*.
```gab
message:      
# => message:

message: ?  
# => message:
```
Messages are  useful as keys in records, to indicate success or failure in returning from blocks, as enumerations, and in many other ways.
Messages can also be called like blocks - however, they will look up a *specialization* based on the receiver's type.
```gab
+:.(2, 2)
# => 4

+:.('Hello ', 'world!')
# => 'Hello world!'
```
Instead of writing out a message literal like `+:` and calling it, we can use a different *infix* notation. For operators like `+:`, that should look familiar!
```gab
2 + 2
# => 4

# We've already seen another syntax for sending messages
#  (ones that aren't operators)
# Replace the colon `:` at the end with a dot `.` at the front,
#  and you've got a message send!
'Hello world!'.println
```
### Records
Records are Gab's *only* data structure. They serve as both dictionaries *and* lists.
```gab
{ msg: 'hi' }

[1, 2, 3]

{ name: "Joe" }?
# => <gab\shape name:>
```
### Shapes
Shapes are one of the more obscure concepts in Gab. We'll explore them further later. For now, know that all records with the same set of keys (in the same order) share the same *shape*.
```gab
a = { name: "Joe" }

a ?
# => <gab\shape name:>

b = { name: "Rich" }
b ?
# => <gab\shape name:>

(a ?) == (b ?)
# => true:
```
> [!NOTE]
> A space is required between `a` and `?`. Identifiers like `a` are allowed to end with either a question mark `?` or an exclamation point `!`. This serves various conventions
> in Gab.
### Fibers
`gab\fiber` is a green thread - similar to processes on the BEAM, and goroutines in golang.
```gab
Fibers.make () => do
    'I could run on another os thread!'
end
```
Fibers are created as above, and automaticaly queued up for execution. The block passed to `make:` will run, potentially on another operating-system thread.
As all Gab values are immutable, the block passed here may capture any variables it likes. However, communicating to this fiber once its created is only possible
through a `gab\channel`.
### Channels
Channels are a synchronized portal for handing off values between two `gab\fibers`.
```gab
ch = Channels.make

# <!: is a blocking operation to put a value onto a channel
Fibers.make () => ch <! 'Hello world!'

# >!: is the opposite - a blocking operation for taking values out.
ch.>!.println
```
A fiber waiting on a channel operation may not continue executing until either the operation completes or the channel closes.
To prevent fibers from hogging the CPU while they wait, they may yield the CPU to other fibers and will retry their operation at a later time.
> [!NOTE]
> Even the put message `<!:` must block until a receiver arrives to become responsible for the passing value.
> This is required by Gab's runtime, as the `gab\channel` value is immutable and cannot hold references to other values.
## Conclusion
And thats it! Gab is meant to be small and composable - the core concepts are few, but they compose in powerful ways. The chapters that follow will explore these types further!
