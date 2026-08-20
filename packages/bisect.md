# bisect

Binary search over a sorted list: insertion points, membership, and order-preserving insert. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/bisect
```

```ecko fragment
import bisect
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/bisect) - MIT.

---


## `left(items, x)`

The leftmost position where `x` could be inserted with the list still
sorted. If `x` is already present, this is the index of the first copy, so
`left` is what you want for "where does this value start".

## `right(items, x)`

The rightmost position where `x` could be inserted with the list still
sorted. If `x` is present, this is one past the last copy, so
`right(xs, x) - left(xs, x)` counts the copies.

## `left_by(items, x, key)`

`left`, comparing `key(item)` rather than the item itself.

## `right_by(items, x, key)`

`right`, comparing `key(item)` rather than the item itself.

## `insert_left(items, x)`

A new list with `x` inserted at `left`, leaving the input untouched.

## `insert_right(items, x)`

A new list with `x` inserted at `right`, leaving the input untouched.

## `insert_by(items, item, key)`

A new list with `item` inserted by its key, keeping the list sorted.

## `at(items, x, index)`

Splice `x` into `items` at `index`.

## `has(items, x)`

Is `x` present? O(log n), unlike the linear `contains` builtin.

## `index(items, x)`

The index of the first `x`, or null when it is absent.

## `count(items, x)`

How many copies of `x` the list holds.
