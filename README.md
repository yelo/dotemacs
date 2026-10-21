# Emacs Configuration

> **Requires Emacs 31+**

A personal Emacs 31+ configuration: modern and modular, using built-in
features alongside external packages where they make sense.

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
editing, completion, LSP integration, Markdown, and Org writing support. These
form the foundation of the configuration and are loaded in a fixed order to
ensure proper initialization.

**Language-specific modules** (`lang-python.el`, `lang-rust.el`, etc.) extend
support for particular programming languages.
They load during init so language hooks apply to the first opened file and to
buffers restored from the saved desktop.

**OS-specific modules** adapt the configuration for macOS, Linux, and Windows.

**Helper scripts** in `scripts/` support first-party modules where Emacs needs
to call out to host OS functionality, such as macOS native spell checking.

Each module is independent; features and keybindings are self-contained and
easy to customize or disable.

Packages are managed with Emacs's built-in package support and `use-package`;
VC-hosted packages can be declared directly from their upstream repositories.
Missing declared packages are installed during startup; Consult and Magit load
on demand. The completion and Git packages below use the default GNU/NonGNU
ELPA archives.
An initial installation needs network access; packages are not automatically
updated on each startup.

## Completion, search, and Git

- **Vertico**, **Orderless**, and **Marginalia** provide vertical minibuffer
  completion, out-of-order matching, and informative candidate annotations.
- **Consult** adds previewable buffer/symbol navigation and live project
  search. Install **ripgrep** (`rg`) for `C-c p s`; built-in project search
  remains available at `C-x p s`.
- **Corfu** provides manually triggered in-buffer completion using existing
  CAPFs and Eglot. `TAB` indents/completes; navigate to a candidate and accept
  explicitly. It replaces inline completion previews and supports GUI and
  terminal Emacs 31 without a companion package.
- **Magit** adds Git status and staging at `C-c v s`, alongside the existing
  built-in VC shortcuts. Install **Git** on the host.

Eglot, Flymake, project.el, Speedbar, and tab-bar/desktop remain the underlying
language, diagnostics, project, file-tree, and workspace/session facilities.

## Support & Navigation

**Supported languages:**
- Python
- Rust
- C#
- Elisp

**Documentation:**
- Keybindings and workflows: [HOWTO.md](HOWTO.md)
- Detailed feature breakdowns: See module files in `lisp/`

**Writing:** Org mode is configured for notes, tasks, agenda basics, and spell
checking in Finnish, Swedish, and English. On macOS, org buffers use the native
system dictionaries through Flymake diagnostics; elsewhere, or when native
checking is unavailable, Hunspell remains the fallback and dictionaries must be
installed separately on the host system.

## Startup profiling

Check startup performance:

```bash
emacs --init-directory ~/.config/emacs --eval '(kill-emacs)'
RK_PROFILE_STARTUP=1 emacs --init-directory ~/.config/emacs
```

## Configuration checks

After installing the declared packages, run the focused completion/routing
regressions from this repository:

```bash
emacs -Q --init-directory . --batch \
  --eval "(progn (require 'package) (package-initialize))" \
  -l tests/core-completion-tests.el -f ert-run-tests-batch-and-exit
```

The checks use temporary history and file fixtures, not the saved desktop.
