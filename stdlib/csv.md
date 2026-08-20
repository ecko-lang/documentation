# `std.csv`

```ecko fragment
import std.csv

rows = csv.parse(text)          # rows as column-keyed maps
text = csv.stringify(rows)
rows = csv.read("data.csv")
csv.write("out.csv", rows)
```

## Rows are maps

The first line is the header, and each row becomes a map keyed by column name:

```ecko fragment
for row in csv.read("people.csv") {
    print("{row.name} is {row.age}")
}
```

Better than positional access in the way that matters: inserting a column upstream
does not shift every index in your code.

## Columns are sorted on write

`csv.stringify` sorts columns, because Ecko maps are unordered - so output is
deterministic and diffable. If you need a specific column order, build the rows as
a list of lists and write it yourself.

## Everything is a string

CSV has no types. Every value parses as a string, including numbers:

```ecko fragment
row.age             # "42", not 42
int(row.age)        # 42
```

Convert explicitly, and be ready for a conversion to fail on real data - a blank
cell is `""`, not `null`, and `int("")` raises.

## Errors

Malformed input raises `{ kind: "parse", format: "csv" }`, with `path` from
`csv.read`.

## What it handles, and what it does not

Quoted fields, embedded commas and embedded newlines inside quotes all work.

CSV in the wild is not one format. Semicolon separators, a byte-order mark, CRLF
line endings, inconsistent column counts, `latin-1` encoding - any of these can
arrive. When they do, read the bytes and pre-process, or reach for
[`re`](./re.md)/[`string`](./string.md) directly.

For anything with real structure, prefer JSON, [TOML](./toml.md) or a
[database](./sql.md). CSV is a transport for tables of text, and treating it as more
than that is where the pain comes from.
