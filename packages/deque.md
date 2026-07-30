# deque

A double-ended queue for Ecko: push/pop/peek at both ends, amortized O(1). Immutable two-stack deque. Pure - no capabilities.

```bash
ecko get github.com/ecko-sh/deque
```

```ecko
import deque
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.9.4 - [source](https://github.com/ecko-sh/deque) - MIT.

---


## `new()`

new() -> an empty deque. Deques are values, so every operation returns a
new one rather than mutating.

## `size(q)`

size(q) -> item count.

## `is_empty(q)`

is_empty(q) -> true when size is 0.

## `push_front(q, x)`

push_front(q, x) -> a new deque with `x` at the front.

```ecko
q = push_front(new(), 1)
```

## `push_back(q, x)`

push_back(q, x) -> a new deque with `x` at the back.

## `peek_front(q)`

peek_front(q) -> the front item, or null if empty. Does not remove it.

## `peek_back(q)`

peek_back(q) -> the back item, or null if empty. Does not remove it.

## `pop_front(q)`

pop_front(q) -> [front, new_deque]. Raises kind-"value" if empty.

## `pop_back(q)`

pop_back(q) -> [back, new_deque]. Raises kind-"value" if empty.

## `to_list(q)`

to_list(q) -> the items as a plain list, front to back.

## `from_list(l)`

from_list(l) -> a deque holding `l`, front to back. Inverse of `to_list`.
