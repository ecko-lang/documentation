# heap

A priority queue (min-heap) for Ecko: push/pop/peek, heapify, and top-k. Immutable skew heap. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/heap
```

```ecko
import heap
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.9.5 - [source](https://github.com/ecko-lang/heap) - MIT.

---


## `new()`

new() -> an empty heap. Heaps are values, so every operation returns a new
one rather than mutating.

## `is_empty(h)`

is_empty(h) -> true when size is 0.

## `size(h)`

size(h) -> item count.

## `push(h, priority, value)`

push(h, priority, value) -> a new heap with the item added.

## `peek(h)`

peek(h) -> [priority, value] of the minimum, or null if empty.

## `pop(h)`

pop(h) -> [ [priority, value], new_heap ]. Raises kind-"value" if empty.

## `from_list(pairs)`

from_list(pairs) -> a heap built from [priority, value] pairs.

## `top_k(items, k)`

top_k(items, k) -> the k smallest values of a plain list, ascending.
