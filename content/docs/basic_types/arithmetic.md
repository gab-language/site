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
