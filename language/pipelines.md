# Pipelines

`|>` feeds the value on the left into the call on the right.

```ecko fragment
result = data
    |> filter(pred)
    |> map(transform)
    |> sort()
```

Equivalent to `sort(map(filter(data, pred), transform))`, and considerably easier
to read: the steps are in the order they happen, one per line, and adding a stage
is adding a line rather than finding the right nesting depth.

## It binds loosest

`|>` has the lowest precedence of any operator, so a pipeline stage can contain
arithmetic, comparison and boolean logic without parentheses:

```ecko fragment
xs |> filter(fn(x) x > 2 and x < 10) |> len()
```

A leading `|>` also continues a statement across a newline, which is why the
multi-line form above needs no continuation marker.

## With `ai`

This is where pipelines and the language's purpose meet. The piped value becomes
the prompt input:

```ecko fragment
dates = text
    |> ai "Extract all dates"
    |> ai "Format as ISO 8601"
```

Each stage is a model call whose input is the previous stage's output. The same
shape works with types, so a pipeline can narrow from text to structure:

```ecko fragment
report = raw_email
    |> ai "Extract the complaint"
    |> ai[Severity] "How severe is this?"
```

## The argument position

The piped value is passed as the **first** argument, which is why the standard
library consistently takes its subject first - `filter(list, pred)`,
`replace(s, from, to)`, `insert(map, k, v)`. That consistency is what makes
arbitrary functions pipeable.

For a function whose subject is not first, use a lambda:

```ecko fragment
value |> fn(v) other(config, v)
```

## Parallel

Swap `map` for [`pmap`](../concurrency/pmap.md) and the stage runs in parallel:

```ecko fragment
summaries = docs
    |> pmap(fn(d) ai "Summarize: {d}")
    |> filter(fn(s) len(s) > 0)
```
