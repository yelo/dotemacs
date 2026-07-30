# Emacs Configuration

> **Requires Emacs 30.2+**

Modular, self-contained Emacs config. `early-init.el` tunes GC and frame UI
before `package.el` loads. `init.el` bootstraps `package.el` (with
`package-quickstart`), `use-package`, and `custom-file`, then delegates to
purpose-specific modules under `lisp/`.

> **Note:** after installing new packages run `M-x package-quickstart-refresh`
> to rebuild the startup cache; without it, new packages fall back to a full
> scan which is slower but still correct.

## Architecture

`early-init.el` tunes the GC and kills menu/tool/scroll bars before the frame
is created. `init.el` bootstraps the package system (using `package-quickstart`
for fast startup), then iterates over `lisp/` modules in order:

| Category              | Module(s)                         |
| --------------------- | --------------------------------- |
| Settings              | `core-settings` (UI cleanup, sane defaults, backup, global font/frame defaults) |
| UI                    | `core-ui`                         |
| Dashboard             | `core-dashboard`                  |
| File management       | `core-files`                      |
| Editing               | `core-editing`                    |
| Window management     | `core-windows`                    |
| Keybindings           | `core-keybindings`                |
| Completion            | `core-completion`                 |
| LSP                   | `core-lsp`                        |
| Syntax checking       | `core-flycheck`                   |
| Tree-sitter           | `core-treesit`                    |
| Version control       | `core-vc`                         |
| Shell                 | `core-shell`                      |
| OS                    | `os-macos` (Darwin), `os-linux` (GNU/Linux), `os-windows` (Windows) |
| Languages             | `lang-*.el` (auto-discovered)     |
| AI / Agents           | `ai-*.el` (auto-discovered)       |
| Early init            | `early-init.el` (frame UI, GC)    |

Language and AI modules are discovered automatically — add or remove files
without touching `init.el`.

Global frame defaults live in `core-settings`: Emacs starts maximized and uses
`Iosevka NFM 14` by default across platforms.

## Rationale & Packages

### Modal editing

**[meow](https://github.com/meow-edit/meow)** provides modal editing (NORMAL/INSERT/MOTION states) with a lighter
footprint than evil/Doom. Configured with Dvorak hints and SPC as the leader
prefix, keeping modal bindings out of the way of leader-key workflows.

**[general](https://github.com/noctuid/general.el)** layers doom-style `SPC` / `SPC m` leader binds on top of meow,
with `which-key` for discoverability. `core-keybindings` defines a top-level
leader menu (files, buffers, windows, project, search, git, help) and provides
macros for language/feature-specific `SPC m` menus.

### Completion & narrowing

The stack follows the modern Emacs completion paradigm:

- **[vertico](https://github.com/minad/vertico)** — vertical minibuffer completion.
- **[orderless](https://github.com/oantolin/orderless)** — flexible, space-separated matching (literal, regex, flex).
- **[marginalia](https://github.com/minad/marginalia)** — rich annotations in minibuffer lists.
- **[consult](https://github.com/minad/consult)** — enhanced previewing commands (buffer, line, ripgrep, etc.).
- **[corfu](https://github.com/minad/corfu)** — in-buffer popup completion, backed by **[cape](https://github.com/minad/cape)** (dabbrev, file,
  keyword) and **[tempel](https://github.com/minad/tempel)** for template expansion.
- **[embark](https://github.com/oantolin/embark)** — context-sensitive action menus at point.
- **completion-preview** (built-in, Emacs 30) — inline ghost-text preview of the top completion candidate in `prog-mode` buffers.

### UI

- **[solarized-theme](https://github.com/bbatsov/solarized-emacs)** (`solarized-gruvbox-dark`) — low-contrast, warm.
- **[mood-line](https://github.com/jessiehildebrandt/mood-line)** — compact mode-line with glyphs.
- **[minions](https://github.com/tarsius/minions)** — hides minor-mode lighters behind a single indicator.
- **[dashboard](https://github.com/emacs-dashboard/emacs-dashboard)** — cyberpunk-themed startup screen with recents, bookmarks,
  projects, agenda, and navigator buttons. Powered by **[nerd-icons](https://github.com/rainstormstudio/nerd-icons.el)**.
- **[dirvish](https://github.com/alexluigit/dirvish)** — Dired replacement with side-panel tree, git indicators,
  nerd-icons, and `fd` integration.
- **dired-preview** — file preview in Dired buffers on hover.

### LSP & syntax checking

**[lsp-mode](https://github.com/emacs-lsp/lsp-mode)** provides IDE features (diagnostics, refactoring, code actions).
Language modules hook `lsp-deferred` in and expose cargo / python-shell / eval
commands under `SPC m`. LSP diagnostics are routed through flycheck via
`lsp-diagnostics-provider :flycheck`.

**lsp-lens-mode** (built into lsp-mode) provides Code Vision–style inline
annotations above function definitions: reference counts, implementation counts,
and test counts — depending on what the language server reports. Each lens is
clickable and triggers the corresponding LSP action (e.g. `lsp-find-references`).
Enabled by default in all LSP buffers; toggle per-buffer with `SPC g L`. Quality
varies by server: `rust-analyzer` reports references and implementations;
`pyright`/`pylsp` report references only.

**[flycheck](https://www.flycheck.org/)** is the global syntax-checking layer, replacing flymake. It
receives LSP diagnostics from lsp-mode and also runs language-native checkers
directly (e.g. `python-ruff` for Python, cargo/clippy for Rust via
`flycheck-rust`). Error navigation and checker management live under the `SPC e`
leader prefix. The `*Flycheck errors*` list buffer is managed as a popper popup.

**[treesit-auto](https://github.com/renzmann/treesit-auto)** automatically installs tree-sitter grammars and remaps
classic major modes to their `*-ts-mode` equivalents when a grammar is
available. `treesit-font-lock-level` is set to 4 for maximum syntax-highlight
detail. Language modules register hooks for both the classic and `ts` variants.

| Language | Package / mode | Notable commands               |
| -------- | -------------- | ------------------------------ |
| Elisp    | built-in       | eval-last-sexp, ielm, find-fn  |
| Python   | built-in (`python-ts-mode`) + **ruff-format**, **pyvenv**, **pytest** | format on save (ruff), virtualenv activate/deactivate, run all tests / test at point, REPL, send region/buffer/file; linting via flycheck `python-ruff` checker. LSP servers (`ruff`, `pylsp`) are loaded from the project's `.venv` — install them per project: `pip install ruff "python-lsp-server[all]"` (or `uv add --dev ruff python-lsp-server`). |
| Rust     | **rustic** + **flycheck-rust** | cargo build/check/run/test/fmt/clippy; flycheck runs clippy via `flycheck-rust` |

### Version control

- **[magit](https://magit.vc)** — git porcelain.
- **project.el** (built-in, Emacs 28+) — project navigation (`SPC p`), tied into consult for ripgrep and magit for status. Replaces projectile.
- **[blamer](https://github.com/Artawower/blamer.el)** — Code Vision–style inline git blame. Shows author name and
  commit summary as virtual text beside every line (defaulting on via
  `global-blamer-mode`). Clicking the annotation opens the full commit details
  popup. Toggle per-buffer with `SPC g B`; the existing `SPC g b` still runs
  `magit-blame-addition` for a full blame view.

### Shell

- **[eat](https://codeberg.org/akib/emacs-eat)** — fast terminal emulator that integrates with **eshell** visual
  commands (ssh, htop, etc.) and uses `fish` as the underlying shell.
- **eshell** — Emacs' own shell, configured with `fish` for external commands,
  large history, and scroll-to-bottom.

### AI / Agents

- **[agent-shell](https://github.com/xenodium/agent-shell)** — native Emacs shell for ACP-driven coding agents.
  Configured with **opencode** as the agent and **DeepSeek**
  (`deepseek/deepseek-chat`) as the provider. Leader key `SPC A` menu provides
  start, toggle, restart, and send-region commands.

### Window management

**[popper](https://github.com/karthink/popper)** manages transient buffers (messages, compilation, backtrace, etc.)
as a popup at the bottom of the frame. The `SPC w` leader menu includes layout
presets (2-column, 3-column, 2-row), split-direction toggling, a zoom toggle,
and `SPC wu`/`SPC wU` for `winner-undo`/`winner-redo` (built-in window
configuration history). Help/describe buffers (`*Help*`, `*Apropos*`, etc.)
open automatically in a right-side split for easy side-by-side reference.

### macOS

`os-macos.el` binds Cmd to Super (standard macOS shortcuts work), and Option to
Meta.
