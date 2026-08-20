# `std.term`

Colour, styles, cursor control and key input for the terminal.

```ecko fragment
import std.term

print(term.style("done", { fg: "green", bold: true }))
print(term.size())          # { rows, cols }
key = term.read_key()       # a single keypress
```

Every function returns a string (or, for control sequences, `""` when output is
not a terminal) rather than writing to the terminal directly, so a whole frame
can be built and printed in one go - flicker-free.

## Colour

One function per named colour, each taking the text to wrap:
`black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, `gray`
(alias `grey`), and a `bright_*` variant of each -
`bright_black`, `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`,
`bright_magenta`, `bright_cyan`, `bright_white`:

```ecko fragment
print(term.red("error"))
print(term.bright_cyan("info"))
```

`term.rgb(text, r, g, b)` and `term.color(text, n)` reach truecolor and the
256-colour palette directly, for anything the named set does not cover.

## `style`

One call for colour and attributes together: `fg`, `bg`, `bold`, `dim`,
`italic`, `underline`, `blink`, `reverse`, `strikethrough`. It emits the escape
sequences and resets afterwards, so styles cannot leak into later output.

The same attribute names are also their own functions - `term.bold(text)`,
`term.dim(text)`, `term.italic(text)`, `term.underline(text)`, `term.blink(text)`,
`term.reverse(text)`, `term.strikethrough(text)` - for a single attribute with
no colour.

## Hyperlinks

`term.link(url, text)` emits a clickable terminal hyperlink (OSC 8) in
terminals that support it, and falls back to plain `text` elsewhere.

## It honours `NO_COLOR`

Escape codes are emitted only when stdout is a TTY. Piping to a file or another
program produces clean text with no sequences in it - so `ecko report.ecko > out.txt`
does the right thing without a flag.

`NO_COLOR` (any value) forces colour off; `CLICOLOR_FORCE` forces it on, which is
what you want when deliberately piping into something that renders colour, like
`less -R`.

Because this is automatic, you do not need to check whether to colourize. Write the
styled output and let the module decide.

`term.strip(s)` removes ANSI escape sequences from a string, and `term.is_tty()`
reports whether stdout is a terminal - useful for the rare case where behaviour
should differ rather than just styling.

## Cursor movement

| call | effect |
|---|---|
| `term.up(n)`, `term.down(n)`, `term.left(n)`, `term.right(n)` | move the cursor `n` cells (default 1) |
| `term.goto(row, col)` | move to an absolute position, 1-indexed |
| `term.save_cursor()` / `term.restore_cursor()` | remember and return to a position |
| `term.hide_cursor()` / `term.show_cursor()` | toggle cursor visibility |

## Clearing

`term.clear()` clears the whole screen and homes the cursor. `term.clear_line()`
clears the current line, and `term.clear_down()` clears from the cursor to the
end of the screen.

## Escape sequences are order-sensitive

One trap worth stating: the sequence that erases a line erases the **whole** line,
including anything already written to it. So it goes *before* the content, not
after:

```ecko fragment
print_no_newline(term.clear_line() + "progress: {n}")
```

Getting that backwards produces a blank line and a mystery.

## Alternate screen

`term.alt_screen()` switches to the terminal's alternate buffer (what full-screen
tools like `less` and `vim` use), and `term.alt_screen(false)` switches back,
leaving the original scrollback untouched.

## Size

`term.size()` reports the terminal as `{ rows, cols }`. It has a sensible 80x24
fallback when there is no terminal, so code that uses it still works under a
pipe. `term.width(s)` is unrelated - it is the display width of a string once
ANSI codes are stripped, for aligning coloured output.

## Key input

`term.read_key()` reads a single keypress without waiting for Enter, blocking
until one arrives (or a passed timeout expires). That is what makes a menu or a
prompt possible. `term.poll()` checks whether a key is waiting without blocking,
and `term.raw_mode(true)` / `term.raw_mode(false)` toggle raw input mode
(no line buffering, no local echo) - always paired, and restored automatically
on exit even if the program errors.

## Building a UI

For width-aware padding, bordered boxes and aligned tables, use the
[`tui` package](../packages/tui.md), which is built on this module and handles
display width correctly - the character count of a string is not its width on
screen once you have wide characters in it.
