# The value model

One `Value` type covers everything a program can hold: `null`, `bool`, `int`,
`float`, `decimal`, `string`, `bytes`, `list`, `map`, `struct`, functions, tasks,
channels and [cells](../concurrency/cell.md).

## Copy-on-write collections

Collections are reference-counted and shared until written to. So:

- **Cloning a collection is a counter bump**, not a copy. Passing a large list to
  a function costs nothing.
- **Writing to a shared collection copies it first**, so the other holder is
  unaffected.

The observable behaviour is plain **value semantics**:

```ecko
mut a = [1, 2, 3]
b = a
a[0] = 99
print(b[0])       # 1
```

There is no aliasing to reason about, and no `clone()` to remember. The
optimization is invisible except in that it makes the semantics affordable.

This is the mechanism behind [assignment through fields](../language/assignment.md)
requiring a mutable root: mutating a field is conceptually replacing the value
bound to the name.

## `cell` is the deliberate exception

```ecko
a = cell(0)
b = a             # the same cell
cell_set(b, 5)
cell_get(a)       # 5
```

A [cell](../concurrency/cell.md) shares on clone. That is precisely what lets
state survive being captured into a parallel worker, where everything else is
snapshotted. Sharing is a visible construct with its own name, rather than a
property of where a variable was declared.

## Share-nothing concurrency falls out of this

Because collections are values and cloning is cheap, giving each
[`pmap`](../concurrency/pmap.md) worker or [task](../concurrency/async.md) a
snapshot of its captured state is affordable. That is why data races are not a
category of bug in Ecko: the default is isolation, and it is not an expensive
default.

## Determinism

Maps are hash maps internally but **print, encode and iterate in sorted key
order**. Deterministic output is a design requirement, not a convenience - it is
what allows the test suite to assert on program output, including output derived
from `ai` calls in [mock mode](../ai/mock-mode.md).
