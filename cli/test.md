# `ecko test`

```bash
ecko test                  # discover and run everything
ecko test tests/           # an explicit path
ecko test --generate file.ecko   # draft tests for a file with AI
```

## Discovery

Two conventions, both honoured:

- `tests/*.ecko`
- `*_test.ecko` anywhere in the tree

A package that ships a release workflow usually keeps its test file at the root
as `<name>_test.ecko`, because a non-recursive archive step would not capture a
`tests/` directory.

## Writing a test

```ecko
import std.test

test.case("splits on commas", fn() {
    test.eq(split("a,b", ","), ["a", "b"])
})

test.case("rejects an empty name", fn() {
    test.err(fn() validate(""))
})
```

`test.eq`, `test.ok`, `test.err` and `test.fail` are the assertions. See
[`std.test`](../stdlib/test.md).

## Mock mode is forced

**`ecko test` ignores your API key.** Every `ai` call in a test run answers from
the deterministic [mock](../start/mock-mode.md), whether or not a provider is
configured.

This is not a convenience, it is the point. It means a test suite over an AI
pipeline is fast, free, offline, and identical on every machine - so the suite
can run on every commit, and a failure is a real regression rather than a model
having a different day. What mock mode cannot assert is answer *quality*; that
is what [contracts](../ai/contracts.md) are for, and they are evaluated in tests
too.

## Output and exit status

One line per case, a summary per file, and a non-zero exit if anything failed:

```
  ok splits on commas
  ok rejects an empty name
1 file(s), 2 case(s): 2 passed, 0 failed (0.01s)
```

## `--generate`

```bash
ecko test --generate parser.ecko
```

Reads the file and drafts a test file for it. It is a starting point, not a
substitute for deciding what the behaviour should be - read what it writes before
trusting it. With no provider configured this produces mock output, so it is one
of the few commands that genuinely needs a key.
