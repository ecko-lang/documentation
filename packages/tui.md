# tui

Terminal UI composition for Ecko: width-aware pad/center/truncate, bordered boxes, and aligned tables over std.term.

```bash
ecko get github.com/ecko-lang/tui
```

```ecko
import tui
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.1 - [source](https://github.com/ecko-lang/tui) - MIT.

---


## `pad_end(s, w)`

Pad `s` on the right (left) to a visible width of `w`; wider stays unchanged.

## `pad_start(s, w)`

Right-align `s` in `w` columns by padding on the left. Width is measured in
visible columns, so ANSI colour codes do not count.

## `center(s, w)`

Center `s` in `w` columns; an odd leftover goes on the right.

## `truncate(s, w)`

Truncate to a visible width of `w`, marking the cut with an ellipsis. (A
truncated colored string loses its trailing escapes - truncate plain text.)

## `box(lines, opts)`

box(lines, opts?) -> a bordered box as one string. opts: border (style),
title, padding (spaces inside the verticals, default 1), min_width (total).

## `table(rows, opts)`

Render rows as an aligned text table. `opts` may carry `align` (a list of
`"left"`/`"right"` per column) and `gap` (the column separator, two spaces
by default). Column widths come from the widest visible cell.
