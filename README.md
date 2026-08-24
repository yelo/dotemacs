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

This config is organized as a **modular system**. At its core are two bootstrap
files: `init.el` and `early-init.el`, which handle loading and initial setup.

The **core modules** in `lisp/` provide essential functionality: UI rendering,
editing, completion, and LSP integration. These form the foundation of the
configuration and are loaded in a fixed order to ensure proper initialization.

**Language-specific modules** (`lang-python.el`, `lang-rust.el`, etc.) extend
support for particular programming languages.

**OS-specific modules** adapt the configuration for macOS, Linux, and Windows.

Each module is independent; features and keybindings are self-contained and
easy to customize or disable.

## Support & Navigation

**Supported languages:**
- Python
- Rust
- C#
- Elisp

**Documentation:**
- Keybindings and workflows: [HOWTO.md](HOWTO.md)
- Detailed feature breakdowns: See module files in `lisp/`

## Startup profiling

Check startup performance:

```bash
emacs --init-directory ~/.config/emacs --eval '(kill-emacs)'
RK_PROFILE_STARTUP=1 emacs --init-directory ~/.config/emacs
```
