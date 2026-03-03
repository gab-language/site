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
1.2e4
0.2? # => gab\number
```
> [!NOTE]
> Numbers less than one **require** a leading zero, as shown below.
>
> This is because the plain `.` would conflict with another element of Gab's syntax (a message send).
### Strings
Strings are a sequence of bytes. They are UTF8-encoded. For working with raw un-encoded bytes, Gab provides `gab\binary`.
```gab
"gab"
"what type am I?"?
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

message:?  
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

# This also works for operators
2 .+ 2
# => 4
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
+++
date = '2025-02-07T13:01:01-05:00'
title = 'Arithmetic'
weight = 1
+++
Lots of dynamic scripting languages make the distinction between integers and floats. Python can even upgrade numbers to the heap when they would otherwise overflow their size.
Gab keeps it simple - numbers are just 64-bit floats. It is possible that in the future a distinct integer type will be added.
```gab
1 / 3
# => 0.33333

2 * 2 
# => 4
```
### A note on bit-shifting
The bit-shift operators `<<` and `>>` are particularly interesting to implement. Dynamic languages do this slightly differently.
In the normal case, shifting does divisions or multiplications by 2.
```gab
4 << 1
# => 8

4 >> 1
# => 2
```
However, there are some corner cases which are actually *undefined behavior* in c. Dynamic languages implemented on top of c need to *define* this behavior.
Shifting left or right by a negative amount is undefined behavior
```gab
4 << -1
4 >> -1
```
Most dynamic languages replace these with an equal shift in the opposite direction (Javascript, python, lua, ruby). Gab matches this behavior.
```gab
4 >> -1
# => 8

4 << -1
# => 2
```
Shifting left or right by a number greater than the width of the integer is undefined behavior.
```gab
# What does this mean?
4 >> 65
4 << 65
```
A lot of dynamic languages implement this by just returning 0 - which makes sense when you think about a shift conceptually. This is what Gab does.
Additionally, it is important to note that for these bitwise or integer operations, Gab uses 52-bit integers. This is because 64-bit integers are not completely
representable with a 64-bit float. In order to guarantee lossless conversion between the number types, Gab limits integers to 52 bits.
```gab
1 << 52
# => -4.5036e+15
1 << 53
# => 0
```
Notably, Javascript diverges here:
```javascript
1 << 31
// => -2147483648
1 << 32
// => 1

// If it isn't clear whats happening here:
const INT_WIDTH = 32
1 << (31 % INT_WIDTH)
// => -2147483648
1 << (32 % INT_WIDTH)
// => 1
```
This is the most nasty of the corner cases. Bit shfiting negative integers is confusing!
```gab
# left-shifting a negative integer is undefined behavior
-1 << 1

# right-shifting a negative integer is implementation defined
-1 >> 1
```
Python, Javascript, and Ruby maintain the divide/multiply by two semantics that work on positive integers.
However, this isn't behavior that you would actually see in the hardware. As mentioned above, shifting negative integers is either
implementation defined or undefined behavior. Lua's bit shifting works like this:
```lua
-4 >> 1
-- 9223372036854775806
-4 << 1
-- -8
```
This is because lua performs the shift operation on *unsigned integers*, so the `-4` wraps around
(due to underflow) into a really large number, which is then bitshifted to the right by one, and *then*
converted back into a signed integer. This avoids the icky behavior of shifting signed integers in C, but does
mean shifting positive and negative integers has  asymmetrical semantics. It is also more performant than a symmetrical implementation,
because less checks/conversions are required. Gab chooses this route, as shifting negative integers is not a common enough operation to warrant
the extra checks and implementaiton effort.
+++
date = '2025-03-10T10:06:10-04:00'
draft = false
title = 'Blocks'
weight = 3
+++
Blocks are simply functions, as seen before. But there are some additional, useful tidbits to cover in this chapter.
### Multiple return values
Blocks can return multiple values, similar to golang or lua.
Here, `open:` returns two values. One signals the status of the operation, and another providing value or an error.
```gab
IO.file('my_data.csv')
# => ok: <gab\box io\file ...>
# => err: File does not exist
```
The group of values *passed to* and *return from* a block is called a **tuple**. They can be unpacked like this:
```gab
# Unpack the tuple here with parentheses ().
# This is called 'destructuring'
(status, stream) = IO.file('my_data.csv')

status.ok.then () => do
    # Do something with stream here.
end

# Alternatively, we can unwrap our stream:
# This will crash if the first element in the tuple isn't ok:
stream = IO
    .file('my_data.csv')
    .unwrap
```
Tuples are used heavily, and preferred to records wherever possible.
While records allocate memory, tuples use the interpreter's stack and **do not** require allocation.
### Tuples
Now that we've been introduced to tuples, there are a few rules about them to learn.
```gab
# Messages are sent to the FIRST element of a tuple.
# Heres some funky syntax you *could* write:

(1 2) +
# => 3

(1 2) + 3
# => 4
```
When the left-hand side of a send is a tuple and the right-hand side is empty, Gab emits a send to the **whole** left-hand tuple.
When the right-hand side is **not** empty, Gab will *trim* the left hand side to one value, and then send the message to that value with the right-hand tuple as arguments.

This behavior means that you can forward **entire** tuples returned by blocks into new message sends, without any intermediate allocation.
In fact, this is how `unwrap:` is implemented!
```gab
unwrap: .defcase {
    # If the receiver (first element of tuple) was ok: then return the result
    ok:  result => result
    # If the receiver was err: then panic
    err: err => 'Unwrap Failed: $'.panicf err
}

# file: returns a tuple (ok: <gab\box io\stream ...>)
# This tuple is forwarded to .unwrap
stream = IO
    .file('my_data.csv')
    .unwrap
```
+++
date = '2025-02-07T16:06:29-05:00'
title = 'Booleans'
weight = 4
+++
Booleans are implemented with messages - they are not built-in keywords like in other languages!
```gab
true:
false:
```
There is no `if` in gab. Typically, a `defcase` is used instead:
```gab
my_message: .defcase! {
    true: (args) => do
        # Do something with args in the truthy case
    end
    false: (args) => do
        # Do something with args in the falsey case
    end
}

some_condition .my_message args
```
For simple use cases, there are messages `and:`, `or:`, `then:` and `else:` defined in the core library.
```gab
# Lifted from gab's core library.

truthy_values .defmodule! {
  and: (alt[]) => alt**
  or: _ => self

  then: f => f. self
  else: _ => self
}

falsey_values .defmodule! {
  and: _ => self
  or: (alt[]) => alt**

  then: _ => self
  else: f => f. self
}
```
The `and:` and `or:` messages do what you expect for the most part, except they *don't short circuit*. This means the value on the right is *always evaluated*.
```gab
true: .and 2  # 2
false: .and 2 # .false
false: .or 2  # 2
true: .or 2   # .true
```
The `then:` and `else:` messages **do** short circuit, by accepting *blocks* instead of values.
```gab
true: .then () => do
    # Do something in the truthy case
end
false: .else () => do
    # Do something in the falsey case
end
```
This is is the part of Gab that some may find to be most inconvenient.
However, I find that it encourages writing smaller functions and more modular code, as nesting lots of scopes and conditionals is impossible.
+++
date = '2025-02-07T18:33:11-05:00'
title = 'Messages'
weight = 3
+++
Message are the bread and butter of Gab. They serve many purposes. Mainly they provide control flow, or act as enums or sentinel values. However, They also serve as Gab's mechanism for **polymorphism**.
### Message Sends
The only way to *do* anything is by *sending a message to a value*.
```gab
"Hello world!" .println # => Hello world!
```
Earlier we saw message literals, which look like this:
```gab
println:
```

Now we've seen a message *send*, which is like calling a method or function:
```gab
any_value .println
```

Message literals can also respond to messages!
```gab
my_message: .println # => my_message:
```
In fact, this is how new messages are defined in Gab!
```gab
my_message:.def(
    myType,
    () => do
        self.name.println
    end)
```

Messages *themselves* respond to the `def:` message by adding a new implementation for the given type(s).
There are several other messages for defining new implementations, which Gab refers to as **specializations**.
```gab
# Define multiple specializations for one message, conveniently
my_message: .defcase {
    nil:  () => "I was nil!"
    true: () => "I was true!"
    none: "I was none!" # Values alone can also serve as a specialization.
}

# Define the same specializations for multiple types, conveniently
[ myType, myOtherType ] .defmodule {
    message_one: () => "Sending message one"
    message_two: () => "Sending message two"
}
```
### Message Values
We've seen message values before. They are identifiers that end in a colon`:`.
They're useful for singleton or sentinel values - and in fact, Gab implements booleans and nil using messages. More on this in later chapters!
Gab also uses message values to implement results or optionals.
Since Gab has multiple return values, sends that can error often return multiple values like this:
```gab
# This call may fail, if Gab can't open the file
(ok file) = IO.file('Maybe_Exists.txt')

(ok file) # => If the file exists  (ok: <gab\box io\file ...>)
          # => If the file doesn't (err: "File not found")

# This line will crash - the record doesn't respond to age:
age = { name: 'bob' } .age

(ok age) = { name: 'bob' }.at(age:)
# Now instead we will either see:
# => (ok: <whatever we saw in the record>)
# => (none: nil:)

```
+++
date = '2025-02-07T16:07:28-05:00'
title = 'Records'
weight = 5
+++
Records are collections of key-value pairs. They are ordered and structurally typed. In Gab they come in two flavors - Dictionaries and Lists.
### Dictionaries
Dictionaries are Gab records which allow arbitrary values as keys. They are denoted with `{}`.

Between the curly brackets, expressions are expected in key-value pairs.
Any expression is allowed as either a key or value.
```gab
a_record = { key: 'value' }

a_record .key                    # => 'value'

another_record = { key: 'value', 'another_key' 10 } 

another_record .at 'another_key' # => (ok: '10)
```
### Lists
Lists are records which allow only monotonically-increasing-integer values as keys. This is some fancy talk for saying it only allows for keys `0-n`.

Lists are constructed with the square brackets `[]`, and any number of expressions are allowed inside.
```gab
a_list = [1 2 3] 

a_list # => [1, 2, 3]

a_list = { 0 1, 1 2, 2 3 }

a_list # => [1, 2, 3]
```
> Note - you can construct a list with the same syntax as a dictionary by typing in those integer keys yourself.
> Gab will still consider it a list-type record.

While you *are* allowed to set any key on a list, keep in mind that Gab will transition the list *into* a dictionary.
```gab
a_list = [1 2 3]
# => [1, 2, 3]

a_list = a_list.put(name: 'bob')
#=> { 0 1, 1 2, 2 3, name: bob }
```
### Records
The rest of this chapter is about `gab\record` itself, and therefore applies to both dictionary and list flavors.

Records, like all values in Gab, are **immutable**. This means that setting values in records returns a *new record*.
```gab
a_record = { key: 'value' }

a_record                                   # => { key:  'another value' }

a_record = a_record .put (key: 'something else')

a_record                                   # => { key: 'something else' }
```
Both **Dictionaries** and **Lists** use the same underlying datastructure, `gab\record`. In order to make these immutable data structures fast, records are implemented with a **bit partitioned vector trie**.
Gab's implementation is very much inspired by clojure's immutable vectors.
Because of this implementation, records are able to *share memory* under the hood, to avoid copying large of data for a single key-value mutation. This is called structural sharing,
and is a common optimization among immutable data structures.

As seen above, `gab\record` implements some useful messages `put:` and `at:`.
```gab
some_record .at key: # => (ok:, 'value')
```
### Shapes
All records have an underlying shape. Shapes determine what the available keys are, and their order. It might be useful to think of shapes as an implicit class.
Records with the same keys in the same order *share the same shape*.
```gab
some_record = { x: 1 y: 2 }

shape_x_y = some_record? # => <gab\shape x: y:>

({ x: 2 y: 3 }?) == shape_x_y # => true:
```
Shapes are useful for defining specializations. When resolving which specialization to use for a given value, Gab checks in the following order:

 - If the value has a **super type**, and said **super type** has an available specialization, use it.
 - If available, use the **type's** specialization.
 - If available, use the **property**.
 - If available, use the **general** specialization.
 - No specialization found.

For example: `{ x: 1 }` has a **super type** of `<gab\shape x:>`, and a **type** of `gab\record`.
```gab
# Define the message y: in the general case.
y: .def 'general case'

# Define the message z: in the case of <gab\shape x:>
z: .def (
    Shapes.make x:,
    'shape case')

{ x: 1 }.x # => 1

{ x: 1 }.y # => 'general case'

{ x: 1 }.z # => 'shape case'
```
+++
date = '2025-02-07T16:06:50-05:00'
title = 'Strings'
weight = 2
+++
This chapter will discuss the three basic string-ish types. It is meaningful to group these three types together because they **share data in memory**.
The string `"true"` and the message `true:` each share the same four bytes of memory in the heap: `[ 't', 'r', 'u', 'e' ]`.
The values differentiate their type by tagging themeselves slightly differently - but this is an implementation detail. The important note to take from this is that
converting these types into each other (eg: `'true'.messages\into`) is a constant-time operation. There is **no copying, nor memory allocation**.
## Strings
Strings are sequences of UTF8-encoded bytes. Single-quoted strings support some escape sequences, while double-quoted strings do not.
```gab
"Hello!"
'\tHello\n'
'Hello \u[2502]'
```
The `gab\string` type *respects* its UTF-8 Encoding. Operations that would be constant time fora `gab\binary` may actually be linear time for a `gab\string`. For example,
slicing a UTF-8 string at a given index requires processing the string linearly. This is because UTF8 is a multi-byte character encoding and codepoints may be anywhere from one to four bytes long.

On the other hand, the `gab\binary` type is trivially convertible from `gab\string`, and respects bytes directly, without enforcing or respecting *any* encoding. Becaues of this, converting from a `gab\binary` to a `gab\string` can fail if the binary is not valid UTF-8.
```gab
smiley = '😀'

smiley.len
# => 1

smiley_bin = smiley.to\b
# => <gab\binary ...>

smiley_bin.len
# => 4
```
There is no syntax for string interpolation, but it is easy to construct strings out of other values using `make:` or `sprintf:`.
```gab
full_name = Strings.make("Ada" " " last_name)

'Format a value: $'.sprintf({ name: 'bob' })
# => 'Format a value: { name: bob }'
```
## Binaries
As mentioned above, the `gab\binary` operates on bytes directly - there is no encoding enforced. This means indexing/slicing operations are constant-time.
There is no syntax for constructing binary literals, but other types can be converted into binaries.
```gab
# Requires linearly scanning from the front of the string
"This is a string".slice(3 8)

# slices from the 3rd to 8th byte in constant time
"This will be a binary".to\b.slice(3 8)
```
