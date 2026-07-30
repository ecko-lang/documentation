# Control flow

```ecko
status = if age >= 18 { "adult" } else { "minor" }
unless ready { wait() }

for i in 0..10 { print(i) }
while condition { do_work() }

value = loop {
    n = n + 1
    if n * n > 50 { break n * n }
}
```

## `if` is an expression

It evaluates to the taken branch, which is why it can be assigned. There is no
ternary operator because there is no need for one.

## `unless`

`if` with the condition negated. An expression like `if`, with an optional
`else`, yielding `null` when nothing runs. It reads best as a guard:

```ecko
unless valid(x) { return err }
```

## Ranges

```ecko
0..10       # exclusive: 0 to 9
0..=10      # inclusive: 0 to 10
```

Ranges are lazy, so `for i in 0..1000000` does not build a list.

## `for`

```ecko
for x in items { }
for c in "hello" { }         # characters
for byte in b"\x01\x02" { }   # Ints
for (k, v) in config { }     # map pairs, sorted by key
for (i, x) in enumerate(xs) { }
```

**Destructuring is strict**: two or more parenthesized names bind each item's
elements, and every item must be a list of exactly that length or the loop
errors. Silent partial binding would be guessing. Use `_` for positions you do
not need:

```ecko
for (_, v) in config { print(v) }
```

Map iteration yields `[key, value]` pairs in **sorted key order**, so a loop over
a map is deterministic.

## `while` and `loop`

`while` tests before each iteration. `loop` runs until `break`, and evaluates to
the break value - which is the clean way to write "repeat until you find
something".

`for` and `while` evaluate to `null`.

## `break` and `continue`

Work in `for`, `while` and `loop`. Using one outside a loop is an error.
`break v` supplies a value to a `loop`.

## Iterating a channel

```ecko
for job in jobs { handle(job) }
```

Drains a [channel](../concurrency/channels.md) until it is closed. This is the
idiomatic consumer, and unlike `recv` it distinguishes a sent `null` from
end-of-channel.

## Budgeting a loop

`ECKO_MAX_STEPS` sets an opt-in step budget, so an accidental infinite loop or an
adversarial input degrades into a catchable error instead of hanging. Unset means
unlimited. See [Resource limits](./limits.md).
