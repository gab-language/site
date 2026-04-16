---
title: Numbers
weight: 1
---

All numbers in Gab are IEEE 754 64-bit floating point values. There is no distinct integer type.

```gab
1
-42
1.2e4
0.2

3.14?   # => gab\number
```

> Numbers less than one require a leading zero: `0.5`, not `.5`. A bare `.` is the empty message send in Gab.

## Arithmetic

The standard arithmetic operators are all message sends:

```gab
10 + 3   # => 13
10 - 3   # => 7
10 * 3   # => 30
10 / 3   # => 3.33333
10 % 3   # => 1
```

## Bitwise Operations and 52-bit Integers

For bitwise operations, Gab uses **52-bit integers**. This is because 64-bit floats can only represent integers losslessly up to 2^52. Limiting integers to 52 bits guarantees that Gab can convert freely between its float representation and integer operations without loss.

```gab
1 << 52   # => -4.5036e+15
1 << 53   # => 0
```

The standard bitwise operators:

```gab
4 & 6    # => 4   (AND)
4 | 2    # => 6   (OR)
4 << 1   # => 8   (left shift)
4 >> 1   # => 2   (right shift)
```

## Bit-Shifting Edge Cases

Gab defines behaviour for several cases that are undefined or implementation-defined in C.

**Shifting by a negative amount** is treated as a shift in the opposite direction:

```gab
4 >> -1   # => 8
4 << -1   # => 2
```

**Shifting by more than 52** returns zero:

```gab
4 >> 65   # => 0
4 << 65   # => 0
```

**Shifting negative integers** follows Lua's semantics: the shift is performed on the unsigned bit representation, then converted back. This means right-shifting a negative number does not preserve the sign bit — it produces a large positive number:

```gab
-4 >> 1   # => 9223372036854775806
-4 << 1   # => -8
```

This is asymmetric but is the most efficient implementation, and shifting negative integers is uncommon enough that the trade-off is worthwhile.
