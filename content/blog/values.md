+++
date = '2025-04-16T09:22:19-04:00'
draft = false
title = 'Value Representation'
+++
## Why it matters
In a language like `C`, code is compiled to run natively - values are just blocks of memory, and at runtime there is *no type information*.
A register could hold an integer, or a pointer, or a boolean, but to the program they're all just bits.

This differs from how a language like Java, Python, or Gab work. 
These dynamic languages also carry type information about values through runtime, and use it for garbage collection, reflection, and detecting type errors.

> Don't get mad at me for calling Java dynamic. You know it is.

At the runtime-level, dynamic languages need a type which can represent *any* value in a program. A simple (dare I say naive) way of implementing this is with
a *tagged union*.
```c
struct value {
    /* A 'tag' to keep track of which kind of data is in 'val' */
    enum value_type t;
    union {
        /* Numeric value */
        double floating;
        /* A boolean */
        bool boolean;
        /* A pointer to a larger object on the heap */
        void* pointer;
    } val;
};
```
This works well! We can now pass around this small struct in our interpreter. Just to help you visualize, here is what a simple add instruction might look like.
```c
 struct value add_implementation(struct interpreter* i, struct value lhs, struct value rhs) {
     /* We have a type error, throw an error in our interpreter */
     if (lhs.type != TYPE_NUMBER || rhs.type != TYPE_NUMBER)
         return throw_error(i);

     /* Create a new value with the result of the addition */
     return (struct value) {
         .t = TYPE_NUMBER,
         .val.floating = lhs.val.floating + rhs.val.floating,
     };
 }
```
Alright! We've seen how these values can be used in our c-interpreter, and it all works nicely. What are the problems with this approach?
To understand that, we need to dive a little bit deeper into how our c-interpreter *actually* works.

Native programs have two types of memory - a **stack** and a **heap**. The same is true in the managed runtimes of Java, Python, and Gab. The interpreters (or virtual machines - VMs, as I'll probably say from now on) have an internal *stack*, which keep track of local variables, scopes, and function calls.

Here we have a random Python function which for the purpose of this demonstration, just makes some random calculations with arguments and variables.
```python
def example(a, b):
    c = a + b
    d = a - b
    e = c * d
    return e
```
Let's take a look at how the *stack* might look under the hood as this function is being called.
> Disclaimer: I am not a cpython expert. I am guessing based on what I know about it and stack vms in general.
```python
# Here is what the stack might look like at the callsite below.
example(1, 2)
# %---------%
# | 2       | The second argument
# %---------%
# | 1       | The first argument
# %---------%
# | example | The function being called
# %---------%
# | ....... | Any local variables before, or functions being called above
# %---------%

# Once we're in example, it might look like this:
def example(a, b):
    c = a + b
    d = a - b # <-- Paused here
    e = c * d
    return e
# %---------%
# | -1      | Local variable d
# %---------%
# | 3       | Local variable c
# %---------%
# | 2       | The second argument (local variable b)
# %---------%
# | 1       | The first argument (local variable a)
# %---------%
# | ....... | The rest of the stack below, i.e. all the function calls that led to this one
# %---------%
```
The point I'm trying to get across is that the stack is basically a big, contiguous, array. As functions are called and scopes are entered/left, values are pushed and popped off of this array.
Lets tie in our tagged-union implementation, and look at the actual **memory layout** of our stack at the last pause point.
```c
const sz = sizeof(struct value);         // 9 bytes
const alignment = alignof(struct value); // 16 bytes
/* Something like this:
 %---------%
 | -1      | 8 byte integer value field
 | ------- |
 | TAG_NUM | 1 byte tag
 | ------- |
 | PADDING | 7 bytes padding
 %---------%
 | 3       | Local variable c
 | ------- |
 | TAG_NUM | 1 byte tag
 | ------- |
 | PADDING | 7 bytes padding
 %---------%
 | 2       | The second argument (local variable b)
 | ------- |
 | TAG_NUM | 1 byte tag
 | ------- |
 | PADDING | 7 bytes padding
 %---------%
 | 1       | The first argument (local variable a)
 | ------- |
 | TAG_NUM | 1 byte tag
 | ------- |
 | PADDING | 7 bytes padding
 %---------%
 | ....... | The rest of the stack below, i.e. all the function calls that led to this one
 %---------%
*/
```
Look at this! Our vm's internal representation of our program's stack is almost **50%** padding. In fact, any contiguous array of these structs wastes nearly 50% of its memory.

This is extremely relevant, as a runtime will keep these values in a contiguous array in *many* places:
- The vm's internal stack.
- The internal stack of lightweight fibers/green threads.
- Garbage collection often involves keeping track of lists of values.
- Implementing data structures like lists/dictionaries/records/tuples often use contiguous arrays of values.

In each of these areas, we're experiencing:
- Less relevant data can fit into the cpu caches.
- We allocate *more* memory from the kernel dynamically than we actually use.

In order to fix this problem, is there a way to fit a value *and* a tag into 8 bytes?

## NaN Tagging
There is a technique among vm-implementers known as *NaN tagging*, which involves repurposing some of the normally useless states
that a double-precision floating-point number can be in. There is an in-depth explanation in the source code, and the comment is copied at the end of this blog post.

To summarize, we use a special incantation bit-pattern (known as a quiet NaN) to signal that we're in one of these useless floating-point states. If we confirm a double matches our incantation,
we can safely use the lower 50 bits to interpret however we choose. If it doesn't, then we should interpret it as an ordinary double.

In the special nan-tagging case, `cgab` sets aside the highest two bits to store an extra tag, leaving 48 bits below for data.

> There is actually another state - when the sign bit is set *and* the incantation is found, we should interpret the lower 50 bits as a pointer to the heap.
> On the other side of the pointer there will be a tag and data describing the object.

The tag uses the same `gab_kind` enum that the rest of `cgab` uses - it describes all the types a value can possibly have.
```c
enum gab_kind {
  kGAB_STRING = 0, // MUST_STAY_ZERO
  kGAB_BINARY = 1,
  kGAB_MESSAGE = 2,
  kGAB_PRIMITIVE = 3,
  kGAB_NUMBER,
  // ... Lots of others omitted for brevity
};
```
The reason that the first four values are specified is because of our NaN tagging scheme. Those four kinds need to be small enough to fit in our two-bit tag.
These four tags determine the types of all the values which we can cram into our remaining 48 bits.

### Short String Optimization
Using the remaining 48 bits, `cgab` can store up to 5 bytes of string data, including a length byte. This short string optimization is also described in the below comment.
Strings, Binaries, and Messages *all* benefit from the short string optimization, and internally they all point to the same data. This is because the tag in the NaN-boxed value itself is 
what determines whether the value is a String, Binary, or Message. Because of this, converting *between* the 3 string-like types is quite literally trivial. Here is the code for converting
a string into a binary, lifted from `cgab`.
```c
gab_value gab_strtomsg(gab_value str) {
  assert(gab_valkind(str) == kGAB_STRING);
  return str | (uint64_t)kGAB_MESSAGE << __GAB_TAGOFFSET;
}
```
It simply takes the input value (which should have `kGAB_STRING` for its NaN tag, aka 0) and bitwise-ors in the `kGAB_MESSAGE` tag instead. Just two instructions!
> This detail is why the kGAB_STRING enum must have the value 0!

As promised, Here is the big doc comment lifted directly from `cgab`'s source code.
It describes more in depth how the floating-point trickery and short-string optimization work.
```c
/**
 * %-------------------------------%
 * |     Value Representation      |
 * %-------------------------------%
 *
 * Gab values are nan-boxed.
 *
 * An IEEE 754 double-precision float is a 64-bit value with bits laid out like:
 *
 * 1 Sign bit
 * |   11 Exponent bits
 * |   |           52 Mantissa
 * |   |           |
 * [S][Exponent---][Mantissa------------------------------------------]
 *
 * The details of how these are used to represent numbers aren't really
 * relevant here as long we don't interfere with them. The important bit is NaN.
 *
 * An IEEE double can represent a few magical values like NaN ("not a number"),
 * Infinity, and -Infinity. A NaN is any value where all exponent bits are set:
 *
 *     NaN bits
 *     |
 * [-][11111111111][----------------------------------------------------]
 *
 * The bits set above are the only relevant ones. The rest of the bits are
 * unused.
 *
 * NaN values come in two flavors: "signalling" and "quiet". The former are
 * intended to halt execution, while the latter just flow through arithmetic
 * operations silently. We want the latter.
 *
 * Quiet NaNs are indicated by setting the highest mantissa bit:
 * We also need to set the *next* highest because of some intel shenanigans.
 *
 *                  Highest mantissa bit
 *                  |
 * [-][....NaN....][11--------------------------------------------------]
 *
 * This leaves the rest of the following bits to play with.
 *
 * Pointers to objects with data on the heap set the highest bit.
 *
 * We are left with 50 bits of mantissa to store an address.
 * Even 64-bit machines only actually use 48 bits for addresses.
 *
 *  Pointer bit set       Pointer data
 *  |                     |
 * [1][....NaN....11][--------------------------------------------------]
 *
 * Immediate values *don't* have the pointer bit set.
 * They also store a tag in the 2 bits just below the NaN.
 * This tag differentiates how to interpret the remaining 48 bits.
 *
 *      kGAB_BINARY, kGAB_STRING, kGAB_MESSAGE, kGAB_PRIMITIVE
 *                   |
 * [0][....NaN....11][--][------------------------------------------------]
 *
 * 'Primitives' are immediates which wrap further data in the lower 48 bits.
 * In most cases, this value is a literal bytecode instruction. This allows
 * the vm to implement certain message specializations as bytecode instructions.
 *
 * There are some special cases which are not bytecode ops:
 *  - gab_cvalid
 *  - gab_cinvalid
 *  - gab_ctimeout
 *  - gab_cundefined
 *
 * These are constant values used throughout cgab.
 *
 *                    kGAB_PRIMITIVE                  Extra data
 *                    |                               |
 * [0][....NaN....11][--][------------------------------------------------]
 *
 * Gab also employs a short string optimization. Lots of strings in a gab
 * program are incredibly small, and incredibly common. values like
 *
 * none:
 * ok:
 * and even a send, like (1 + 1), stores a small string (for the message +:)
 *
 * We need to store the string's length, a null-terminator (for
 * c-compatibility), and the string's data.
 *
 * Instead of storing the length of the string, we store the amount of bytes
 * *not* used. Since there are a total of 5 bytes available for storing string
 * data, the remaining length is computed as 5 - strlen(str).
 *
 * We do this for a special case - when the string has length 5, the remaining
 * length is 0. In this case, the byte which stores the remaining length *also*
 * serves as the null-terminator for the string.
 *
 * This layout sneakily gives us an extra byte of storage in our small strings.
 *
 *             kGAB_STRING Remaining Length                             <- Data
 *                    |    |                                               |
 * [0][....NaN....11][--][--------][----------------------------------------]
 *                       [   0    ][   e       p       a       h       s    ]
 *                       [   3    ][----------------   0       k       o    ]
 *
 */
```
