# Assignment through fields & indexes

Assignment reaches into structures. **The root binding must be mutable.**

```ecko
mut user = { name: "Alice", tags: ["a"] }

user.name = "Bob"
user.tags[0] = "admin"
user.profile.city = "Cairo"     # nested paths work
```

## Why the root must be mutable

```ecko
let user = { name: "Alice" }
user.name = "Bob"               # error
```

Ecko collections have **value semantics**: a map is a value, not a reference to
one. So mutating a field is conceptually replacing the whole value bound to the
name - which is exactly what `let` forbids. The rule falls out of the value
model rather than being a separate restriction to remember.

## Value semantics, briefly

```ecko
mut a = [1, 2, 3]
b = a
a[0] = 99
print(b[0])       # 1 - b is an independent value
```

Binding does not alias. Underneath, collections are reference-counted and copied
only when a shared one is written to, so this costs nothing to pass around and
copies only when it must. The observable behaviour is plain value semantics.

The exception is [`cell`](../concurrency/cell.md), which shares deliberately.

## Bounds and keys are strict

```ecko
mut xs = [1, 2, 3]
xs[9] = 0         # error: index 9 is out of bounds (len 3)
```

Assignment does not grow a list, and it does not create a missing intermediate
map. Use `push` to extend, and `insert` to add a key:

```ecko
xs = push(xs, 4)
m  = insert(m, "key", value)
```

Both return a new value rather than mutating in place, which is the functional
idiom and composes with pipelines. Path assignment is the imperative shorthand
for when that reads better.
