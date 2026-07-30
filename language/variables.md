# Variables & mutability

```ecko
name = "Ecko"       # bare assignment: a mutable binding
name = "Echo"       # so reassignment is fine

mut count = 0       # explicitly mutable
count = count + 1

let ratio = 3.14    # immutable
# ratio = 1.0       # error: cannot reassign immutable variable
```

## Three forms, one rule

| form | reassignable |
|---|---|
| `x = v` | yes |
| `mut x = v` | yes |
| `let x = v` | no |

`let` is the constant. `mut` is the explicit-mutable marker, useful where you want
a reader to see that the value changes. A bare assignment is the informal middle -
convenient at the top of a script, and the reason `mut` is not required for
everything.

`const` is a **deprecated** alias for `let` - identical behaviour.
[`ecko check`](../cli/check.md) warns and [`ecko fmt`](../cli/fmt.md) rewrites it.

## Function bindings are immutable

```ecko
fn f() = 1
f = 2               # error
let f = fn() 2      # legal: an explicit redeclaration
```

Same for built-ins - except that assigning to a built-in name **shadows** it with
a new binding in the current scope rather than erroring:

```ecko
sum = 0             # fine anywhere; the builtin `sum` is untouched here
```

`ecko check` warns when you shadow a built-in, because it is usually accidental.
When it is deliberate - a module that exports `get` or `join` - reach the original
through `core.get`, `core.join` and so on.

## Shadowing and scope

A block introduces a scope. An inner binding shadows an outer one for the rest of
the block and does not affect it afterwards.

Closures capture their **defining scope**, so they observe later updates and can
mutate an outer `mut`:

```ecko
fn make_counter() {
    mut n = 0
    fn() {
        n = n + 1
        n
    }
}
```

The captured scope stays alive after the defining call returns, which is what
makes the counter work.

## The one exception: parallel workers

A closure running in [`pmap`](../concurrency/pmap.md), an
[async task](../concurrency/async.md) or an HTTP handler gets a **snapshot** of
captured variables. Mutating a captured `mut` changes only that worker's copy:

```ecko
mut count = 0
pmap(items, fn(i) { count = count + 1 })
print(count)        # still 0
```

That is share-nothing by construction - it is why data races are not a category of
bug here. When workers must share, use a [`cell`](../concurrency/cell.md).

## No silent nulls

Reading a name that was never defined is an error found by `ecko check` before the
program starts, not a `null` that propagates until something else breaks. The same
strictness applies to [collection access](./data-access.md).
