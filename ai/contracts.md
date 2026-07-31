# Contracts

Types catch type errors. Contracts catch the rest.

```ecko
@requires(x > 0)
@ensures(result > x)
fn increment(x) = x + 1
```

`@requires` runs before the body with the parameters in scope. `@ensures` runs
after, with the parameters **and** `result` in scope. A false condition raises.

## Why this matters for `ai`

An `ai` call can return the right *type* and the wrong *answer*. A contract is
where you say what right means:

```ecko
@ensures(len(result) <= 80)
fn headline(article) = ai "Headline for: {article}"
```

When the contract fails on an `ai`-bodied function, Ecko **feeds the failure back
and retries** rather than returning output you already know is wrong. That is the
loop you would otherwise write by hand at every call site.

## Natural-language contracts

A string condition is verified by a model:

```ecko
@ensures("result is a valid email address")
fn extract_email(text) = ai "Find the email in: {text}"
```

This is genuinely useful for properties you cannot express as code. **Be
clear-eyed about what it is:**

- A boolean contract is a **deterministic guarantee**. A string contract is a
  **probabilistic judgment**. Prefer boolean wherever the property is
  expressible - `len(result) <= 80` beats `"result is short"` every time.
- **In mock mode string contracts always pass.** They cannot catch anything
  offline. Boolean contracts work identically on and offline.
- Each attempt adds a verification call.

## The cost, stated plainly

Every `@ensures` retry of an `ai`-bodied function is a paid call, and the two
retry layers **compound**. A typed `ai` body inside a failing contract can retry
coercion (up to 1+3 calls) on each of up to 1+3 contract attempts - **worst case
16 calls for one invocation**, plus one verification call per attempt for a string
contract.

`ECKO_AI_MAX_CALLS` is the hard stop. Set it in production, so a contract failing
on a hot path fails fast instead of spending.

## Privacy

A string contract sends the checked value to a model. For `@ensures` that is the
function's result; for `@requires` it is the arguments. If either can contain
personal data or a credential, use a boolean contract - the verification call is a
data egress like any other.

## The direction of travel

Contracts are honest about being runtime checks today. The North Star is a
compiler that can discharge some of them statically, which is why they are written
as declarations rather than as assertions in the body: a declaration is something
a checker can read.

For now the useful framing is **verification is a spectrum**. Types catch type
errors cheaply and completely. Boolean contracts catch semantic errors
deterministically at runtime. String contracts catch fuzzy properties
probabilistically, at a price. Reach for the cheapest one that expresses what you
mean.
