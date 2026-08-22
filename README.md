# Emacs Configuration

> **Requires Emacs 31+**

This branch is a **vanilla Emacs 31** configuration: built-in features only,
no external packages required or loaded.

## Architecture

- `early-init.el`: pre-init startup tuning (GC, process output, frame defaults,
  `package-enable-at-startup` disabled).
- `init.el`: loads `custom.el`, then loads modules from `lisp/`.
- `lisp/` core modules (fixed order):
  - `core-settings`, `core-ui`, `core-dashboard`, `core-files`,
    `core-editing`, `core-windows`, `core-keybindings`, `core-completion`,
    `core-eglot`, `core-flymake`, `core-treesit`, `core-vc`, `core-shell`,
    `core-markdown`
- Optional module families:
  - `lang-*.el` (auto-discovered and loaded once after startup / first file)
- OS modules:
  - `os-macos` (Darwin), `os-linux`, `os-windows`
- TTY-only module:
  - `core-tty` (loaded only when `(display-graphic-p)` is nil)

## Built-in-only feature set

- **Completion:** `fido-vertical-mode`, built-in completion styles, `savehist`,
  `recentf`, `completion-preview-mode`.
- **Editing:** stock Emacs key model, electric-pair, show-paren, repeat-mode,
  long-line handling via `global-so-long-mode`.
- **Projects & search:** `project.el`, `project-find-regexp`.
- **LSP/diagnostics:** `eglot` + `flymake`.
- **Tree-sitter:** `treesit-enabled-modes`, `treesit-auto-install-grammar`.
- **VC:** built-in `vc` / `vc-dir` with Emacs 31 VC improvements.
- **Shell:** `eshell`, `shell`, `term` (no third-party terminal packages).
- **Windows/popups:** `display-buffer-alist`, `winner-mode`, `speedbar-window`.
- **Markdown:** built-in `markdown-ts-mode` when available.

## Keybindings

This branch intentionally stays close to stock Emacs bindings and adds a few
minimal prefixes:

- `C-c p`: project commands (`f` find-file, `p` switch-project, `d` dired, `s` search)
- `C-c w`: window commands (`2/3` split, `0/1` delete, `o` other, `=` balance)
- `C-c v`: VC commands (`d` vc-dir, `=` vc-diff, `l` vc-log)
- `C-c f`: `find-file`
- `C-c b`: `switch-to-buffer`
- `C-c r`: `recentf-open-files`
- `C-c !`: flymake shortcuts (`l` list, `n/p` next/prev, `s` start)

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
