# Structured data access

```ecko
config = {
    server: { host: "localhost", port: 8080 },
    features: ["auth", "cache"],
}

print(config.server.port)     # 8080
print(config.features[0])     # "auth"
config.server.port = 9090     # path assignment; root must be mutable
```

## Keys, bare or quoted

A bare key must be an identifier - keywords are allowed, so `x.type` is fine. A
quoted key can be anything, which is what makes HTTP headers and hyphenated JSON
expressible inline:

```ecko
http.response(303, "", { location: "/", "set-cookie": "a=b; HttpOnly" })
```

`{ a: 1 }` and `{ "a": 1 }` are the same map. A quoted key is taken
**verbatim** - `{expr}` does not interpolate in key position, because a map
literal's shape is fixed at parse time. [`ecko fmt`](../cli/fmt.md) canonicalizes
to the bare form where the key is a plain identifier.

## Access is strict

```ecko
xs[9]          # index 9 is out of bounds (len 3)
m.key          # map has no key 'key'
s.field        # struct has no field 'field'
```

The nullable lookup is `get`:

```ecko
get(m, "key")       # null on a miss
get(xs, 9)          # null on a miss
```

**Reach for `get` when absence is expected, and indexing when it is not.** That
choice is the whole point: a strict read fails at the mistake, while a nullable
read that silently returns `null` propagates the problem into unrelated code. Rule
1 of the [error dialect](./error-handling.md) is that only the documented nullable
lookups return `null`.

[`match`](./pattern-matching.md) tests rather than accesses, so a non-matching
pattern is never an error - which makes it the right tool for data of uncertain
shape.

## Slicing

Strings, lists and bytes slice with range syntax. Strings slice **by character**,
so multi-byte UTF-8 is handled correctly:

```ecko
s = "hello"
s[1..3]      # "el"    exclusive end
s[0..=2]     # "hel"   inclusive end
s[..3]       # "hel"   open start
s[2..]       # "llo"   open end
s[-3..]      # "llo"   negative from the end
s[1..-1]     # "ell"

xs = [1, 2, 3, 4]
xs[1..3]     # [2, 3]
```

**Slices are total** where indexing is strict: out-of-range bounds **clamp**
(`s[2..99]` is `"llo"`, `s[7..9]` is `""`) and a reversed range is empty. Slicing
takes what is there and never errors.

That asymmetry is deliberate. `xs[i]` asks for one specific element, and its
absence is a mistake. `xs[a..b]` asks for a region, and "less than you asked for"
is a sensible answer.

`..=` requires an end index: `s[0..=]` is a parse error, and `s[0..]` is the open
form.

## Determinism

Maps print and JSON-encode with **sorted keys**, and map iteration yields pairs in
sorted key order. Output is reproducible without sorting anything yourself.
