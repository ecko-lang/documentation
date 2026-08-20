# `std.cli`

Declarative argument parsing. Describe the interface, get a parser and a help
screen.

```ecko fragment
import std.cli
import std.os

spec = {
    program: "report",
    options: [
        { name: "format", short: "f", default: "text", help: "output format" },
        { name: "verbose", flag: true, help: "explain what is happening" },
    ],
    args: [
        { name: "input", help: "the file to read" },
    ],
}

opts = cli.parse(spec, os.args())

print(opts.format)      # "text" unless --format was given
print(opts.verbose)     # false unless --verbose
print(opts.input)
print(opts.rest)        # anything after the declared positionals
```

## The surface

| call | |
|---|---|
| `cli.parse(spec, argv)` | parse, or error with a usage message |
| `cli.help(spec)` | the generated help text |

## The spec

- `program` - the name shown in usage.
- `options` - each `{ name, short?, default?, flag?, help? }`. A `flag` takes no
  value and defaults to `false`.
- `args` - positional parameters, in order.
- `rest` - whatever is left over, always present in the result.

## Why declarative

The parser and the help text come from **one description**, so they cannot
disagree. Hand-rolled argument parsing drifts from its `--help` output almost
immediately, and the drift is invisible until someone follows the help and gets an
error.

## With `std.defaults`

A natural pairing: put the defaults in `ecko.json` and let flags override them.

```ecko fragment
import std.defaults
opts = cli.parse(spec, os.args())
port = if opts.port == null { defaults.port } else { int(opts.port) }
```

The manifest holds what the project wants; the command line holds what this run
wants. See [`std.defaults`](./defaults.md).

## The `cli` package

There is also a Layer-3 [`cli` package](../packages/cli.md) written in Ecko, with
typed flags and richer usage generation. This module is the built-in, no-dependency
option; the package goes further.
