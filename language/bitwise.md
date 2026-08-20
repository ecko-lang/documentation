# Bitwise & word operators

The bitwise operators are **words**, because `|` belongs to
[pipelines](./pipelines.md) and lambdas.

```ecko fragment
a band b        # AND
a bor b         # OR
a bxor b        # XOR
a shl 3         # shift left
a shr 2        # shift right (arithmetic, sign-extending)
bnot a          # complement
```

This is the same choice as `and`, `or` and `not`: where a symbol would be
ambiguous with something more common in this language, the operator gets a name.

## On `int`

Two's complement on 64 bits. **A shift amount outside `0..64` is an error**, not
a silent wrap - the C behaviour here is undefined in practice and a source of
real bugs. `shr` is arithmetic, so it sign-extends.

## On `bytes`

`band`, `bor` and `bxor` are element-wise and **require equal lengths**. `bnot`
complements each byte. Shifts do not apply.

```ecko fragment
key = b"\x5a\x5a\x5a\x5a"
masked = message bxor key
original = masked bxor key
```

Mixing `int` and `bytes` operands is a type error.

## Precedence

Between comparison and range - **looser than arithmetic**:

```ecko fragment
a + b shl 2        # means (a + b) shl 2
```

Relative order mirrors Python's: `band` tighter than `bxor` tighter than `bor`.

Because this trips people up,
[`ecko fmt`](../cli/fmt.md) **always prints clarifying parentheses** where bitwise
mixes with arithmetic. You do not have to remember the table; the formatter makes
the grouping visible in the source.

Full precedence, loosest to tightest:

```
|> < or < and < comparisons < bor < bxor < band < shl/shr < .. < + - < * / % < unary
```
