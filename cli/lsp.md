# `ecko lsp`

```bash
ecko lsp
```

The language server, speaking LSP over stdin and stdout. You do not normally run
it yourself - an editor launches it. See [Editor support](../start/editors.md)
for setup.

## What it provides

- **Diagnostics** - the same findings as [`ecko check`](./check.md), live as you
  type: undefined names with suggestions, arity, use-before-definition, match
  exhaustiveness, unwrapped credentials, unused bindings.
- **Completion** - names in scope, standard-library modules and their functions,
  and the global built-ins.
- **Hover** - signatures and documentation, including the `##`
  [doc comments](../language/comments.md) on your own functions.
- **Go to definition**.
- **Document symbols** - the outline of a file.

## No separate install

The server is the same binary as the compiler. There is no language-server
package to install, no version to keep in step with the toolchain, and no
possibility of the editor analyzing your code with different rules than the
compiler applies - it is literally the same analysis pass.

## Debugging it

An editor that shows no diagnostics is usually failing to launch the binary.
Check that `ecko` is on the `PATH` the editor sees, which is not always the
`PATH` your shell sees, and look at your editor's LSP log.
