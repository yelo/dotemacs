# AGENTS.md

This repository is a modular Emacs configuration targeting **Emacs 31+**.

## Current architecture

- `early-init.el` runs first and handles pre-package startup tuning (GC/process
  settings, frame UI defaults, and disabling package auto-init).
- `init.el` loads `custom.el`, then loads modules from `lisp/`.
- `lisp/` contains configuration modules by concern:
  - Core modules loaded in fixed order: `core-settings`, `core-ui`,
    `core-dashboard`, `core-files`, `core-editing`, `core-windows`,
    `core-keybindings`, `core-completion`, `core-eglot`, `core-flymake`,
    `core-treesit`, `core-vc`, `core-shell`, `core-markdown`.
  - OS-specific modules: `os-macos`, `os-linux`, `os-windows`.
  - Auto-discovered optional family: `lang-*.el`.
    Current language modules: `lang-elisp`, `lang-python`, `lang-rust`, `lang-csharp`.
- `custom.el` stores `custom-set-variables`/`custom-set-faces`
  (auto-generated).

## Directory and file roles

- `lisp/` — first-party config modules (main customization surface).
- `site-lisp/` — manually installed Lisp code (if present).

Keep behavior changes in modules under `lisp/` and keep bootstrap concerns in
`early-init.el`/`init.el`.

## Emacs 31 target

This branch is intentionally **built-in only**: no external package dependency
is required for normal startup and workflows.

## Commit Conventions

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]
```

Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `revert`.

## README Maintenance

Keep `README.md` updated when adding, removing, or substantially reconfiguring
modules or workflows so architecture and user-facing behavior stay accurate.

Keep `AGENTS.md` updated when the module list in `lisp/` changes (new modules
added, modules renamed, or the Emacs version target changes).
