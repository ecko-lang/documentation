# `std.math`

Constants and floating-point functions.

```ecko
import std.math

math.pi                      # 3.141592653589793
math.sqrt(2)                 # 1.4142135623730951
math.clamp(15, 0, 10)        # 10
math.isclose(0.1 + 0.2, 0.3) # true
```

## Constants

`pi`, `e`, `tau`, `inf`, `nan`.

## Powers and roots

`sqrt`, `cbrt`, `pow`, `exp`, `hypot(x, y)`.

## Logarithms

`ln`, `log(x, base)`, `log2`, `log10`.

## Trigonometry

`sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2(y, x)`, and the hyperbolics
`sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`.

`degrees(rad)` and `radians(deg)` convert.

## Rounding and sign

`trunc`, `sign`, `copysign(x, y)`, `fmod(x, y)`, `clamp(x, lo, hi)`.

The global `floor`, `ceil`, `round` and `abs` are always in scope.

## Integers

`gcd(a, b)`, `lcm(a, b)`, `factorial(n)`.

## Predicates

`isnan(x)`, `isinf(x)`, `isfinite(x)`, and `isclose(a, b)` for tolerance
comparison.

## Float comparison

```ecko
0.1 + 0.2 == 0.3            # false - exact IEEE equality
math.isclose(0.1 + 0.2, 0.3) # true
approx(0.1 + 0.2, 0.3)       # true - the global, same idea
```

Use `isclose` or the global `approx` for anything derived from arithmetic. For
money, do not use floats at all - see [Numbers](../language/numbers.md) and the
`decimal` type.

## Integer division

`7 / 2` is `3`. Convert one operand for a fraction: `float(7) / 2` is `3.5`.
