# Templates

`template` defines a function whose body is a template string - the natural
home for prompts, and for any other generated text.

```ecko
template summarize(text, tone = "neutral") = """
    You are an editor. Summarize the following in a {tone} tone.

    <input>
    {text}
    </input>
"""

# Runs offline in mock mode with no API key - a deterministic placeholder
# comes back until you set ECKO_API_KEY.
article = "The board approved the budget on Tuesday."
result = ai summarize(article, tone: "formal")
```

Template bodies support control flow:

```ecko
template report(title, items) = """
    == {title} ==
    {for item in items}
    - {item.name}: {item.count}
    {end}
    {if items == []}
    (nothing to report)
    {end}
"""
```

- `{expr}` interpolates a value into the text.
- `{for x in expr}...{end}` repeats a block once per item.
- `{if cond}...{else}...{end}` branches.
- A directive alone on its own line disappears from the output (its
  indentation and newline go with it); an inline directive affects only its
  own text.
- `{input expr}` renders the value wrapped in `<input>` delimiters, with any
  embedded `</input>`/`<input>` sequences neutralized - the safe way to put
  untrusted data into an `ai` prompt (see "Prompt safety" below).
- Templates are ordinary functions - first-class values, callable anywhere a
  string is expected, and the natural way to build reusable `ai` prompts.
- Use `\{` for a literal `{`.

## Prompt safety: `@untrusted`

A prompt often embeds data from outside the program - an HTTP response, a
file, user input, the output of an earlier `ai` call. That data can contain
text written to override your instructions ("ignore the above and..."). The
static analyzer can catch the common mistake of dropping that kind of data
into a prompt through a plain `{expr}` hole, where the model has no way to
tell it apart from your own instructions.

The safe, checked pattern is a `template` whose parameter is marked
`@untrusted` and rendered with the `{input}` guard. `ecko check` verifies the
guard is there - rule `untrusted-in-prompt` - and warns if you render the same
parameter through a plain `{expr}` hole instead. `{input ...}` is only
available inside a `template` body; it wraps the value in `<input>` delimiters
so the model treats it as data:

```ecko
template reply(@untrusted m) = "answer: {input m}"  # ok
template reply(@untrusted m) = "answer: {m}"  # warning: use {input m}
```

`@untrusted` also works on a `let` binding or an ordinary function parameter,
and taint propagates through derived `let`s. A marked value warns wherever it
reaches an `ai` prompt, as a conservative audit:

```ecko fragment
@untrusted let body = http.get(url).body
ai "summary: {body}"   # warning (a plain ai string cannot use {input})
```

A few things worth knowing about v1:

- **Analysis-only.** `@untrusted` has no runtime effect - it is a marker read
  by `ecko check`, not a sanitizer and not a type.
- **Intraprocedural.** Tracking stops at a function or template boundary.
  Passing a tainted value into a function does not taint it there unless that
  function's own parameter is also marked `@untrusted`. The callee is not
  inspected, so a value marked at a call site still warns at the `ai` sink - the
  checked, warning-free path is to mark the `template` parameter and use
  `{input}` there.
- **A warning, not a gate.** `untrusted-in-prompt` never blocks a run - `ecko
  file.ecko` still executes; `ecko check` just flags the line.
- **Explicit-marker-only.** Nothing is tainted automatically, not even a
  `std.http` response - you mark the trust boundary yourself. Automatic
  source-tainting (tainting common untrusted sources by default) is a planned
  follow-up.

Every example on this page runs offline in mock mode: `@untrusted` and
`untrusted-in-prompt` are purely static, so they do not touch the LLM call
itself, and no `ECKO_API_KEY` is required to see the behavior.
