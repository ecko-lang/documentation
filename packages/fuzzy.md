# fuzzy

String similarity: Levenshtein, Jaro-Winkler, Dice and Jaccard, plus best-match selection over a list. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/fuzzy
```

```ecko fragment
import fuzzy
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/fuzzy) - MIT.

---


## `fail(message)`

The error raised for inputs an algorithm cannot accept.

## `max2(a, b)`

The larger of two numbers.

## `min2(a, b)`

The smaller of two numbers.

## `levenshtein(a, b)`

The Levenshtein distance: the fewest single-character insertions, deletions
or substitutions that turn `a` into `b`.

Computed with two rows rather than the full matrix, so the memory cost is
the length of the shorter string rather than the product of both.

## `ratio(a, b)`

Levenshtein distance normalised to 0.0 (nothing in common) through 1.0
(identical), against the longer of the two strings.

## `hamming(a, b)`

The Hamming distance: how many positions differ. Both strings must be the
same length, which is the whole premise of the measure.

## `jaro(a, b)`

The Jaro similarity, 0.0 to 1.0.

Two characters count as matching only if they are the same and fall within
`max(len_a, len_b) / 2 - 1` positions of each other; a transposition is a
matched pair that arrived out of order, and counts half.

## `jaro_winkler(a, b)`

The Jaro-Winkler similarity: Jaro, boosted for strings that share a prefix.

The prefix counts at most four characters, and the boost only applies to
already-similar strings. Without the cap a long shared prefix would drag
every comparison toward 1.0.

## `bigrams(s)`

The bigrams of a string: every adjacent character pair.

## `dice(a, b)`

The Sorensen-Dice coefficient over bigrams, 0.0 to 1.0. Good for names and
titles, where word order varies but letter pairs persist.

## `jaccard(a, b)`

The Jaccard index over character sets: shared characters over distinct
characters. Order-blind and the cheapest of the four.

## `best_match(needle, candidates)`

The closest candidate to `needle`, as `{ value, score }`, or null when there
are no candidates. Scored with Jaro-Winkler, which suits the typo-correction
case this is usually reached for.

## `best_match_by(needle, candidates, scorer)`

`best_match` with the scorer of your choice - any `fn(a, b) -> float`.

## `top_matches(needle, candidates, limit)`

The `limit` closest candidates, best first, as `{ value, score }` records.

## `scored(value, score)`

One scored candidate. A named function because `fn(c) { value: ... }` would
parse its brace as a block rather than a map literal.

## `top_matches_by(needle, candidates, limit, scorer)`

`top_matches` with the scorer of your choice.
