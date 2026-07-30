# `ai` and typed output

`ai` is a keyword. Nothing to import, nothing to configure.

```ecko
answer = ai "What is the capital of France?"
```

An untyped call returns text. The interesting form asks for a type:

```ecko
count = ai[Int] "How many words in: {text}"
print(count + 1)              # arithmetic, not string concatenation
```

`ai[Int]` is an `Int`. Not `"seven"`, not `" 7\n"`, not a JSON blob you have to
parse. The type is enforced by generating a schema from it, sending that schema to
the provider, and coercing the reply through it - and if coercion fails, the call
retries with the failure fed back before it gives up.

## The types you can ask for

```ecko
ai[Int] "how many?"
ai[Float] "what fraction?"
ai[Bool] "is this spam?"
ai[String] "rewrite this"

type Sentiment = Positive | Negative | Neutral
ai[Sentiment] "classify this review"          # one of the variants

type Person = { name: String, age: Int }
ai[Person] "extract the person from: {text}"  # a struct, fields coerced

ai[json<List<Int>>] "list three primes"       # a shaped JSON value
```

An enum returns a variant, so it slots straight into
[`match`](../language/pattern-matching.md) with exhaustiveness checked at
analysis time. A struct returns a struct with each field coerced to its declared
type.

## Why a keyword and not a library

Because the alternative is worse in a specific way. A library call returns a
string and hands you the problem: parse it, validate it, decide what to do when it
is not what you asked for, remember to do all three at every call site. That
scaffolding is where AI programs actually break, and no amount of library design
removes it, because the language cannot see inside the string.

Making the model call a language construct means the schema, the coercion, the
retry, the budget, the trace and the [contract](./contracts.md) all live in one
place - and the type is checked before your next line runs.

## Pipelines

`ai` composes with `|>`, which feeds the left value in as prompt input:

```ecko
dates = text
    |> ai "Extract all dates"
    |> ai "Format as ISO 8601"
```

## Clauses

The `ai` expression takes modifiers, each documented on its own page:

| clause | meaning |
|---|---|
| `ai[T]` | [typed output](./typed-output.md) |
| `ai[T] n "..."` | [majority voting](./voting.md) over `n` samples |
| `... using [f, g]` | [tool calling](./tools.md) |
| `... with chat` | [a session](./sessions.md) |
| `... on img` | [image input](./multimodal.md) |
| `... -> stream` | [streaming](./streaming.md) |

Not every combination is legal - voting, tools, sessions and streaming are
mutually exclusive in the current version, and an illegal combination is a clear
parse error rather than a surprise at runtime.

## No key required

Everything above runs offline. Without a provider, typed calls return
deterministic schema-valid values - see [Mock mode](./mock-mode.md).
