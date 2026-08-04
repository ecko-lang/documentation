# Global builtins reference

Around 95 functions are always in scope, with no import.

## Collections

**Transform:** `map`, `filter`, `reduce`, `flatten`, `zip`, `enumerate`, `chunk`,
`window`, `unique`, `reverse`, `sort`, `sort_by`, `sort_with`, `group_by`,
`partition`, `frequencies`, `select`.

**Access:** `first`, `last`, `take`, `drop`, `slice`, `get`, `len`, `contains`,
`index_of`, `find`, `count`, `any`, `all`, `sum`, `min`, `max`, `empty_map`,
`keys`, `values`.

**Build:** `push`, `pop`, `set`, `insert`, `remove`, `range`, `list`.

Three of those are easy to mix up:

- `set(coll, key, value)` **replaces**; `insert` **splices** a new element in and
  the list gets longer. On a map both set the key. Reaching for `insert` when you
  meant `set` changes the length without saying so.
- `drop(list, n)` is the complement of `take`, so `take(n) + drop(n)` rebuilds the
  input. `slice(list, start, end)` is the half-open range, with out-of-range
  bounds clamped rather than raised.
- `sort_by` takes a **key**; `sort_with` takes a **comparator** returning a
  negative number, zero or a positive one. Reach for `sort_with` when the order
  cannot be reduced to a key - a comparison whose answer depends on the operands'
  types, for instance.

**Parallel:** [`pmap`](../concurrency/pmap.md).

`get` is the **nullable** lookup - `get(m, k)` and `get(xs, i)` return `null` on a
miss, where `m.k` and `xs[i]` raise. See
[Structured data access](../language/data-access.md).

## Strings

`upper`, `lower`, `trim`, `split`, `join`, `replace`, `contains`, `starts_with`,
`ends_with`, `chars`, `lines`, `reverse`, `index_of`, `len`, `escape_html`.

`is_blank` is **not** a global - it lives in [`std.string`](./string.md).

The full toolkit is [`std.string`](./string.md).

## Numbers and conversion

`int`, `float`, `decimal`, `bool`, `string`, `bytes`, `abs`, `floor`, `ceil`,
`round`, `pow`, `sqrt`, `min`, `max`, `sum`, `approx`, `type_of`, `is_null`.

`approx(a, b, eps?)` is tolerance comparison for floats - `==` on floats is exact
IEEE. See [Numbers](../language/numbers.md).

## JSON

`json_encode`, `json_decode`. File forms are in [`std.json`](./json.md).

## AI

`embed`, `embed_all`, `cosine`, `tokens`, `cost`, `retry`, `session`, `uuid`.

See [Embeddings](../ai/embeddings.md), [Budgeting](../ai/budgeting.md),
[Retry](../ai/retry.md), [Sessions](../ai/sessions.md).

## Concurrency

`cell`, `cell_get`, `cell_set`, `cell_update`, `channel`, `send`, `recv`,
`try_recv`, `close`, `select`, `cancel`, `sleep`, `pmap`.

See [`cell`](../concurrency/cell.md) and [Channels](../concurrency/channels.md).

## Secrets

`secret`, `reveal`, `is_secret`. See [Secrets](../language/secrets.md).

## Errors and assertions

`error`, `assert`. See [Error handling](../language/error-handling.md).

## Output

`print`, `print_no_newline`, `read_file`, `write_file`.

## Python escape hatch

```ecko
result = py("[x*2 for x in range(5)]")
```

`py(...)` evaluates Python in a persistent worker process, for the case where a
library exists there and nowhere else. It is the deliberate escape hatch: reaching
for it stays inside your Ecko program rather than becoming a separate service.

It needs Python on the machine, which is the one place Ecko's "one binary, nothing
to install" promise does not reach - so treat it as a bridge, not a foundation.

## Shadowing

Assigning to a builtin name **shadows** it in the current scope rather than
erroring, so `sum = 0` is always safe. [`ecko check`](../cli/check.md) warns,
because it is usually accidental. Reach the original through `core.*`:

```ecko
export fn get(c, key) { ... }
fn internal(m, k) = core.get(m, k)
```

## Arity

Every builtin's arity is checked at the call site by `ecko check`, before the
program runs - so a wrong argument count is caught rather than raising mid-run.
