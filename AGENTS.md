# AGENTS.md

This repository is a modular Emacs configuration targeting **Emacs 31+**.

## Current architecture

- `early-init.el` runs first and handles pre-package startup tuning (GC/process
  settings, frame UI defaults, and disabling package auto-init).
- `init.el` loads `custom.el`, then loads modules from `lisp/`.
- `lisp/` contains configuration modules by concern:
  - Core modules loaded in fixed order: `core-settings`, `core-ui`,
    `core-modeline`, `core-dashboard`, `core-files`, `core-editing`,
    `core-windows`, `core-keybindings`, `core-completion`, `core-eglot`,
    `core-flymake`, `core-treesit`, `core-vc`, `core-shell`, `core-markdown`,
    `core-tabs`.
  - TTY-only module: `core-tty` (loaded only when Emacs has no window
    system, i.e. `(display-graphic-p)` is nil).
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

This configuration is intentionally **built-in only**: no external package
dependency is required for normal startup and workflows.

## Commit Conventions

Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]
```

Types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `ci`, `revert`.

Do not add a `Co-authored-by` trailer (or any other AI-attribution trailer)
to commit messages in this repository.

## Documentation Maintenance

### README.md
Keep `README.md` updated when adding, removing, or substantially reconfiguring
modules or workflows so architecture and user-facing behavior stay accurate.

### AGENTS.md
Keep `AGENTS.md` updated when the module list in `lisp/` changes (new modules
added, modules renamed, or the Emacs version target changes).

### HOWTO.md
Keep `HOWTO.md` up-to-date whenever configuration changes may impact end-user
workflows. Trigger points include:

- **Keybindings changed or added** in `core-keybindings.el` or language modules
  (e.g., `C-c p`, `C-c w`, `C-c v`, `C-c !`, language-specific helpers like
  `C-c t a` for Python).
- **Window/popup routing modified** in `core-windows.el`'s `display-buffer-alist`
  (e.g., which side Help/compilation/shell windows appear on).
- **Language modules added/removed** in `lisp/lang-*.el` (affects §10 "LSP &
  diagnostics" and §13 "Daily workflows" pattern descriptions).
- **LSP servers changed** for any language (affects server names mentioned in
  language module documentation).
- **New major features enabled** in core modules (e.g., new completion style,
  new session restore behavior, new shell/term handling).
- **Startup launcher or essential workflows modified** (affects §12 and §13).

When in doubt: if an end-user workflow or keybinding changes, `HOWTO.md` likely
needs a corresponding update. Verify with `HOWTO.md` by tracing the section that
documents the feature (use section references like §10, §13, etc.).
