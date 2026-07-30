# Retry

```ecko
reply = retry(3, fn() ai "flaky prompt")
```

`retry(n, f)` calls the zero-argument function `f` and re-runs it on error, up to
`n` attempts total, with exponential backoff. It returns the first success, or
propagates the final error once the attempts are spent.

Backoff starts at `ECKO_RETRY_BASE_MS` (default 50ms) and doubles.

## Not just `ai`

`retry` wraps any failing operation:

```ecko
body = retry(5, fn() http.get(url).body)
row  = retry(3, fn() sql.query_one(db, "select 1"))
```

It is a general-purpose combinator that happens to be useful for model calls
because networks and rate limits are unreliable in the same way.

## Retry that is already happening

Two layers retry without being asked, and it is worth knowing which is which:

- **Coercion retries** - a typed `ai[T]` call that fails to coerce retries up to
  `ECKO_AI_MAX_RETRIES` (default 3), feeding the failure back.
- **Contract retries** - a failing [`@ensures`](./contracts.md) on an `ai`-bodied
  function re-runs the body, also bounded by `ECKO_AI_MAX_RETRIES`.

`retry(n, ...)` wraps *around* both. Nesting them multiplies:
`retry(3, fn() ai[T] "...")` is up to 3 × 4 = 12 calls. See
[Token budgeting](./budgeting.md) for the full arithmetic, and set
`ECKO_AI_MAX_CALLS`.

## What not to retry

Retrying only helps for **transient** failure - a timeout, a rate limit, a
connection reset. Retrying a deterministic failure spends the budget to get the
same error three times more slowly.

A malformed prompt, an invalid API key, a schema the model cannot satisfy, a
contract that is simply false: none of these improve with another attempt. Where
the distinction matters, catch and inspect rather than blanket-retrying:

```ecko
try {
    result = retry(3, fn() call())
} catch (e) {
    if e.kind == "rate_limit" { wait_and_escalate() } else { give_up(e) }
}
```

## Cancellation

`retry` does not accept an async callback, because it needs each attempt's result
before deciding on the next. To retry concurrent work, retry inside the task
rather than around it.
