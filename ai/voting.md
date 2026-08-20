# Majority voting

```ecko fragment
best = ai[Sentiment] 5 "classify this review: {text}"
```

Runs 5 independent samples and returns the majority-coerced value. A quality dial
for noisy classifications, in one number.

## When it helps

Classification into a small set of options, where the model is usually right and
occasionally not. Voting turns "right 85% of the time" into something better
without changing the prompt, because the errors are usually not the same error.

## When it does not

- **Generation.** Five different summaries have no majority. Voting needs an
  answer space small enough for agreement to mean something.
- **A systematically wrong model.** If the model is confidently wrong about this
  input, all five samples agree and voting launders the error into apparent
  confidence. Voting reduces variance, not bias.

## The count

`n` is 1 to 25. Higher `n` costs linearly and improves sub-linearly; 3 or 5 is
usually the whole benefit.

## Cost

**Each sample runs its own retry loop.** `ai[T] 5 "..."` can spend up to 5 × 4 =
20 provider calls before returning.

Votes bypass the [cache](./caching.md) - identical cached responses would defeat
the point - but they do count against `ECKO_AI_MAX_CALLS`. This is the single
easiest way to multiply a bill by five without noticing, so set a budget.

## Combining

Cannot combine with `-> stream` (there is no partial majority) or with `using`
tools. Works with any type, including structs and enums.

## Offline

In mock mode every sample returns the same deterministic value, so the majority is
that value. The wiring is exercised; the variance-reduction is not, because there
is no variance.
