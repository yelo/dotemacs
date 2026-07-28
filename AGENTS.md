# AGENTS.md

This is an Emacs configuration directory. Packages are managed via `package.el`
and installed into `elpa/` (git-ignored). Custom lisp lives under `lisp/`.

- `init.el` — entry point, loads `sanemacs` then `lisp/` modules
- `custom.el` — `custom-set-variables` and `custom-set-faces` (auto-generated)
- `lisp/` — per-concern config modules
- `site-lisp/` — manually installed third-party packages
