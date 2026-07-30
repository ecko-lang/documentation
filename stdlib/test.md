# `std.test`

```ecko
import std.test

test.case("splits on commas", fn() {
    test.eq(split("a,b", ","), ["a", "b"])
})

test.case("rejects an empty name", fn() {
    test.err(fn() validate(""))
})
```

Run with [`ecko test`](../cli/test.md).

## Assertions

| call | passes when |
|---|---|
| `test.eq(actual, expected)` | the two are equal |
| `test.ok(value)` | the value is truthy |
| `test.err(fn)` | calling `fn` raises |
| `test.fail(message)` | never - an explicit failure |
| `test.assert(cond, message?)` | the condition holds |
| `test.group(name, fn)` | groups cases under a heading |

`test.err` takes a **function**, not an expression, because the expression would
raise before the assertion could catch it.

## Discovery

`tests/*.ecko` and `*_test.ecko` anywhere in the tree. Both conventions work; see
[`ecko test`](../cli/test.md) for why packages sometimes use one over the other.

## `ai` in tests

**`ecko test` forces [mock mode](../ai/mock-mode.md)** and ignores your API key. So
a test over an AI pipeline is deterministic, offline and free:

```ecko
test.case("classifies sentiment", fn() {
    test.eq(classify("great service"), Positive())
})
```

`ai[Sentiment]` returns the first variant offline, so this asserts the *plumbing* -
that the call is wired up, the type coerces, and the branch is reachable. It does
not assert that the model is any good, which no offline test can.

For output quality, use [contracts](../ai/contracts.md): boolean contracts are
real checks and they run in tests identically to production.

## Determinism

Because assertions compare output, the usual rules apply: sort before comparing
where order is not guaranteed, and avoid wall-clock values in expectations. Maps
already iterate and encode in sorted key order, so map comparisons are stable.
