## number
```gab
float
```

  A 64-bit floating number.
  

## float\between
```gab
gab\number:.float\between: (() | from 0 to  number | between (lower number, upper number)) => number
```
Return a random float between lower and upper..

## Pi
```gab
gab\number:.Pi: () => number
```
Return pi.

## E
```gab
gab\number:.E: () => number
```
Return e.

## Infinity
```gab
gab\number:.Infinity: () => number
```
Return infinity.

## MaxInt
```gab
gab\number:.MaxInt: () => number
```
Return the maximum safe integer available to the gab runtime.

## is\nan
```gab
number.is\nan: () => boolean
```

  Returns true if self is NaN.
  

## is\inf
```gab
number.is\inf: () => boolean
```

  Returns true if self is infinity.
  

## floor
```gab
number.floor: () => number
```

  Returns the largest integral value not greater than self.
  

## ceil
```gab
number.ceil: () => number
```

  Returns the smallest integral value not less than self.
  

## round
```gab
number.is\round: () => number
```

  Returns self to the nearest integral value.
  

## acos
```gab
number.acos: () => number
```

  Returns the arccosine of self.
  

## asin
```gab
number.asin: () => number
```

  Returns the arcsine of self.
  

## atan
```gab
number.atan: () => number
```

  Returns the arctangent of self.
  

## cos
```gab
number.cos: () => number
```

  Returns the cosine of self.
  

## sin
```gab
number.sin: () => number
```

  Returns the sine of self.
  

## tan
```gab
number.tan: () => number
```

  Returns the tangent of self.
  

## abs
```gab
number.abs: () => number
```

  Returns the absolute value of self.
  
