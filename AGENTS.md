# AGENTS.md

This repository is a modular Emacs configuration.

## Current architecture

- `early-init.el` runs first and handles pre-package startup tuning (GC/process
  settings, frame UI defaults, and disabling package auto-init).
- `init.el` bootstraps `package.el`, enables `package-quickstart`, configures
  archives, loads `custom.el`, and then loads modules from `lisp/`.
- `lisp/` contains configuration modules by concern:
  - Core modules loaded in fixed order: `core-settings`, `core-ui`,
    `core-dashboard`, `core-files`, `core-editing`, `core-windows`,
    `core-keybindings`, `core-completion`, `core-lsp`, `core-vc`, `core-shell`.
  - OS-specific module: `os-macos` (loaded on Darwin only).
  - Auto-discovered module families: `lang-*.el` and `ai-*.el`.
- `custom.el` stores `custom-set-variables`/`custom-set-faces`
  (auto-generated).

## Directory and file roles

- `lisp/` — first-party config modules (main customization surface).
- `site-lisp/` — manually installed third-party Lisp code (if present).
- `elpa/` — `package.el` installation directory (git-ignored).
- `package-quickstart.el` — generated package autoload cache for faster startup.

Keep behavior changes in modules under `lisp/` and keep bootstrap concerns in
`early-init.el`/`init.el`.

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
