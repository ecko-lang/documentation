# Strings

Ecko strings are UTF-8, and every string operation is **character-indexed** -
never bytes - so multi-byte text behaves correctly everywhere.

```ecko
name = "Ada"
print("Hello, {name}!")   # {expr} interpolates - see Templates for the full story
```

A handful of the most common operations are global builtins (`upper`, `lower`,
`trim`, `split`, `join`, `replace`, `contains`, `starts_with`, `ends_with`,
`chars`, `lines`, `reverse`, `index_of`, `len`). The complete toolkit lives in
`std.string`:

```ecko
import std.string

string.title("the quick fox")        # "The Quick Fox"
string.pad_start("7", 4, "0")        # "0007"
string.substring("hello world", -5)  # "world" - negatives count from the end
```

Every example on this page runs offline - string operations never touch the
network or an LLM.

## Slicing

Strings, lists, and bytes slice with range syntax:

```ecko
s = "hello"
s[1..3]    # "el"    exclusive end
s[0..=2]   # "hel"   inclusive end
s[..3]     # "hel"   open start
s[2..]     # "llo"   open end
s[-3..]    # "llo"   negative indices count from the end
s[1..-1]   # "ell"
```

`slice(s, start, end)` is the same half-open range as a function, for when the
bounds are computed rather than written:

```ecko
slice("hello world", 0, 5)   # "hello"
slice("héllo", 1, 3)         # "él"   characters, not bytes
```

Slices are total: out-of-range bounds clamp (`s[2..99]` is `"llo"`) and a
reversed range is empty - a slice takes what's there, it never errors. Single
-index access (`s[i]`, `xs[i]`) stays strict and raises when out of bounds; use
`get(...)` when absence is expected.

## Raw strings

`r"..."` turns off interpolation and escapes, for text that is full of braces or
backslashes: CSS, regexes, format templates.

```ecko
css = r"body { margin: 0 }"        # braces stay literal
pat = r"\d+\.\d+"                  # no escaping the escapes
```

For anything containing double quotes, use the triple form. A single `r"..."`
ends at the first quote, so it can hold JSON's braces but not its quotes:

```ecko
r"""{"jsonrpc": "2.0", "method": "tools/list"}"""
```

That is the one to reach for when embedding JSON in a test or a fixture.
Without it you have to build a map and `json.encode` it, which is fine for
generated data and needless ceremony for a literal.

## Trim and split

`trim`, `trim_start`, and `trim_end` take an optional second argument - a set
of characters to strip instead of whitespace:

```ecko
trim("  hi  ")           # "hi"
trim("xxhixx", "x")      # "hi" - any char in the set, from both ends
```

`split` takes an optional limit capping the number of splits, and `rsplit`
counts that limit from the right (parts always come back left-to-right):

```ecko
split("a,b,c,d", ",", 2)                 # ["a", "b", "c,d"]

import std.string
string.rsplit("a,b,c,d", ",", 1)         # ["a,b,c", "d"]
```

## The full `std.string` surface

- **Case** - `upper`, `lower`, `capitalize`, `title`, `swapcase`,
  `eq_ignore_case(a, b)` (case-insensitive equality, Unicode lowercase-based)
- **Trim** - `trim(s, chars?)`, `trim_start(s, chars?)`, `trim_end(s, chars?)`,
  `trim_prefix(s, p)`, `trim_suffix(s, sfx)`
- **Pad** - `pad_start(s, width, fill?)`, `pad_end(s, width, fill?)`,
  `center(s, width, fill?)`, `zfill(s, width)` (zero-pad after a leading sign)
- **Extract** - `substring(s, start, end?)`, `char_at(s, i)` - negative indices
  count from the end
- **Search** - `contains`, `starts_with`, `ends_with`, `index_of`,
  `last_index_of`, `count(s, sub)`
- **Replace** - `replace(s, from, to)`, `replace_first(s, from, to)`
- **Split/join** - `split(s, sep, limit?)`, `rsplit(s, sep, limit?)`,
  `partition(s, sep)` / `rpartition(s, sep)` (split once into a guaranteed
  `[head, sep, tail]` 3-list - total destructuring), `split_whitespace`,
  `lines`, `join(list, sep)`, `chars`, `reverse`
- **Test** - `is_digit`, `is_alpha`, `is_alnum`, `is_space`, `is_ascii`,
  `is_upper`, `is_lower` - non-empty and every char in the class
  (Unicode-aware); `is_upper`/`is_lower` need one cased char and none of the
  opposite case; the empty string is false for every predicate
- **Info** - `len`, `is_empty`, `is_blank`, `repeat(s, n)`
- **Convert** - `from(x)` turns any value into a string

> **Note** - `import std.string` binds the name `string`, which shadows the
> global `string()` constructor in that scope. Use `string.from(x)` to convert,
> or import it aliased: `import std.string as s`.
