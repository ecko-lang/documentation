# `std.random`

Two generators in one module, and the distinction matters.

```ecko
import std.random

random.seed(42)                 # reproducible sequence
random.int(1, 6)
random.float()
random.choice(xs)
random.shuffle(xs)

random.bytes(32)                # CSPRNG: OS entropy
random.token()                  # 32-byte url-safe token
```

## The seedable RNG

`seed`, `int`, `float`, `choice`, `shuffle`. For simulations, sampling, test
fixtures, jitter - anywhere you might want to reproduce a run.

**`random.seed(n)` seeds a process-wide RNG.** Concurrent workers share it, so
seed once at startup if you want reproducibility, and do not expect a
[`pmap`](../concurrency/pmap.md) over seeded work to be deterministic in ordering.

## The CSPRNG

`random.bytes(n)` and `random.token(n)` draw from **OS entropy**, not the seedable
RNG. They stay unpredictable even after `random.seed`, which is the entire point:

```ecko
random.seed(1)
random.int(1, 100)      # predictable - that is the feature
random.token(32)        # still unpredictable - that is also the feature
```

Use these, and only these, for session tokens, CSRF tokens, API keys,
password-reset links and salts. `random.token` returns url-safe base64 with no
padding, ready for a cookie or a URL.

## Getting this wrong

A token generated from a seedable RNG is guessable by anyone who can work out the
seed - and seeds are often the clock. This is a real and recurring vulnerability
class in other ecosystems, which is why the split here is two named functions
rather than a parameter you might forget.

The rule of thumb: **if guessing the value would be a security problem, use
`bytes` or `token`.**

## Passwords are not this module

Hashing a password is [`std.hash`](./hash.md) - `hash.password` and `hash.verify`,
Argon2id with a per-call salt. Do not build your own from `random` and a digest.
