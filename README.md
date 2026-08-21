# Emacs Configuration

> **Requires Emacs 31+**

Modular, self-contained Emacs config targeting **Emacs 31**. `early-init.el`
tunes GC and frame UI before `package.el` loads. `init.el` bootstraps
`package.el` (with `package-quickstart`), `use-package`, and `custom-file`,
then delegates to purpose-specific modules under `lisp/`.

> **Note:** after installing new packages run `M-x package-quickstart-refresh`
> to rebuild the startup cache; without it, new packages fall back to a full
> scan which is slower but still correct.

## Architecture

`early-init.el` tunes the GC and kills menu/tool/scroll bars before the frame
is created. `init.el` bootstraps the package system (using `package-quickstart`
for fast startup), then loads core modules in order and defers optional module
families until right after startup (or first file open):

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
| Syntax checking       | `core-flymake`                    |
| Tree-sitter           | `core-treesit`                    |
| Version control       | `core-vc`                         |
| Shell                 | `core-shell`                      |
| Markdown              | `core-markdown`                   |
| OS                    | `os-macos` (Darwin), `os-linux` (GNU/Linux), `os-windows` (Windows) |
| TTY                   | `core-tty` (loaded only when `(display-graphic-p)` is nil)          |
| Languages             | `lang-*.el` (auto-discovered)     |
| AI / Agents           | `ai-*.el` (auto-discovered)       |
| Early init            | `early-init.el` (frame UI, GC)    |

Language and AI modules are discovered automatically and loaded once after
startup (or immediately on first file open), so you can add/remove files
without touching `init.el`.

## Startup profiling

Use these commands to benchmark and profile startup from a terminal:

```bash
emacs --init-directory ~/.config/emacs --eval '(kill-emacs)'
RK_PROFILE_STARTUP=1 emacs --init-directory ~/.config/emacs
```

With `RK_PROFILE_STARTUP=1`, the built-in CPU+memory profiler starts during
init and opens a profiler report after startup.

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
- **completion-preview** (built-in) — inline ghost-text preview of the top completion candidate in `prog-mode` buffers.

### UI

- **[solarized-theme](https://github.com/bbatsov/solarized-emacs)** (`solarized-gruvbox-dark`) — low-contrast, warm.
- **[mood-line](https://github.com/jessiehildebrandt/mood-line)** — compact mode-line with glyphs.
- **mode-line-collapse-minor-modes** (built-in, Emacs 31) — collapses minor mode lighters into a single button. Replaces the `minions` package.
- **[dashboard](https://github.com/emacs-dashboard/emacs-dashboard)** — cyberpunk-themed startup screen with recents, bookmarks,
  projects, agenda, and navigator buttons. Powered by **[nerd-icons](https://github.com/rainstormstudio/nerd-icons.el)**.
- **dired** (built-in) — simple file management defaults (recursive copy/delete prompts streamlined, DWIM target, optional GNU `ls` integration).
- **auto-revert** (built-in) — automatically reverts buffers when files change on disk.

### LSP & syntax checking

**[lsp-mode](https://github.com/emacs-lsp/lsp-mode)** provides IDE features (diagnostics, refactoring, code actions).
Language modules hook `lsp-deferred` in and expose cargo / python-shell / eval
commands under `SPC m`. LSP diagnostics are routed through **flymake** via
`lsp-diagnostics-provider :flymake`.

**lsp-lens-mode** (built into lsp-mode) provides Code Vision–style inline
annotations above function definitions. Toggle per-buffer with `SPC g L`.

**flymake** (built-in) is the global syntax-checking layer, replacing the
`flycheck` package. Error navigation and checker management live under the
`SPC e` leader prefix (backed by `core-flymake.el`).

**editorconfig** (ELPA) — globally active; reads `.editorconfig` files and
applies indent style, line endings, charset, and trailing-whitespace settings
across all major modes automatically.

**Tree-sitter** (built-in, Emacs 31) — `treesit-enabled-modes` is set to `t`
so Emacs automatically switches to `*-ts-mode` variants when grammars are
available. `treesit-auto-install-grammar` is set to `ask` so missing grammars
are offered on demand — no more manual `treesit-install-language-grammar`
calls. Replaces the `treesit-auto` package. `treesit-font-lock-level` is set
to 4 for maximum syntax-highlight detail.

| Language | Package / mode | Notable commands               |
| -------- | -------------- | ------------------------------ |
| Elisp    | built-in       | eval-last-sexp, ielm, find-fn  |
| Python   | built-in (`python-ts-mode`) + **ruff-format**, **pyvenv** | format on save (ruff), virtualenv activate/deactivate, run all tests / test at point (`python -m pytest`), REPL, send region/buffer/file; LSP uses `pylsp` for completions/hover/go-to-def — install per project: `pip install "python-lsp-server[all]"` (or `uv add --dev python-lsp-server`). |
| Rust     | **rustic** | cargo build/check/run/test/fmt/clippy; diagnostics via flymake |
| C# / .NET | built-in (`csharp-ts-mode`) + **lsp-csharp** (OmniSharp, auto-downloads), **dap-mode** + netcoredbg (auto-downloads), **reformatter** + csharpier (optional) | dotnet build/run/test, DAP debugging, csharpier format-on-save; only `.NET SDK` on `$PATH` is required — OmniSharp Roslyn downloads via `M-x lsp-install-server`, netcoredbg downloads on first `M-x dap-debug`. Optional: `dotnet tool install -g csharpier` for format-on-save. |

### Markdown

**markdown-ts-mode** (built-in, Emacs 31, experimental) — org-like navigation
and heading folding, live syntax-highlighted fenced code blocks (using the
real major mode for each language), and inline image rendering. Loaded in
`core-markdown.el` and wired to `.md`/`.markdown` files. `markdown-ts-view-mode`
is used by eglot to render hover documentation with proper syntax highlighting.

### Version control

- **[magit](https://magit.vc)** — git porcelain.
- **project.el** (built-in, Emacs 28+) — project navigation (`SPC p`), tied into consult for ripgrep and magit for status. Replaces projectile.
- **[blamer](https://github.com/Artawower/blamer.el)** — Code Vision–style inline git blame. Toggle per-buffer with `SPC g B`.
- **vc-dir-auto-hide-up-to-date** (Emacs 31) — `vc-dir` hides up-to-date files automatically on refresh.
- **xref-edit-mode** (Emacs 31) — press `e` in `*xref*` buffers to edit matches inline (like grep-edit-mode).

### Shell

- **[eat](https://codeberg.org/akib/emacs-eat)** — fast terminal emulator that integrates with **eshell** visual
  commands (ssh, htop, etc.) and uses `fish` as the underlying shell.
- **eshell** — Emacs' own shell, configured with `fish` for external commands,
  large history, and scroll-to-bottom.
- IELM history is persisted across sessions via `ielm-history-file-name` (Emacs 31).

### AI / Agents

- **[agent-shell](https://github.com/xenodium/agent-shell)** — native Emacs shell for ACP-driven coding agents.
  Configured with **opencode** as the agent. Leader key `SPC A` menu provides
  start, toggle, restart, and send-region commands.

### Window management

Window placement is fully controlled by `display-buffer-alist` — no random
popup windows. Rules are grouped by intent (docs/xref, diagnostics/output, shell), and the layout is:

- **Right side** (38%): Help, Apropos, Info, Man, xref, eldoc
- **Bottom** (25-30%): Compilation, flymake diagnostics, eshell/eat, Messages, Warnings
- **Left side** (via `SPC f t`): **Speedbar** — file tree, imenu, VC status (Emacs 31: `speedbar-window` docks in a side window instead of a separate frame)

The `SPC w` leader menu includes:
- Layout presets: 2-column, 3-column, 2-row, split-direction toggle, zoom toggle
- `SPC wu`/`SPC wU` — `winner-undo`/`winner-redo` (built-in window configuration history)
- `SPC wR` — rotate window layout clockwise (Emacs 31)
- `SPC wF` — flip window layout left/right (Emacs 31)
- `SPC wT` — transpose window layout (swap horizontal/vertical splits) (Emacs 31)

### TTY / terminal mode

`core-tty.el` is loaded only when `(display-graphic-p)` returns nil (i.e. `emacs -nw`).

- **xterm-mouse-mode** — enables mouse clicks, selection, and scroll-wheel in xterm-compatible terminals.
- **[clipetty](https://github.com/spudlyo/clipetty)** — forwards the kill-ring to the system clipboard via OSC 52, so copy/paste works inside tmux, SSH, etc. without `xclip`/`xsel` binaries.
- Mouse scroll mapped to `[mouse-4]`/`[mouse-5]` (3 lines, no acceleration).
- Cursor blink disabled and `visible-bell` enabled (prevents terminal beep).
- `xterm-extra-capabilities` tuned when `$TERM` reports 256-color or truecolor support.

### macOS

`os-macos.el` binds Cmd to Super (standard macOS shortcuts work), and the left
Option to Meta. The right Option is left as AltGr so macOS unicode/hex character
composition still works.
