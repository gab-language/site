+++
date = '2025-02-07T12:49:57-05:00'
title = 'Basic Types'
weight = 1
+++
In this chapter, we will learn more about Gab's basic types. It will build the foundation of how to think and program in Gab.
### Numbers
Numbers are represented by IEEE 64-bit floating point values. There is no distinct integer type.
```gab
1
0.2 ? # => gab\number
```
**Note:** `?` is the operator for getting the type of a value.
### Strings
Strings are just a sequence of bytes.
```gab
"gab"
"what type am I?" ? # => gab\string
```
### Records
Records are both dictionaries *and* lists.
```gab
{ msg: 'hi' }
[1, 2, 3]
{ name: "Joe" } ? # => <gab\shape name:>
```
### Shapes
Shapes are one of the more obscure concepts in Gab. We'll explore them further later. For now, know that all records with the same set of keys (in the same order) share the same *shape*.
```gab
a = { name: "Joe" }
b = { name: "Rich" }
(a ?) == (b ?) # => true:
```
### Messages
Messages are another obscure concept, also to be explored later. To begin, just think of them as methods. They also serve as constants whose value and type is just their name.
```gab
message:      
message: ?    # message:
```
## Conclusion
And thats it! Gab is meant to be small and composable - the core concepts are few, but they combine in powerful ways. The chapters that follow will go explore these types further.
