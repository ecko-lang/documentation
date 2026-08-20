# `std.defaults`

The `ecko.json` sitting **next to the file you run** is loaded automatically,
before your program starts. There is no loader to call and no setup step - the
values are simply there.

```json
{
    "app": "billing",
    "version": "1.0",
    "api_url": "https://api.example.com",
    "environment": { "ECKO_AI_PROVIDER": "ollama" }
}
```

```ecko fragment
import std.defaults

print(defaults.app)          # "billing"
print(defaults.version)      # "1.0"
```

Two separate things happen when that file is read.

## Every key becomes a default

Each top-level key other than `environment` becomes a member of `std.defaults`,
keeping its JSON type - strings stay strings, numbers become `int` or `float`,
and lists and objects become Ecko lists and maps.

```ecko fragment
import std.defaults

defaults.retries + 1         # a JSON number is a real number
defaults.hosts[0]            # a JSON list is a real list
```

Indexing by string reaches the same value, which is what you want when the key
is only known at runtime:

```ecko fragment
import std.defaults

wanted = "api_url"
defaults[wanted]             # "https://api.example.com"
```

Reading a key that isn't there is an error, like any other missing member. Since
`ecko check` has no way to know what a given `ecko.json` holds, it never reports
members of `std.defaults` as unknown.

## Every key must be a valid identifier

Letters, digits and underscores, not starting with a digit - the same rule that
governs variable names. Keywords are fine, so `defaults.type` works.

JSON is happy to hold `"api-url"` or `"two words"`, but neither can be read back:
`defaults.api-url` parses as a subtraction. Rather than load values that nothing
can name, the file is refused when it loads:

```
error: ecko.json: 'api-url' is not a usable key - every key is read as
defaults.<name>, so it must be a valid identifier: letters, digits and
underscores, not starting with a digit
```

The same rule applies to names inside `environment`, where a name a shell cannot
export is no use either.

## `environment` configures the process

The optional `environment` object is applied to the process environment before
your program runs, so it reads back through `std.os` like anything else:

```ecko
import std.os

os.env("ECKO_AI_PROVIDER")  # "ollama"
```

Values must be a string, number, or boolean. An object or a list is an error
rather than a silently JSON-encoded string - there is no sensible
environment-variable spelling for one.

**It overrides the surrounding shell.** This is the opposite of
`std.config`, where the environment wins over the file, and it is
deliberate: this block exists so a project can *pin* the environment its code
expects, which it cannot do if whatever happens to already be exported takes
priority. Values that should vary from machine to machine belong in the shell,
not in a committed file.

Because it is applied before evaluation, it also configures Ecko itself - any of
Ecko's `ECKO_*` environment variables work here:

```json
{ "environment": { "ECKO_AI_PROVIDER": "ollama", "ECKO_MAX_DEPTH": "5000" } }
```

## The same file is the package manifest

There is no second file. A package manifest is just a
defaults file that has no `environment` block, so its own fields read back the
same way:

```ecko fragment
import std.defaults

defaults.version             # the manifest's version
defaults.entrypoint          # "main.ecko"
```

The two readers are independent. The manifest reader stays strict about the
fields a *package* needs; the defaults reader accepts any JSON object. A project
that only wants defaults therefore never has to satisfy the manifest schema -
this is a perfectly good `ecko.json`:

```json
{ "app": "scratch", "environment": { "TZ": "UTC" } }
```

## What belongs here

This is project configuration, not a secret store: `ecko.json` is a file you
commit, and `std.defaults` is ungated because it holds what you put in it.

Secrets belong in the environment, which stays behind the
`env` capability, or in `std.config` with `secret: true`.
