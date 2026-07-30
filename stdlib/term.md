# `std.term`

Colour, styles, cursor control and key input for the terminal.

```ecko
import std.term

print(term.style("done", { color: "green", bold: true }))
print(term.cols())          # terminal width
print(term.rows())
key = term.read_key()       # a single keypress
```

## `style`

One function for colour and attributes: `color`, `bg`, `bold`, `dim`, `italic`,
`underline`. It emits the escape sequences and resets afterwards, so styles cannot
leak into later output.

## It honours `NO_COLOR`

Escape codes are emitted only when stdout is a TTY. Piping to a file or another
program produces clean text with no sequences in it - so `ecko report.ecko > out.txt`
does the right thing without a flag.

`NO_COLOR` (any value) forces colour off; `CLICOLOR_FORCE` forces it on, which is
what you want when deliberately piping into something that renders colour, like
`less -R`.

Because this is automatic, you do not need to check whether to colourize. Write the
styled output and let the module decide.

## Size

`cols()` and `rows()` report the terminal size, for laying out output that should
fit. They have a sensible fallback when there is no terminal, so code that uses
them still works under a pipe.

## Key input

`read_key()` reads a single keypress without waiting for Enter. That is what makes
a menu or a prompt possible.

## Escape sequences are order-sensitive

One trap worth stating: the sequence that erases a line erases the **whole** line,
including anything already written to it. So it goes *before* the content, not
after:

```ecko
print_no_newline(term.clear_line() + "progress: {n}")
```

Getting that backwards produces a blank line and a mystery.

## Building a UI

For width-aware padding, bordered boxes and aligned tables, use the
[`tui` package](../packages/tui.md), which is built on this module and handles
display width correctly - the character count of a string is not its width on
screen once you have wide characters in it.
