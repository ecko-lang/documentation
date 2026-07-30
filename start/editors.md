# Editor support

Ecko ships a language server inside the one binary (`ecko lsp`). Editors that speak
LSP get live diagnostics, completion, hover, go-to-definition, and document symbols.
VS Code (and Cursor) also get a first-party extension with highlighting and snippets.

Install the binary first: [Download](/download).

## VS Code

The **Ecko Language** extension packages the TextMate grammar, snippets, and a
language client that launches `ecko lsp`.

### Install from a VSIX

Package from the language repo (`editors/vscode-ecko`) and install:

```bash
cd editors/vscode-ecko
npm install
npx @vscode/vsce package
code --install-extension vscode-ecko-*.vsix
```

For Cursor:

```bash
cursor --install-extension vscode-ecko-*.vsix
```

Reload the window after install (**Developer: Reload Window**).

When the extension is on the Marketplace, the same identifier will be
`ecko.vscode-ecko`.

### Requirements

`ecko` must be on your `PATH`. If it lives elsewhere, set **`ecko.server.path`**
in VS Code settings to the full path. Without the binary, highlighting and snippets
still work; smart editing waits until the server is available.

## Zed

Zed has no separate Ecko plugin - point it at the binary.

Add to your Zed settings (`settings.json`):

```json
{
  "lsp": {
    "ecko": {
      "binary": {
        "path": "ecko",
        "arguments": ["lsp"]
      }
    }
  },
  "languages": {
    "Ecko": {
      "language_servers": ["ecko"]
    }
  }
}
```

Open a `.ecko` file and confirm the language server attaches in the status bar.
Syntax highlighting in Zed improves when a community grammar lands; diagnostics and
completion do not wait on that.

## JetBrains IDEs

IntelliJ IDEA, WebStorm, PyCharm, and other IntelliJ-based products can run a custom
language server.

### Built-in language servers

1. Open **Settings → Languages & Frameworks → Language Servers** (wording varies slightly by product).
2. Add a server:
   - **Command:** `ecko`
   - **Arguments:** `lsp`
3. Associate it with `*.ecko` files (or the Ecko file type if you create one).

### LSP4IJ plugin

If your build does not expose custom servers yet, install
[LSP4IJ](https://plugins.jetbrains.com/plugin/22407-lsp4ij) and configure the same
command and arguments there.

`ecko` must be on your `PATH`, or use an absolute path to the binary.
