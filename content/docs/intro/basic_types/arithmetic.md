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
