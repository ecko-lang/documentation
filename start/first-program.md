# Your first program

This is the ten-minute path from an empty file to a typed, verified AI call. No
API key is needed for any of it.

## 1. Hello

```ecko
# hello.ecko
print("Hello, AI World!")
```

```bash
ecko hello.ecko
```

## 2. Values and functions

```ecko
name = "Ada"                  # a binding
mut count = 0                 # explicitly mutable
count = count + 1

fn greet(who) = "Hello, {who}!"   # single-expression function

print(greet(name))            # Hello, Ada!
```

Strings interpolate with `{expr}` directly. Functions can be one expression with
`=`, or a block with `{ }`.

## 3. Collections and pipelines

```ecko
scores = [3, 9, 4, 1]

top = scores
    |> filter(fn(s) s > 2)
    |> sort()
    |> reverse()

print(top)      # [9, 4, 3]
```

`|>` feeds the value on the left into the call on the right. It binds loosest of
all operators, so a pipeline reads top to bottom.

## 4. Your first `ai` call

`ai` is a keyword. There is nothing to import and nothing to configure:

```ecko
answer = ai "Name a colour"
print(answer)
```

Run it. With no API key you get `[AI Mock] Name a colour` - deterministic
[mock mode](./mock-mode.md), which is what makes the rest of this page testable
offline.

## 5. Typed output

An untyped call returns text. Ask for a type and you get that type:

```ecko
count = ai[Int] "How many days in a week?"
print(count + 1)              # arithmetic on the result, not on a string
```

The type is enforced by coercion through a schema. `ai[Int]` is an `Int` or the
call fails - it is never the string `"seven"`. Structs, enums and lists work the
same way:

```ecko
type Sentiment = Positive | Negative | Neutral

mood = ai[Sentiment] "The service was wonderful"
```

See [`ai` and typed output](../ai/typed-output.md) for the full set.

## 6. A contract

Types catch type errors. Contracts catch the rest:

```ecko
@ensures(len(result) <= 80, "must be at most 80 characters")
fn headline(article) = ai "Write a one-line headline for: {article}"

print(headline("A cat was rescued from a tree by a passing cyclist."))
```

If the model returns something too long, Ecko feeds the failure back and retries
rather than handing you bad output. Contracts can also be written in natural
language, checked by a model. See [Contracts](../ai/contracts.md).

## 7. Run it as a test

Rename the checks into a test file and `ecko test` runs them in forced mock
mode - deterministic, offline, no key:

```ecko
# hello_test.ecko
import std.test

test.case("greeting", fn() {
    test.eq(greet("Ada"), "Hello, Ada!")
})
```

```bash
ecko test
```

## Where to go next

- [Mock mode](./mock-mode.md) - how all of this ran without a key
- [Providers & configuration](../ai/providers.md) - adding a real key
- [The language](../language/statements.md) - Ecko as a general-purpose language
- [The REPL](./repl.md) - trying things without a file
