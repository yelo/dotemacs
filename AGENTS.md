# AGENTS.md

This repository is a modular Emacs configuration targeting **Emacs 31+**.

## Current architecture

- `early-init.el` runs first and handles pre-package startup tuning (GC/process
  settings, frame UI defaults, and disabling package auto-init).
- `init.el` bootstraps `package.el`, enables `package-quickstart`, configures
  archives, loads `custom.el`, and then loads modules from `lisp/`.
- `lisp/` contains configuration modules by concern:
  - Core modules loaded in fixed order: `core-settings`, `core-ui`,
    `core-dashboard`, `core-files`, `core-editing`, `core-windows`,
    `core-keybindings`, `core-completion`, `core-eglot`, `core-flymake`,
    `core-treesit`, `core-vc`, `core-shell`, `core-markdown`.
  - OS-specific module: `os-macos` (loaded on Darwin only).
  - Auto-discovered module families: `lang-*.el` and `ai-*.el`.
    Current language modules: `lang-elisp`, `lang-python`, `lang-rust`, `lang-csharp`.
- `custom.el` stores `custom-set-variables`/`custom-set-faces`
  (auto-generated).

## Directory and file roles

- `lisp/` — first-party config modules (main customization surface).
- `site-lisp/` — manually installed third-party Lisp code (if present).
- `elpa/` — `package.el` installation directory (git-ignored).
- `package-quickstart.el` — generated package autoload cache for faster startup.

Keep behavior changes in modules under `lisp/` and keep bootstrap concerns in
`early-init.el`/`init.el`.

## Emacs 31 target

This config hard-targets Emacs 31. There are no version guards — all features
are used unconditionally. Key packages replaced by built-in equivalents:

| Removed package | Native replacement |
| --------------- | ------------------ |
| `treesit-auto` | `treesit-enabled-modes` + `treesit-auto-install-grammar` |
| `flycheck` + `flycheck-rust` | `flymake` (built-in) → `core-flymake.el` |
| `minions` | `mode-line-collapse-minor-modes` |
| `popper` | `display-buffer-alist` side-window rules |
| `dirvish-side` | `speedbar-window` (Emacs 31 side-window docking) |

## Commit Conventions

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]
```

Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `revert`.

## README Maintenance

Keep `README.md` updated when adding, removing, or substantially reconfiguring
packages. The README documents the architecture, rationale, and package
selection; any change that alters what a reader would learn about the config
should be reflected there.

Keep `AGENTS.md` updated when the module list in `lisp/` changes (new modules
added, modules renamed, or the Emacs version target changes).
