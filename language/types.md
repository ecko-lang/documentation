# Values & types

Ecko is dynamically typed. `type_of(v)` names a value's type:

| type | literal | notes |
|---|---|---|
| `null` | `null` | absence |
| `bool` | `true`, `false` | |
| `int` | `42` | 64-bit signed, **checked** arithmetic |
| `float` | `3.14` | IEEE-754 double |
| `decimal` | `19.99m` | exact base-10, for money |
| `string` | `"hi"` | UTF-8, character-indexed |
| `bytes` | `b"\x01"` | binary data |
| `list` | `[1, 2]` | |
| `map` | `{ a: 1 }` | |
| `struct` | `Circle(3)` | from a [`type`](./type-definitions.md) declaration |

Functions are values too (`fn`, `native_function`).

## Truthiness

`false` and `null` are falsy. So are `0`, `""`, `[]`, `{}` and `b""` - the empty
value of each type.

## No implicit conversion between kinds

```ecko
"count: " + 5  # error
"count: {5}"  # interpolate instead
string(5) + " items"  # or convert explicitly
```

Ecko does not concatenate a number onto a string for you. The same stance applies
to [bytes](./bytes.md) (`bytes + string` is an error) and
[secrets](./secrets.md) (`"x" + secret` is an error): where two kinds of thing
meet, the source says which way the conversion goes.

Numbers do mix, with one hard rule: `int` and `decimal` mix and give `decimal`,
`int` and `float` mix and give `float`, and **`decimal` with `float` is an
error** - a binary float must never silently contaminate an exact value. See
[Numbers](./numbers.md).

## Conversions

```ecko fragment
int("42")        float("3.5")     string(99)
bool(1)          decimal("0.1")   bytes("hi")
list(b"\x01")    json_encode(v)   json_decode(s)
```

`int("abc")` raises rather than returning `0` or `null` - a failed conversion is a
failure, not a default.

## Collections are values

Binding a collection to a new name gives an independent value; there is no
aliasing to reason about. Copy-on-write underneath makes that cheap. See
[Assignment through fields & indexes](./assignment.md).

The single deliberate exception is [`cell`](../concurrency/cell.md).

## Access is strict

`xs[9]` and `m.missing` raise. `get(xs, 9)` and `get(m, "missing")` return `null`.
See [Structured data access](./data-access.md) - the distinction is a load-bearing
part of the [error dialect](./error-handling.md).

## Determinism

Maps are unordered internally but **print and JSON-encode with sorted keys**, and
map iteration yields pairs in sorted key order. So output is reproducible without
you sorting anything, which is what lets the test suite assert on it.
