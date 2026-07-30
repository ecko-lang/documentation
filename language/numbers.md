# Numbers

Three numeric types, each for a different job.

| type | what it is | use for |
|---|---|---|
| `int` | 64-bit signed, **checked** | counting, indexing |
| `float` | IEEE-754 double | scientific, approximate |
| `decimal` | exact base-10, ~28 digits | **money** |

## `int` overflow is an error

```ecko
9223372036854775807 + 1     # runtime error, not a wraparound
```

Silent wraparound is a bug that surfaces far from its cause. Ecko refuses at the
operation.

## `float` equality is exact IEEE

```ecko
0.1 + 0.2 == 0.3            # false
approx(0.1 + 0.2, 0.3)      # true
approx(a, b, 0.01)          # explicit epsilon
```

`==` on floats does what IEEE says, which is the honest answer. `approx` has a
default epsilon of `1e-9`.

## `decimal` for money

```ecko
price = 19.99m
qty = 3
subtotal = price * qty          # 59.97 exactly

tax_rate = decimal("0.0825")
total = subtotal + subtotal * tax_rate

print(0.1m + 0.2m)              # 0.3
print(0.1 + 0.2)                # 0.30000000000000004
```

The rules, chosen so money behaves:

- **`decimal` mixes with `int`** and the result is `decimal`. `5m == 5` is `true`.
- **`decimal` with `float` is a hard error.** A binary float has already lost
  precision; letting it into an exact calculation would silently corrupt the
  result. Convert explicitly if you truly mean to.
- **`decimal(aFloat)` is rejected.** Pass a string - `decimal("0.1")` - to state
  the exact value you want. `decimal(x)` does accept an `int` or a numeric string.
- **`+`, `-`, `*` preserve scale**, so cents are never dropped: `19.99m + 0.01m`
  is `20.00`.
- `/` and `%` return the exact quotient normalized: `decimal(10) / 4` is `2.5`.
- Overflow and divide-by-zero raise, as with `int`.

## Integer division truncates

```ecko
7 / 2        # 3
7.0 / 2      # 3.5
float(7) / 2 # 3.5
```

A common surprise. Convert one operand when you want a fraction.

## JSON

JSON has no exact-decimal type. `json_encode` emits a decimal as a plain number
in its canonical text, and decoding gives back a float. A round trip through JSON
is float-precision - if exactness must survive transport, send a string.

## Maths

[`std.math`](../stdlib/math.md) has the constants and functions: `pi`, `e`,
`sqrt`, `sin`, `log`, `floor`, `clamp`, `gcd`, `isclose` and the rest.
