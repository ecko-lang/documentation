# semver

Semantic Versioning 2.0.0: parse, compare, sort and match version ranges. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/semver
```

```ecko
import semver
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/semver) - MIT.

---


## `fail(message)`

The error every entry point raises for input that is not a version.

## `is_numeric(s)`

Is `s` a run of one or more ASCII digits?

## `is_ident(s)`

Identifier characters allowed in a pre-release or build part: alphanumerics
and hyphen. Anything else - underscore, space, dot - ends the identifier.

## `numeric_field(s, what)`

A numeric field of the version core. Rejects a leading zero, so "01.1.1" is
invalid rather than quietly becoming 1.1.1.

## `identifiers(s, numeric_matters, what)`

Split a pre-release or build string on dots, checking each identifier.
Numeric pre-release identifiers become ints so they compare numerically;
build identifiers stay text, since build metadata is never compared.

## `identifier(p, numeric_matters, what)`

One identifier from a dot-separated list.

## `parse(text)`

parse("1.2.3-rc.1+build.5") -> { major, minor, patch, prerelease, build }.
Raises `{ kind: "semver" }` for anything that is not a valid version.

## `valid(text)`

Is `text` a valid version? The total form of `parse`.

## `string_of(p)`

Render a parsed version back to text, build metadata included.

## `cmp_int(a, b)`

-1, 0 or 1 for a < b, a == b, a > b.

## `cmp_identifier(a, b)`

Compare two pre-release identifiers. Numeric always ranks below
alphanumeric, and two numerics compare as numbers (spec §11.4.3).

## `cmp_prerelease(a, b)`

Compare two pre-release lists. An empty list means "this is a release",
which outranks any pre-release (§11.3); otherwise identifiers are compared
left to right and a longer list wins the tie (§11.4.4).

## `compare(a, b)`

compare(a, b) -> -1, 0 or 1. Accepts text or already-parsed versions.
Build metadata is ignored, exactly as the spec requires (§10).

## `sort(versions)`

Ascending order by precedence.

`sort_with` takes the comparator directly. `sort_by` could not express this:
a pre-release list mixes numeric and alphanumeric identifiers whose ordering
depends on their types, which is not a value any key function can return.

## `eq(a, b)`

a == b by precedence, ignoring build metadata.

## `gt(a, b)`

a > b by precedence.

## `lt(a, b)`

a < b by precedence.

## `inc(text, part)`

inc("1.2.3", "minor") -> "1.3.0". Bumping drops any pre-release and build
metadata: they described the version being left behind, not the new one.

## `parse_range(text)`

Expand a range string into alternatives, each a list of comparators.
`{ op, version }`, where op is one of >= > <= < =.

## `comparators(alt)`

One alternative: whitespace-separated terms, each expanded to comparators.

## `expand_term(term)`

A single term to the comparators it stands for. `^` and `~` and `*` are
shorthand for a pair of bounds; the explicit operators pass through.

## `strip_op(term, n)`

Drop an `n`-character operator prefix.

## `caret(text)`

`^1.2.3` allows changes that do not modify the leftmost non-zero number, so
the upper bound moves depending on where that digit is: ^1.2.3 stops at
2.0.0, ^0.2.3 at 0.3.0, ^0.0.3 at 0.0.4.

## `tilde(text)`

`~1.2.3` allows patch-level changes: at least 1.2.3, below 1.3.0.

## `matches_comparator(version, c)`

Does one comparator hold for `version`?

## `satisfies(version, range)`

satisfies("1.5.0", "^1.2.3") -> true.

A pre-release only ever matches a range that mentions one at the same
major.minor.patch. Without that rule `^1.0.0` would quietly accept
`2.0.0-alpha`, which is the behaviour every package ecosystem regrets.

## `alternative_holds(v, version, alt)`

Every comparator in an alternative must hold, plus the pre-release rule.

## `mentions_same_prerelease(v, c)`

Does this comparator name a pre-release on the same core version?

## `max_satisfying(versions, range)`

The highest version in `versions` that satisfies `range`, or null.

## `min_satisfying(versions, range)`

The lowest version in `versions` that satisfies `range`, or null.
