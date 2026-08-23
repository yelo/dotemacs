# Emacs Configuration

> **Requires Emacs 31+**

This repository contains a **vanilla Emacs 31** configuration: built-in
features only, with no external packages required or loaded.

## Architecture

- `early-init.el`: pre-init startup tuning (GC, process output, frame defaults,
  `package-enable-at-startup` disabled).
- `init.el`: loads `custom.el`, then loads modules from `lisp/`.
- `lisp/` core modules (fixed order):
  - `core-settings`, `core-ui`, `core-modeline`, `core-dashboard`, `core-files`,
    `core-editing`, `core-windows`, `core-keybindings`, `core-completion`,
    `core-eglot`, `core-flymake`, `core-treesit`, `core-vc`, `core-shell`,
    `core-markdown`, `core-tabs`
- Optional module families:
  - `lang-*.el` (auto-discovered and loaded once after startup / first file)
- OS modules:
  - `os-macos` (Darwin), `os-linux`, `os-windows`
- TTY-only module:
  - `core-tty` (loaded only when `(display-graphic-p)` is nil)

## Built-in-only feature set

- **Completion:** `fido-vertical-mode`, built-in completion styles (including
  `flex`), eager `*Completions*` updates/display, one-column completions
  layout (`completions-format`, `completions-max-height`), auto-selection of
  completions, `savehist`, `recentf`, `completion-preview-mode`, up/down
  minibuffer candidate navigation (`minibuffer-visible-completions`) with
  `C-n`/`C-p`, and Eglot-scoped `rk/flex-noinsert` to avoid ambiguous TAB
  insertion while keeping flex-style ranking.
- **Editing:** stock Emacs key model, electric-pair, show-paren, repeat-mode,
  `kill-region-dwim` (`C-w` kills backward word when no region is active),
  long-line handling via `global-so-long-mode`.
- **Projects & search:** `project.el`, `project-find-regexp`.
- **LSP/diagnostics:** `eglot` + `flymake`.
- **Tree-sitter:** `treesit-enabled-modes`, `treesit-auto-install-grammar`.
- **VC:** built-in `vc` / `vc-dir` with Emacs 31 VC improvements.
- **Shell:** `eshell`, `shell`, `term` (uses your default shell; no third-party
  terminal packages).
- **Windows/popups:** `display-buffer-alist`, `winner-mode`, `speedbar-window`,
  `windmove` (Shift+arrows), `help-window-select`, `compilation-scroll-output`.
- **Session/position restore:** `desktop-save-mode` restores session/frame
  state; `save-place-mode` restores point position per file.
- **Workspaces:** `core-tabs` — `tab-bar-mode` used as a project-per-tab
  workspace switcher (see Keybindings below).
- **Mode-line:** `core-modeline` — segmented, right-aligned mode-line
  (status icon, buffer name, VC branch, mode name, position) tuned for the
  `wombat` theme, with Nerd Font glyphs in GUI frames and plain-text
  fallbacks in terminals.
- **Markdown:** built-in `markdown-ts-mode` enabled by default for markdown files.
- **Startup launcher:** custom built-in startup buffer with a startup status line and quick actions.
- **Editing ergonomics:** `hs-minor-mode` (code folding indicators),
  `global-subword-mode` (camelCase-aware motion), `isearch-lazy-count`
  (match position), `which-function-mode` (current function in mode line),
  `uniquify` (clear same-named buffer names), extra `savehist` variables
  (kill-ring/search history).
- **Files:** `dired-x` (`C-x C-j` dired-jump, `dired-omit-mode`).

## Keybindings

This configuration stays close to stock Emacs bindings and adds a few minimal
prefixes:

- `C-c p`: project commands (`f` find-file, `p` switch-project, `d` dired,
  `s` search, `t` open project in a new tab, named after the project)
- `C-c w`: window commands (`2/3` split, `0/1` delete, `o` other, `=` balance,
  `z` zoom/restore, `t` transpose layout, `r/R` rotate layout, `f/F` flip layout)
- `C-c v`: VC commands (`d` vc-dir, `=` vc-diff, `l` vc-log)
- `C-c f`: `find-file`
- `C-c b`: `switch-to-buffer`
- `C-c r`: `recentf-open-files`
- `C-c i`: `imenu`
- `C-c !`: flymake shortcuts (`l` list, `n/p` next/prev, `s` start)
- `C-c S`: reopen startup launcher buffer
- `Shift+←/→/↑/↓`: move between windows (`windmove`)
- `C-x C-j`: jump to the current file's directory in dired (`dired-x`)
- `C-x t`: built-in `tab-bar-mode` prefix (new/close/switch tabs)

## Startup launcher

On startup, Emacs opens a minimal built-in launcher buffer with:
- a combined Emacs/version + startup timing + GC status line,
- quick actions for file/project/config entry points.

In the startup buffer, use:
- `f` find file
- `r` recent files
- `p` switch project
- `i` open `init.el`

## Language modules

- `lang-elisp.el`: eval/navigation helpers for Emacs Lisp buffers.
- `lang-python.el`: `pylsp` + `eglot`, plus pytest helpers.
- `lang-rust.el`: `rust-analyzer` + `eglot`; cargo via `M-x rk/rust-cargo`.
- `lang-csharp.el`: `csharp-ls` + `eglot`; `rk/dotnet-build/run/test` helpers.

## Startup profiling

```bash
emacs --init-directory ~/.config/emacs --eval '(kill-emacs)'
RK_PROFILE_STARTUP=1 emacs --init-directory ~/.config/emacs
```
