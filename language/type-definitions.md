# Type definitions

```ecko
type Shape = Circle { r: Int }
    | Square { side: Int }
type Color = Red | Green | Blue
```

A `type` declares a tagged union. Each variant is a constructor.

## Construction

```ecko fragment
c = Circle(3)          # positional, in field order
red = Red()            # a fieldless variant is still constructed
```

Both are `struct` values. Fields are read with `.`:

```ecko fragment
print(c.r)             # 3
```

Note that a bare `Red` without parentheses is the **constructor function**, not a
value. Call it.

## Matching

Variants match positionally by field order, which is where a `type` earns its
keep:

```ecko fragment
area = match shape {
    Circle(r) => 3.14159 * r * r
    Square(side) => side * side
}
```

[`ecko check`](../cli/check.md) verifies **exhaustiveness**: a variant with no arm
and no `_` is an error before the program runs. Adding a variant to a `type` and
forgetting a `match` somewhere is caught at analysis time rather than in
production.

Fieldless variants match by name:

```ecko fragment
match colour {
    Red => "stop"
    Green => "go"
    Blue => "cold"
}
```

## Built-in unions

`Result` (`Ok`/`Err`) and `Option` (`Some`/`None`) are predefined:

```ecko fragment
match parse(s) {
    Ok(v) => v
    Err(e) => default
}
```

They are **ordinary data types for your own modelling**, not the error channel.
Nothing in the standard library returns them - failures
[throw](./error-handling.md). Reach for them when a *value* legitimately has two
shapes, not to imitate error handling from another language.

## Types and `ai`

A declared type is a schema, which is what makes typed model output ergonomic:

```ecko fragment
type Sentiment = Positive | Negative | Neutral

mood = ai[Sentiment] "classify this review: {text}"

match mood {
    Positive => reply_warmly()
    Negative => escalate()
    Neutral => file()
}
```

The model is constrained to the variants, the result is coerced to one, and the
`match` over it is exhaustiveness-checked. A struct type works the same way, with
each field coerced to its declared type:

```ecko fragment
type Person = { name: String, age: Int }
p = ai[Person] "extract the person from: {text}"
```

In [mock mode](../ai/mock-mode.md) an enum returns its first variant and a struct
returns each field's mock, so the branch structure is exercised offline.

## What `type` is not

Not a static type system. Field types annotate the declaration and drive `ai`
schema generation and coercion; they are not checked on hand-written
construction. Ecko stays dynamically typed - see
[Values & types](./types.md) - and the verification story is
[contracts](../ai/contracts.md).
