# Emacs Configuration

> **Requires Emacs 30.2+**

Modular, self-contained Emacs config. `early-init.el` tunes GC and frame UI
before `package.el` loads. `init.el` bootstraps `package.el` (with
`package-quickstart`), `use-package`, and `custom-file`, then delegates to
purpose-specific modules under `lisp/`.

## Architecture

`early-init.el` tunes the GC and kills menu/tool/scroll bars before the frame
is created. `init.el` bootstraps the package system (using `package-quickstart`
for fast startup), then iterates over `lisp/` modules in order:

| Category              | Module(s)                         |
| --------------------- | --------------------------------- |
| Settings              | `core-settings` (UI cleanup, sane defaults, backup) |
| UI                    | `core-ui`                         |
| Dashboard             | `core-dashboard`                  |
| File management       | `core-files`                      |
| Editing               | `core-editing`                    |
| Window management     | `core-windows`                    |
| Keybindings           | `core-keybindings`                |
| Completion            | `core-completion`                 |
| LSP                   | `core-lsp`                        |
| Version control       | `core-vc`                         |
| Shell                 | `core-shell`                      |
| OS                    | `os-macos` (Darwin only)          |
| Languages             | `lang-*.el` (auto-discovered)     |
| AI / Agents           | `ai-*.el` (auto-discovered)       |
| Early init            | `early-init.el` (frame UI, GC)    |

Language and AI modules are discovered automatically — add or remove files
without touching `init.el`.

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

### UI

- **[solarized-theme](https://github.com/bbatsov/solarized-emacs)** (`solarized-gruvbox-dark`) — low-contrast, warm.
- **[mood-line](https://github.com/jessiehildebrandt/mood-line)** — compact mode-line with glyphs.
- **[minions](https://github.com/tarsius/minions)** — hides minor-mode lighters behind a single indicator.
- **[dashboard](https://github.com/emacs-dashboard/emacs-dashboard)** — cyberpunk-themed startup screen with recents, bookmarks,
  projects, agenda, and navigator buttons. Powered by **[nerd-icons](https://github.com/rainstormstudio/nerd-icons.el)**.
- **[dirvish](https://github.com/alexluigit/dirvish)** — Dired replacement with side-panel tree, git indicators,
  nerd-icons, and `fd` integration.

### LSP & languages

**[lsp-mode](https://github.com/emacs-lsp/lsp-mode)** provides IDE features (diagnostics, refactoring, code actions).
Language modules hook `lsp-deferred` in and expose cargo / python-shell / eval
commands under `SPC m`.

| Language | Package / mode | Notable commands               |
| -------- | -------------- | ------------------------------ |
| Elisp    | built-in       | eval-last-sexp, ielm, find-fn  |
| Python   | built-in + **ruff-format**, **pyvenv**, **pytest**, **lsp-ruff** | format on save, virtualenv activate/deactivate, run all tests / test at point, REPL, send region/buffer/file, ruff LSP linting |
| Rust     | **rustic**     | cargo build/check/run/test/fmt/clippy |

### Version control

- **[magit](https://magit.vc)** — git porcelain.
- **[projectile](https://github.com/bbatsov/projectile)** — project navigation, tied into consult for ripgrep and
  dirvish-side for tree views.

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
presets (2-column, 3-column, 2-row), split-direction toggling, and a zoom
toggle. Help/describe buffers (`*Help*`, `*Apropos*`, etc.) open automatically
in a right-side split for easy side-by-side reference.

### macOS

`os-macos.el` sets `Iosevka NFM 14` as the frame font, binds Cmd to Super
(standard macOS shortcuts work), and Option to Meta.
