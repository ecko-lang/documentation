# `std.humanize`

Numbers and durations rendered for people.

```ecko fragment
import std.humanize

humanize.duration(3661000)     # "1 hour 1 minute"
humanize.size(1536000)         # "1.5 MB"
humanize.relative(then)        # "3 hours ago"
humanize.ordinal(3)            # "3rd"
humanize.plural(1, "file")     # "1 file"
humanize.plural(4, "file")     # "4 files"
```

## What each takes

- `duration(ms)` - milliseconds to prose.
- `size(bytes)` - bytes to a human unit.
- `relative(timestamp)` - a Unix-millisecond timestamp to "3 hours ago".
- `ordinal(n)` - `1st`, `2nd`, `3rd`, `11th`.
- `plural(n, word)` - the count with the word pluralized.

`ordinal` handles the English irregulars, which is the whole reason not to write it
inline: `11th` and `21st` are the cases people get wrong.

`plural` handles regular pluralization. Irregulars need your own word - it will not
guess that one mouse is several mice.

## For display only

These produce **lossy, locale-flavoured English**. Never parse them, never compare
them, and never store them:

```ecko fragment
print("uploaded {humanize.size(n)}")     # good
record({ size: humanize.size(n) })       # bad - store n
```

Store the number and humanize at the edge, where it is being read. The same value
then renders correctly regardless of what you later want it to look like.

## Determinism

`relative` depends on the current time, so output changes between runs. That makes
it unsuitable for anything whose output is asserted - see
[`ecko test`](../cli/test.md). Pass a fixed "now" or avoid it in tested output.
