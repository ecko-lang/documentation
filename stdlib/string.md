# `std.string`

The complete UTF-8 string toolkit. Every operation is **character-indexed**, so it
is correct for multi-byte text.

```ecko
import std.string

string.title("the quick fox")  # "The Quick Fox"
string.pad_start("7", 4, "0")  # "0007"
string.substring("hello world", -5)  # "world"
string.replace_first("a-b-c", "-", "/")  # "a/b-c"
string.count("banana", "na")  # 2
```

The most common operations are global built-ins already - `upper`, `lower`, `trim`,
`split`, `join`, `replace`, `contains`, `starts_with`, `ends_with`, `chars`,
`lines`, `reverse`, `index_of`, `len`. Import this module for the fuller set.

> **`import std.string` binds `string`**, shadowing the global `string()`
> constructor for the rest of the scope. Use `string.from(x)` to convert, or
> `import std.string as s` to keep `string()` free.

## Case

`upper`, `lower`, `capitalize` (first letter up, rest down), `title` (each word),
`swapcase`, and `eq_ignore_case(a, b)`.

`eq_ignore_case` compares Unicode lowercased forms. It does not perform full case
*folding*, so German `ß` does not compare equal to `ss`.

## Trim

```ecko fragment
string.trim(s)                  # whitespace
string.trim(s, "x")             # any character in the set
string.trim("xxhixx", "x")      # "hi"
string.trim_prefix(s, "www.")   # a fixed affix, once
string.trim_suffix(s, ".com")
```

`trim`, `trim_start`, `trim_end` take an optional character **set**, not a
substring - `trim(s, "ab")` strips any `a` or `b` from the ends.

## Pad

```ecko fragment
string.pad_start(s, 8)          # fill defaults to a space
string.pad_end(s, 8, ".")
string.center(s, 20, "-")       # odd leftover goes right
string.zfill("-5", 4)           # "-005"
```

`zfill` pads with zeros **after** any leading sign, which is the one case
`pad_start(s, w, "0")` gets wrong. A multi-character `fill` cycles and truncates to
the gap.

## Extract

```ecko fragment
string.substring(s, 1, 4)       # clamps
string.substring(s, -5)         # negative from the end
string.char_at(s, 0)            # errors out of range
```

`substring` clamps; `char_at` errors. Same asymmetry as
[slices versus indexing](../language/data-access.md).

## Code points

```ecko fragment
string.ord("A")     # 65
string.ord("𝄞")     # 119070 - a non-BMP character
string.chr(65)      # "A"
```

Scalar values, not bytes, so the pair round-trips for any character. `ord("")`
errors; `chr` errors on a negative value, above U+10FFFF, or in the surrogate
range.

## Search

`contains`, `starts_with`, `ends_with`, `index_of` and `last_index_of` (character
offset, or `-1`), `count(s, sub)` (non-overlapping).

## Split and join

```ecko fragment
string.split("a,b,c", ",", 1)       # ["a", "b,c"]   limit caps the splits
string.rsplit("a,b,c", ",", 1)      # ["a,b", "c"]   counted from the right
string.partition("k=v=w", "=")      # ["k", "=", "v=w"]
string.rpartition("k=v=w", "=")     # ["k=v", "=", "w"]
string.split_whitespace(s)
string.lines(s)
string.join(xs, ", ")
```

`partition` and `rpartition` split **once** and always return a 3-list, so a
destructure never fails:

```ecko fragment
let (key, sep, value) = string.partition(line, "=")
```

With no match, `partition` keeps the string in the head and `rpartition` in the
tail.

## Character-class tests

True only if the string is **non-empty** and *every* character is in the class:
`is_digit` (Unicode numeric), `is_alpha`, `is_alnum`, `is_space`, `is_ascii`.

`is_upper` and `is_lower` need at least one cased character and no cased character
of the opposite case - so `"A1!"` is upper, and `"123"` is neither.

**The empty string is `false` for every predicate**, one uniform rule. For "empty
or whitespace" use `string.is_blank`.

## Info and convert

`len`, `is_empty`, `is_blank`, `repeat(s, n)`, `from(x)`.

## From bytes

```ecko fragment
string.from_utf8(b)         # strict decode, catchable
string.from_utf8_lossy(b)   # opt-in replacement characters
```

See [Bytes](../language/bytes.md).
