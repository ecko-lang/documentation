# Pattern matching

```ecko
match value {
    0 => "zero"
    -1 => "negative one"
    n when n > 0 => "positive"
    _ => "negative"
}
```

An expression: it evaluates to the matched arm.

## What you can match

**Literals**, including `b"\x01"` byte literals.

**Guards** with `when`, evaluated with the arm's bindings in scope:

```ecko
n when n > 0 => "positive"
```

**Maps and structs**, by the subset of fields you name:

```ecko
match user {
    { role: "admin" } => "admin access"
    { role: "user", active: true } => "active user"
    _ => "unknown"
}
```

**Variants**, positionally by field order:

```ecko
type Shape = Circle { r: Int } | Square { side: Int }

match shape {
    Circle(r) => 3.14159 * r * r
    Square(side) => side * side
}
```

**`_`** matches anything.

## Bindings are arm-scoped

A name bound by a pattern exists only inside that arm. It cannot leak into or
clobber the surrounding scope, so reusing a familiar name in a pattern is safe.

## Exhaustiveness is checked

[`ecko check`](../cli/check.md) reports a `match` over a declared
[`type`](./type-definitions.md) that is missing a variant and has no `_`, **before
the program runs**. Adding a variant and forgetting one of its `match` sites is
found at analysis time.

This is the main reason to declare a `type` rather than passing strings around: a
string typo is a runtime surprise, a missing variant arm is a compile-time error.

## Matching tests, it never accesses

A pattern that does not match is not an error - it moves to the next arm. That is
the difference from [strict access](./data-access.md): `m.role` on a map without
`role` raises, while `{ role: "admin" }` as a pattern simply does not match.

So `match` is the natural tool for data whose shape you are unsure of, including
decoded JSON and model output.

## With `ai`

A typed call returning an enum drops straight into an exhaustive match:

```ecko
type Sentiment = Positive | Negative | Neutral

match ai[Sentiment] "classify: {review}" {
    Positive => thank(review)
    Negative => escalate(review)
    Neutral => file(review)
}
```

The model is constrained to the variants and the branches are checked. This is
the pattern the language is shaped around - a model call whose result is as
trustworthy as a local function's.

## Built-in unions

`Ok`/`Err` and `Some`/`None` are predefined for your own modelling. They are not
the error channel - see [Error handling](./error-handling.md).
