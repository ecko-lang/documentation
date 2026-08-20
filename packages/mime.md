# mime

Build MIME messages (multipart, attachments, RFC 5322) and look up media types by file extension. Pure - no capabilities.

```bash
ecko get github.com/ecko-lang/mime
```

```ecko fragment
import mime
```

Pure computation: it declares no capabilities, so it cannot touch the network, the filesystem or the environment.

Version 0.10.2 - [source](https://github.com/ecko-lang/mime) - MIT.

---


## `table()`

The extension-to-type table, lowercase extension without the dot. Exposed so
a caller can see exactly what is known rather than probing `type_for`.

Grouped in source order: text, structured data, documents, images, audio and
video, archives, fonts, then everything else. The groups are not marked with
comments inside the literal on purpose - `ecko fmt` hoists a comment out of a
map literal and then reports the file as unformatted for ever after (core
card 34b0992f).

## `default_type()`

The fallback for anything the table does not know.

## `extension_of(path)`

The lowercase extension of `path`, without the dot, or "" if it has none.
Only the final component is considered, so a dot in a directory name cannot
be mistaken for an extension.

## `type_for(path)`

type_for("photo.png") -> "image/png". Case-insensitive, path-aware, and
falls back to application/octet-stream for anything unrecognised.

## `preferred_extensions()`

The extension to use when a type has several. Written out rather than
derived by scanning `table()`: several types map from more than one
extension (image/jpeg from both "jpg" and "jpeg", text/plain from both "txt"
and "ecko"), and Ecko maps are unordered, so a scan would pick a different
answer run to run.

## `extension_for(content_type)`

extension_for("image/png") -> "png", or null when nothing maps to it. Any
parameters are ignored, so "text/plain; charset=utf-8" still answers "txt".
application/octet-stream deliberately maps to null: it is the fallback for
unknown bytes, not a type with a file extension.

## `trim_type(content_type)`

Strip any parameters from a media type: "text/plain; charset=utf-8" ->
"text/plain".

## `header_safe(value)`

Strip CR and LF from a header value. This is the email equivalent of HTTP
response splitting: a newline inside a Subject or a filename would end that
header and start an attacker-chosen one, so a `Bcc:` smuggled into a subject
becomes a real recipient. Folding would also be valid per RFC 5322, but
stripping keeps the value on one line and cannot be misparsed.

## `crlf(text_body)`

Normalize any mix of line endings to the CRLF that RFC 5322 requires.

## `message(spec)`

Start a message. `spec` carries the envelope: { from, to, subject, date?,
headers? }, where `to` may be a string or a list of addresses. Parts are
added with `text`, `html` and `attach`.

## `normalize_to(to)`

`to` accepts one address or a list; both render as a comma-separated header.

## `text(msg, body)`

Add a text/plain part.

## `html(msg, body)`

Add a text/html part. A message carrying both text and html renders as
multipart/alternative, in the order added, so put the plain text first: a
reader picks the last part it understands.

## `quoted_filename(name)`

A filename as it appears inside `filename="..."`. Stripping CR and LF stops
a new header line; escaping backslash and quote stops the value ending its
own quoted string, which would put attacker text where a parameter goes.

## `attach(msg, filename, data)`

Attach a file. The media type is inferred from the filename's extension,
falling back to application/octet-stream. `data` may be bytes or a string.

## `attach_as(msg, filename, data, content_type)`

`attach` with the media type given explicitly, for content whose extension
does not describe it.

## `add_part(msg, part)`

Append a prepared part. Exposed for parts this package does not model, such
as an inline image with its own Content-ID.

## `wrap76(encoded)`

Wrap a base64 payload to 76-column lines. RFC 2045 caps an encoded line at
76 characters, and RFC 5322 caps any line at 998 octets, so an unwrapped
attachment is not merely untidy: some servers refuse it.

## `boundary_of(msg)`

The multipart delimiter for `msg`, derived from a hash of its parts.

Deriving it rather than randomising it buys two things. It cannot collide
with the content, because content that contained the boundary would have
hashed differently. And the same message renders byte-identically every
time, which is what lets the tests assert on exact output and what makes a
rendered message diffable.

## `take_str(s, n)`

The first `n` characters of `s`.

## `subtype_of(msg)`

The multipart subtype for this set of parts, or null when the message is a
single part and needs no multipart wrapper at all.

## `render(msg)`

Render to the map `smtp.send` accepts: { from, to, subject, headers, body }.
The MIME headers land in `headers`, so the transport does not have to know
anything about multiparts.

Throws `{ kind: "mime" }` for a message with no parts - an empty body is
almost always a caller bug rather than an intent.

## `render_single(msg)`

One part: its own headers become the message's, and its body is the body.

## `render_multipart(msg, subtype)`

Several parts: each gets its own header block, separated by the boundary and
closed by the terminating `--boundary--`.

## `to_string(msg)`

The whole message as RFC 5322 text, headers and all. `render` is what you
hand to a transport; this is for writing a .eml, a fixture, or a test.

## `opt(m, k, fallback)`

`get` with a default, for optional spec fields.
