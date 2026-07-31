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

IntelliJ IDEA, WebStorm, PyCharm, GoLand, CLion, Rider and the rest of the family
have a first-party plugin, including the free Community editions.

### The plugin

Install **Ecko** from the plugin marketplace, or build it from
`editors/jetbrains-ecko` and install the zip through **Settings → Plugins → the
gear icon → Install Plugin from Disk...**.

It gives you syntax highlighting from the same grammar the VS Code extension
uses, plus diagnostics, completion, hover, go-to-definition and symbols through
`ecko lsp`.

The IDE will offer to install [LSP4IJ](https://plugins.jetbrains.com/plugin/22407-lsp4ij)
alongside it. That is deliberate: the JetBrains platform's own LSP API ships only
in the paid IDEs, and going through LSP4IJ means Community users get the same
features.

### Without the plugin

Any IntelliJ-based IDE can run the server directly. Install LSP4IJ, add a server
with command `ecko` and argument `lsp`, and associate it with `*.ecko` files.

`ecko` must be on your `PATH`, or use an absolute path to the binary.
