# Statements & syntax

**A newline ends a statement.** There are no semicolons.

```ecko
name = "Ecko"
count = 1
```

## Continuation

An expression continues across a newline only when one of these is true:

- the line ends with a binary operator
- the next line starts with `|>` or `.`
- you are inside `(...)` or `[...]`, where newlines are insignificant

```ecko fragment
total = 1 +
    2                    # trailing operator

result = data
    |> filter(pred)      # leading |>
    |> map(transform)

xs = [
    1,
    2,
]                        # inside brackets
```

These three rules cover the shapes that read well multi-line - arithmetic,
pipelines, and collection literals - without needing a line-continuation
character. Anything else is a new statement, so a missing operator is a syntax
error rather than a silently different program.

## Blocks are expressions

`{ ... }` evaluates to its last expression, which is why `if` and `match` can be
assigned:

```ecko fragment
status = if age >= 18 { "adult" } else { "minor" }
```

`for` and `while` evaluate to `null`; `loop` evaluates to its `break` value.

## Comments

`#` to end of line. No block comment form. `##` is a
[documentation comment](./comments.md).

## Formatting is not a choice

[`ecko fmt`](../cli/fmt.md) has one canonical style and no options. Any new syntax
in the language must round-trip through it byte-identically, which is enforced by
the compiler's own test suite over every example in the repository.

## Precedence, loosest to tightest

```
|>  <  or  <  and  <  comparisons  <  bor  <  bxor  <  band
    <  shl/shr  <  ..  <  + -  <  * / %  <  unary
```

`|>` binds loosest of everything, which is what makes a pipeline read as a
sequence of steps rather than needing parentheses at each stage. Bitwise
operators are [words](./bitwise.md) because `|` belongs to pipelines and lambdas,
and `ecko fmt` adds clarifying parentheses wherever bitwise mixes with arithmetic.
