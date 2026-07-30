# Destructuring bindings

Bind several names from a list at once.

```ecko
let (a, b) = [1, 2]           # a = 1, b = 2, both immutable
mut (x, y) = [10, 20]         # mutable

(x, y) = [y, x]               # bare form reassigns: a swap
let (q, r) = divmod(17, 5)
```

## Strict by design

The value must be a list of **exactly** that length:

```ecko
let (a, b) = [1, 2, 3]        # error: destructuring expected 2 elements, got 3
```

Silent partial binding would be guessing. A length mismatch is nearly always a
misunderstanding about what a function returns, and it is better to hear about it
at the binding than to debug a `null` three functions later.

## The rules

- **Two or more names**, parenthesized. A single name in parentheses is just a
  grouped expression, so `(a) = 1` is an ordinary assignment.
- **Names only**, no nesting.
- **`_` discards** a position: `let (_, v) = pair`.
- `let` and `mut` introduce new bindings; the bare `(a, b) = ...` form reassigns
  existing ones, and each name follows the usual rules - an immutable target is an
  error.

## Where it pays off

Functions that return a pair, which is a common shape in pure-Ecko code:

```ecko
let (head, sep, tail) = string.partition(line, "=")
```

`partition` always returns a 3-list, even with no match, specifically so this
destructure never fails.

## For loops destructure too

Same flat, strict form:

```ecko
for (k, v) in config { print("{k} = {v}") }      # map pairs, sorted by key
for (i, x) in enumerate(xs) { print("{i}: {x}") }
for (a, b, c) in triples { }
```

See [Control flow](./control-flow.md).
