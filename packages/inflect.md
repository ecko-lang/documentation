# inflect

URL slugs, English pluralisation, ordinals and identifier case conversion. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/inflect
```

```ecko
import inflect
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/inflect) - MIT.

---


## `fail(message)`

The error this package raises.

## `is_alpha(c)`

Is this character an ASCII letter?

## `is_digit(c)`

Is this character a digit?

## `is_upper(c)`

Is this an uppercase ASCII letter?

## `words(text)`

words("helloWorldAgain") -> ["hello", "world", "again"].

Splits on anything that is not a letter or digit, and additionally at a
lowercase-to-uppercase boundary. A run of capitals is kept together until the
last one, so `XMLHttpRequest` gives ["xml", "http", "request"] rather than
eleven single letters.

## `starts_word(cs, idx)`

Does a new word begin at `idx`? True at a lowercase-to-uppercase step
(`helloWorld`), and at the last capital of a run followed by a lowercase
letter (`XMLHttp` breaks before the H, not before the T).

## `capitalize(word)`

Capitalise the first character, leaving the rest alone.

## `translit_table()`

Accented Latin characters and what they become. Transliterating rather than
dropping matters: "Café Münster" stripped is "caf-mnster", which is
unreadable and collides with unrelated titles. Multi-character expansions
(ß to ss, æ to ae) are the reason this is a table and not arithmetic.

## `transliterate(text)`

Replace accented characters with their ASCII equivalents. Anything unknown is
left for `slug` to drop.

## `slug(text, opts = {})`

slug("Hello, World!") -> "hello-world".

Options: `separator` (default "-") and `max_length` (default 0, no limit).
A length limit cuts at a word boundary rather than mid-word, and never
leaves a dangling separator.

## `clip(parts, separator, max_length)`

Keep whole words while the joined result fits. Cutting mid-word would produce
a slug that reads as a different, wrong word.

## `opt(m, k, fallback)`

`get` with a default.

## `uncountable()`

Words whose plural is the same as their singular. Applying a rule to any of
these produces "sheeps" or "informations".

## `irregular()`

Irregular singular-to-plural pairs, in one direction; `singular` reverses
this table rather than keeping a second one that could drift out of step.

## `keeps_f()`

Words ending in -f or -fe that do NOT take -ves. English has both, and the
rule alone would give "rooves" and "chiefs" the same treatment.

## `o_takes_es()`

Words ending in -o that take -es. Most take a plain -s (photos, pianos), so
the shorter list is the exceptional one.

## `is_vowel(c)`

Is this a vowel?

## `tail(word, n)`

The last `n` characters of a word.

## `head(word, n)`

Everything but the last `n` characters.

## `match_case(original, result)`

Re-apply the casing of `original` to `result`: a leading capital stays a
leading capital, and an all-caps word stays all-caps. A CMS pluralises
headings and route names, so "Post" must not come back as "posts".

## `plural(word)`

The plural of a word. Case is preserved.

## `plural_rule(w)`

The regular rules, applied to an already-lowercased word.

## `singular(word)`

The singular of a word. Case is preserved.

## `singular_rule(w)`

The regular rules in reverse.

## `pluralize(count, word)`

"1 post" / "2 posts". The number is included; `word_for` gives just the word.

## `word_for(count, word)`

The right form of `word` for `count`, without the number.

## `ordinal(n)`

ordinal(21) -> "21st".

The rule is not "look at the last digit": 11, 12 and 13 take "th" despite
ending in 1, 2 and 3. That trap is the whole reason this function exists.

## `snake(text)`

snake_case.

## `kebab(text)`

kebab-case.

## `camel(text)`

camelCase - first word lowercase, the rest capitalised.

## `pascal(text)`

PascalCase - every word capitalised.

## `title(text)`

Title Case - every word capitalised, spaces between.

## `case_names()`

The shape names `to_case` accepts.

## `to_case(text, name)`

to_case(text, "snake"). An unknown name raises rather than passing the input
through, because a silent passthrough turns a typo into a subtle data bug.
