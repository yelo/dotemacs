# Emacs Configuration

> **Requires Emacs 31+**

A **vanilla Emacs 31** configuration: modern, minimal, built-in features only.
No external packages—just a well-organized collection of Elisp modules that
enhance the baseline Emacs experience.

**For workflows, keybindings, and detailed how-tos, see [HOWTO.md](HOWTO.md).**

## Quick start

Clone into `~/.config/emacs/` and launch:

```bash
git clone <repo-url> ~/.config/emacs
emacs --init-directory ~/.config/emacs
```

## Architecture

This config is organized as a **modular system**: a bootstrap layer (`init.el`,
`early-init.el`), a set of **core modules** handling UI, editing, completion,
and LSP, optional **language-specific modules** for Python, Rust, C#, and Elisp,
and OS-specific tweaks for macOS, Linux, and Windows. Each module is
independent; features and keybindings are self-contained and easy to customize.

## Support & Navigation

**Supported languages:** Python, Rust, C#, Elisp
**For keybindings and workflows:** See [HOWTO.md](HOWTO.md)
**For detailed feature breakdowns:** Read the module files in `lisp/`

## Startup profiling

Check startup performance:

```bash
emacs --init-directory ~/.config/emacs --eval '(kill-emacs)'
RK_PROFILE_STARTUP=1 emacs --init-directory ~/.config/emacs
```
