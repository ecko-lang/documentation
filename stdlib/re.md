# `std.re`

```ecko
import std.re

re.test("^a.c$", "abc")                  # true
re.find("[0-9]+", "abc 123 def")         # "123"
re.find_all("[0-9]+", "1 a 2 b 3")       # ["1", "2", "3"]
re.captures("(\\w+)@(\\w+)", "ada@ecko")  # ["ada@ecko", "ada", "ecko"]
re.captures_all(pattern, text)
re.split("[,;]", "a,b;c")                # ["a", "b", "c"]
re.replace("[0-9]", "#", "a1b2")         # "a#b#"
re.replace_first("[0-9]", "#", "a1b2")   # "a#b2"
```

## Captures

`captures` returns a list where index `0` is the whole match and the rest are the
groups, in order. A pattern that does not match returns `null`, so check before
indexing:

```ecko
c = re.captures(pattern, text)
unless c == null { print(c[1]) }
```

`captures_all` returns one such list per match.

## Escaping in patterns

A regex backslash needs escaping in a normal Ecko string, so `\d` is written
`"\\d"`. Raw strings avoid the doubling:

```ecko
re.test(r"\d+", "123")
```

Raw strings also suppress `{expr}` interpolation, which matters because `{2,3}` is
a regex repetition and would otherwise be read as an interpolation.

## Errors

An invalid pattern raises `{ kind: "parse" }`, catchable like any other
operational failure. Compile-time validation is not possible for a pattern built at
runtime, so validate patterns that come from configuration or user input:

```ecko
try { re.test(user_pattern, s) } catch (e) { reject("bad pattern") }
```

## When not to reach for regex

Parsing HTML, XML or JSON. Use [`html`](../packages/html.md),
[`xml`](../packages/xml.md) or [`std.json`](./json.md) - nested structure is not a
regular language, and a pattern that appears to work will fail on real input.

For fixed-string work, `contains`, `starts_with`, `split` and
`string.partition` are faster and clearer than a pattern.
