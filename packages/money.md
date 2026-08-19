# money

Currency amounts on Decimal: exact arithmetic, ISO 4217 minor units, and allocation that never loses a cent. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/money
```

```ecko
import money
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/money) - MIT.

---


## `fail(message)`

The error raised for a bad currency, a currency mismatch, or an impossible
division.

## `minor_unit_table()`

Currencies whose minor unit is not two decimal places (ISO 4217). Assuming
two everywhere is the classic bug: it makes yen a hundred times too small
and Kuwaiti dinar ten times too large.

## `minor_units(code)`

How many decimal places this currency uses. Unknown codes get 2, which is
right for most of the world and wrong loudly rather than quietly.

## `normalize_code(code)`

Uppercase a currency code and check its shape.

## `of(amount, code)`

An amount from a Decimal and a currency code.

## `parse(text, code)`

An amount from a string: `parse("19.99", "USD")`.

## `zero(code)`

Zero in the given currency.

## `to_minor(m)`

The amount as an integer count of minor units: 10.50 USD -> 1050.

## `from_minor(units, code)`

An amount from a count of minor units: 1050 with USD -> 10.50.

## `same_currency(a, b, what)`

Both operands must be the same currency. Adding dollars to euros is not a
rounding question, it is a missing exchange rate, so it fails.

## `add(a, b)`

a + b.

## `sub(a, b)`

a - b.

## `mul(m, factor)`

An amount scaled by a plain number.

## `neg(m)`

The amount negated.

## `abs_of(m)`

The amount without its sign.

## `sum(items, code)`

The total of a list. `code` gives the currency for the empty case, where
there is nothing to infer it from.

## `compare(a, b)`

-1, 0 or 1. Both must be the same currency.

## `eq(a, b)`

a == b.

## `lt(a, b)`

a < b.

## `gt(a, b)`

a > b.

## `is_zero(m)`

Is the amount exactly zero?

## `is_negative(m)`

Is the amount below zero?

## `split(m, n)`

Split into `n` parts that sum back to the original exactly.

## `allocate(m, ratios)`

Divide by ratio, in the currency's smallest unit, so nothing is lost.

The remainder is handed out one minor unit at a time from the first share
onward, rather than rounded away. Allocating $0.05 as 3:7 gives 0.02 and
0.03: the shares are as close to the ratio as whole cents allow, and they
still sum to five cents.

A negative amount allocates the same way with the sign carried through, so
a refund splits like the charge it reverses.

## `to_string(m)`

"10.50 USD", with the number of decimals the currency actually uses: yen
render whole, dinar to three places.
