# Functions & lambdas

```ecko
fn add(a, b) = a + b                  # expression body
fn greet(name) = "Hello, {name}!"

fn factorial(n) {                     # block body
    if n <= 1 { 1 } else { n * factorial(n - 1) }
}

double = fn(x) x * 2                  # lambda
fetch = async fn(url) http.get(url)   # async lambda
```

`fn(params) body` is the canonical anonymous form. The pipe form `|x| x * 2`
still parses but is **deprecated**: [`ecko check`](../cli/check.md) warns and
[`ecko fmt`](../cli/fmt.md) rewrites it.

A `fn(x) { ... }` body is a **block**, except when the brace opens a map
literal - no statement can begin with `name :`, so there is no ambiguity:

```ecko
fn(x) { value: x }      # returns a map
fn(x) ({ value: x })    # the same thing, said explicitly
fn(x) { y = x + 1
        y * 2 }         # a block, because `y = ...` is a statement
```

[`ecko fmt`](../cli/fmt.md) canonicalises the first form to the second.

## Defaults and named arguments

```ecko
fn box(w, h, fill = "-") = fill * (w * h)

box(2, 3)              # positional
box(2, h: 3)           # named
box(2, 3, fill: "#")   # positional first, then named
```

Named arguments bind after positional binding. Passing a parameter twice, naming
one that does not exist, or putting a positional argument after a named one is an
error.

## Arity is checked at the call site

```
'box' expects 2..3 argument(s), got 4
'box' is missing required argument 'h'
```

[`ecko check`](../cli/check.md) finds these **before the program runs**, including
for built-ins. Passing `null` explicitly satisfies arity and does *not* trigger a
default - an explicit null is a value you chose.

## Closures capture their defining scope

They observe later updates and can mutate an outer `mut`:

```ecko
fn make_counter() {
    mut n = 0
    fn() {
        n = n + 1
        n
    }
}

next = make_counter()
next()      # 1
next()      # 2
```

The captured scope outlives the defining call. Named functions can be declared
inside another function, and plain, `async` and contracted nested functions all
capture the same lexical scope.

In parallel contexts the capture is a **snapshot** instead - see
[Variables & mutability](./variables.md#the-one-exception-parallel-workers).

## `fn` bindings are immutable

```ecko
fn f() = 1
f = 2               # error
let f = fn() 2      # legal
```

## `return`

Exits the enclosing function immediately. Often unnecessary, since a block
evaluates to its last expression, but useful as a guard:

```ecko
fn handle(x) {
    unless valid(x) { return error_response() }
    process(x)
}
```

## Contracts and tools

A function is where [contracts](../ai/contracts.md) attach:

```ecko
@requires(n > 0)
@ensures(result >= n)
fn grow(n) = n * 2
```

And where [`@tool`](../ai/tools.md) makes a function available to a model.
