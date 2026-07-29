# AGENTS.md

This is an Emacs configuration directory. Packages are managed via `package.el`
and installed into `elpa/` (git-ignored). Custom lisp lives under `lisp/`.

- `init.el` — entry point, loads `sanemacs` then `lisp/` modules
- `custom.el` — `custom-set-variables` and `custom-set-faces` (auto-generated)
- `lisp/` — per-concern config modules
- `site-lisp/` — manually installed third-party packages

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
selection — any change that alters what a reader would learn about the config
should be reflected there.
