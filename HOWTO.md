# HOWTO: Working with Emacs

A short, practical guide to the workflows and keybindings this configuration
provides. This is a **vanilla Emacs 31** setup — everything below is built-in,
no external packages.

> **Rule of thumb:** every keybinding is just a shortcut for a named command.
> If you ever forget a binding, run it with `M-x` and then ask Emacs what key it
> lives on (`C-h w <command>`).

---

## 1. Getting help

Help is one keystroke away. Learn these first.

| Keys | What it does |
|------|--------------|
| `C-h ?` / `C-h C-h` | Help overview (the "meta-help" page) |
| `C-h k <key>` | Describe what a **key** does |
| `C-h f <name>` | Describe a **function**/command |
| `C-h v <name>` | Describe a **variable** |
| `C-h b` | All keybindings in the current buffer |
| `C-h m` | Describe the current **mode** and its bindings |
| `C-h w <cmd>` | Find the key for a command (`where-is`) |
| `C-h a <word>` | Apropos: search commands (`C-h d` searches docs too) |
| `C-h .` | Help for the thing at point (ElDoc) |
| `C-h t` | The interactive tutorial |
| `C-h r` | The full Emacs manual |
| `C-h i` | Info browser |

Also useful: `M-x reload-config` reloads `init.el` without restarting.

---

## 2. The mental model

Emacs is built from a few nested concepts:

- **Buffer** — the fundamental object. A file, a help page, dired, eshell, and
  compile output are *all* buffers. You don't "close files", you switch or kill
  buffers.
- **Window** — a viewport into a buffer. One buffer can appear in many windows.
- **Frame** — an OS window.
- **Tab** — here, a *workspace* (a saved window layout). See §7.

Key consequences:

- Popups (help, compilation, shell) are just buffers shown in *side windows* —
  see §6 for where they land.
- `C-g` is your universal "cancel/escape". Always press it first when stuck.
- `M-x` runs any command by name; completion makes discovery easy (§9).

---

## 3. Projects (`C-c p`)

This config adds a mnemonic `C-c p` prefix (see `core-keybindings.el`). The
stock `C-x p` prefix works too (`C-x p p`, `C-x p f`, …).

| Keys | Action |
|------|--------|
| `C-c p f` | Find a file in the project |
| `C-c p p` | Switch project (project.el menu) |
| `C-c p d` | Open the project root in dired |
| `C-c p s` | Search across the project (`project-find-regexp`) |
| `C-c p t` | Open a project in a **new tab** (named after the project) |

The `C-c p p` switch menu offers `f`/`d`/`s`/`v` (find-file, dired, search,
VC status) — configured in `core-vc.el`.

Version control lives under `C-c v`:

| Keys | Action |
|------|--------|
| `C-c v d` | `vc-dir` (status; up-to-date files auto-hidden) |
| `C-c v =` | Diff |
| `C-c v l` | Log |

In a `*grep*` results buffer, press `C-c C-e` to enter Emacs 31's built-in
grep-edit mode, edit the matches directly, then use the mode's apply command
to write the changes back to the files. This replaces the third-party `wgrep`
workflow.

---

## 4. Buffer navigation

| Keys | Action |
|------|--------|
| `C-c f` / `C-x C-f` | Find (open) a file |
| `C-c b b` / `C-x b` | Switch buffer (fido vertical completion) |
| `C-c b k` | Kill (close) the current buffer |
| `C-c b r` | Revert buffer from disk |
| `C-c b l` / `C-x C-b` | List all buffers |
| `C-c b n` / `C-c b p` | Next / previous buffer |
| `C-c r` | Recent files (`recentf`) |
| `C-x C-j` | Jump to the current file's directory in dired |
| `C-l` | Recenter the view around point |

Conveniences enabled for you:

- **`save-place-mode`** — remembers your cursor position per file between
  sessions.
- **`uniquify`** — same-named files from different dirs are disambiguated as
  `foo<project>` instead of `foo`, `foo<2>`.
- **`global-auto-revert-mode`** — buffers update when files change on disk.

---

## 5. Windows & popups (`C-c w`)

The `C-c w` prefix (see `core-windows.el`) manages window layouts:

| Keys | Action |
|------|--------|
| `C-c w s` | Split below |
| `C-c w v` | Split right (vertical bar) |
| `C-c w k` | Kill (close) this window pane |
| `C-c w K` | Kill all other window panes |
| `C-c w o` | Other window |
| `C-x O` | Other window, backwards (built-in, Emacs 31: `other-window-backward`) |
| `C-c w =` | Balance window sizes |
| `C-c w z` | Zoom current window (toggle maximize) |
| `C-c w t` | Transpose the layout |
| `C-c w r` / `R` | Rotate layout clockwise / counter-clockwise |
| `C-c w f` / `F` | Flip layout left-right / top-bottom |
| `C-c w S` | Toggle Speedbar in a side window (same frame) |
| `Shift+←/→/↑/↓` | Move between windows (`windmove`) |
| `C-c ←` / `C-c →` | Undo / redo window config (`winner-mode`) |

**Where popups land** (via `display-buffer-alist`):

- `*Help*`, `*Apropos*`, `*info*`, `*Man*`, `*xref*`, `*eldoc*` → **right** side
- `*Compilation*`, flymake, `*Messages*`, `*Warnings*`, `*Backtrace*` → **bottom**
- `eshell`/`shell`/`term` → **bottom**
- Speedbar (`C-c w S` / `M-x rk/speedbar-toggle`) → **left** side window
  in the current frame (not a separate frame)
  - Opening files from Speedbar (`RET` / click) reuses the last non-side
    editing window in that frame for consistent navigation.

`*Help*` windows auto-focus (`help-window-select`), so no `C-x o` needed to read
them.

---

## 6. Workspaces & tabs (`C-x t`)

`tab-bar-mode` is used as a lightweight **project-per-tab workspace** switcher
(see `core-tabs.el`). Each tab holds its own window layout, so switching
projects into a fresh tab keeps unrelated buffers/windows from piling up.

| Keys | Action |
|------|--------|
| `C-x t 2` | New tab (opens the launcher) |
| `C-x t 0` | Close current tab |
| `C-x t o` / `C-x t O` | Next / previous tab |
| `C-x t t` | Recent-tab switcher |

Workflow: `C-c p t` opens the chosen project in a new tab that is
**automatically renamed** to the project name. The tab bar is hidden until you
have more than one tab (`tab-bar-show 1`).

---

## 7. desktop-mode & session restore

- **`desktop-save-mode`** (on by default, `core-settings.el`) saves your session
  — buffers, window/frame layout — to
  `~/.config/emacs/cache/desktop/desktop` by default and restores it on startup.
  Use `M-x desktop-save` to save on demand.
- **`save-place-mode`** remembers point per file (§4).
- Frame **colors and fonts are not restored** from the saved session — they
  always come from the current theme and `core-ui.el`, so restoring a session
  saved in dark mode never leaves a light theme on a dark frame.
- **`savehist-mode`** persists minibuffer history, the kill ring, and search
  history across sessions.

To start fresh without a restored session, run
`M-x desktop-clear` or remove the `desktop/` entry in your cache directory.
All writable state paths are rooted at `rk/cache-directory` (`M-x
customize-variable RET rk/cache-directory`), so you can switch between a
persistent cache and a tmp-backed ephemeral cache.

---

## 8. Completion & the minibuffer (`core-completion.el`)

- **`fido-vertical-mode`** gives you a vertical completion UI directly inside
  the minibuffer, without opening a duplicate `*Completions*` window for every
  minibuffer command. The standard `*Completions*` buffer remains available
  when explicitly requested or used by completion contexts that do not use
  Fido.
- **Completion styles** are `basic`, `partial-completion`, `flex`, `initials`,
  `substring` — so `M-x` and `C-x b` match abbreviations, substrings, and
  fuzzy in-order patterns
  (e.g. `M-x rvb` → `revert-buffer`; `C-x b p t` → `project-todos`).
- **Minibuffer completion navigation** supports `↑`/`↓`; `RET` accepts the
  highlighted completion candidate.
- **`completion-preview-mode`** shows inline completion previews in code
  buffers; press `M-TAB` to accept the preview.
- **`tab-always-indent`** is `complete`, so `TAB` indents or triggers
  completion at point (CAPF/Eglot). `TAB` is intentionally *not* bound to
  preview acceptance so it can always reach the completion popup.
- **Eglot completion** uses `rk/flex-noinsert`: flex-ranked candidates are kept,
  but ambiguous `TAB` no longer inserts merged fuzzy guesses before selection.

When `*Completions*` is shown, it uses detailed, grouped, one-column display
with historical sorting and a bounded height. `TAB` remains dedicated to
indentation/completion at point; `M-TAB` accepts an inline preview.

---

## 9. Editing essentials & best practices

Learn and memorize these stock bindings:

| Keys | Action |
|------|--------|
| `C-x C-f` | Open file |
| `C-x C-s` | Save |
| `C-x C-c` | Quit Emacs |
| `C-x u` / `C-_` | Undo |
| `C-g` | Cancel / abort |
| `C-s` / `C-r` | Incremental search forward / backward |
| `C-SPC` | Set mark (start a region) |
| `C-w` | Kill (cut) region — or kill previous word if no region (`kill-region-dwim`) |
| `M-w` | Copy region |
| `C-y` / `M-y` | Yank (paste) / cycle earlier kills |
| `C-a` / `C-e` | Beginning / end of line |
| `M-f` / `M-b` | Forward / backward word |
| `C-n` / `C-p` / `C-f` / `C-b` | Move down / up / right / left |
| `C-v` / `M-v` | Page down / up |
| `C-k` | Kill to end of line |
| `C-u` | Universal argument (prefix for counts, e.g. `C-u 5 C-n`) |

Config-specific niceties:

- **`electric-pair-mode`** — brackets/quotes auto-pair.
- **`global-subword-mode`** — motion stops at camelCase/snake_case boundaries.
- **`repeat-mode`** — repeatable commands continue on their first key (e.g.
  `C-x o o o`).
- **`hs-minor-mode`** — code folding with fringe indicators.
- **`M-DEL` / `C-DEL`** — delete word backward *without* touching the kill ring.
- **`C->` / `C-<`** — indent region right / left.
- **`M-/`** — dynamic abbreviation expansion (word completion).
- **Incremental search** shows lazy match counts, allows scrolling and motion
  while searching, repeats immediately when changing direction, and wraps
  without a warning beep. `C-.` searches forward for the thing at point.
- **`C-x h`** — select all; **`C-x C-x`** — swap point and mark.
- **Trailing whitespace on save** — stripped automatically in **code buffers
  only** (`prog-mode`). Text and Markdown buffers are left alone, so Markdown's
  two-space hard line breaks survive.

**macOS modifiers** (`os-macos.el`): `Cmd` = Super (so `Cmd+C/V/X/A/Z` are the
usual copy/paste/cut/select-all/undo), left `Option` = Meta (`M-`), right
Option = none (for composed/unicode chars).

**macOS tool discovery** (`os-macos.el`): GUI Emacs doesn't inherit the login
shell's `PATH`, so it is rebuilt with the system's own `path_helper`, honouring
`/etc/paths` and `/etc/paths.d` in the same order a terminal sees. No tool
locations are hardcoded, so an SDK that registers itself there (like the .NET
installer) resolves identically inside and outside Emacs. `DOTNET_ROOT` is
derived from whichever `dotnet` that `PATH` resolves to, never pinned to a
specific install, so `global.json` picks the SDK version for each project.
`DOTNET_HOST_PATH` is set beside that real host as well, preventing global
.NET tools such as the Roslyn language server from mistaking Homebrew's
`bin/dotnet` shim for an SDK installation.

**Best practices:**

1. **Think in commands, not menus.** Type `M-x` + a few letters to discover.
2. **`C-g` first.** Whenever something is wrong, escape out.
3. **Save often** (`C-x C-s`); backups/autosaves are redirected to
   `rk/cache-directory`, not your working tree, so no `~`/`#` clutter.
4. **Search to navigate** — `C-s`, `C-c p s`, and `C-c i` (imenu, jump to a
   function) are usually faster than scrolling.
5. **Kill buffers, not windows.** Close a side-window's buffer with `C-x k`;
   layout undo is `C-c ←`.
6. **Use one tab per task/project** to keep contexts isolated (§6).
7. When screen-sharing or teaching, `C-h l` (`view-lossage`) shows recent keys.

---

## 10. LSP & diagnostics (eglot + flymake)

`eglot` is configured via **language modules** in `lisp/lang-*.el`. Each module
registers an LSP server program and enables eglot for that language's major modes.
Currently configured: Python (`pylsp`), Rust (`rust-analyzer`), C#
(`csharp-ls`, with `roslyn-language-server` fallback when necessary),
and Elisp (built-in). To add support for a new language, create `lisp/lang-newlang.el`
and register your LSP server; language servers must be installed separately per
each module's documentation.

**Python virtualenv auto-detection:** `lang-python.el` automatically looks for
a virtualenv in the project root (checking `.venv`, `venv`, then `env`, in that
order) using only built-in `project.el` — no third-party packages (e.g.
`pyvenv`, `pet`) are required. When found, it sets the buffer-local
`python-shell-virtualenv-root` and prepends the venv's `bin`/`Scripts`
directory to `exec-path`/`PATH`. Eglot then prefers the venv's own `pylsp`
binary if present, falling back to a global `pylsp` on `PATH` otherwise.

Where an Emacs tree-sitter grammar is installed, supported language buffers
automatically use the corresponding built-in `*-ts-mode` with maximum
font-lock detail. Without a grammar, the ordinary major mode remains in use.

| Keys | Action |
|------|--------|
| `C-c ! l` | List diagnostics |
| `C-c ! n` / `p` | Next / previous error |
| `C-c ! s` | Start flymake |
| Hover a C# symbol | Show its Eglot signature and documentation in a tooltip |
| `M-.` | Jump to definition (`xref-find-definitions`; stock Emacs) |
| `⌘-click` (`s-mouse-1`) | Jump to definition with mouse |
| `M-,` | Go back (`xref-go-back`; stock Emacs) |
| `M-?` | Find references |
| `C-c i` | imenu (jump to symbol in buffer) |
| `M-x eglot-rename` | Rename symbol |
| `M-x eglot-code-actions` | Quick-fixes / code actions |

In C# buffers, move the mouse over a symbol and wait for the usual tooltip
delay to see the language server's signature and documentation. ElDoc continues
to show the same information for the symbol at point, which also works in a
terminal session. With a graphical Emacs, this configuration enables
`tooltip-mode`; other buffers continue to use their normal Emacs tooltips.

`M-.` and `⌘-click` also follow definitions in referenced .NET SDK assemblies.
`csharp-ls` is started with its `metadata-uris` feature enabled, so SDK
definitions open as navigable decompiled metadata source. Roslyn remains a
fallback and may open real source when symbols or Source Link make it
available; otherwise it also provides metadata/decompiled definitions. The
precise result depends on the language server, installed SDK, and the
referenced assembly's symbols; `M-,` always returns to the calling code.

Compile/test output auto-scrolls continuously
(`compilation-scroll-output t`).

**Language-specific helpers** — Each language module provides commands for its
build/test/run tools. For example:

- **Python:** `C-c t a` (run all pytest), `C-c t t` (run current test)
- **Rust:** `M-x rk/rust-cargo` (run cargo subcommand interactively)
- **C#:** `C-c c b` (build), `C-c c r` (run), `C-c c t` (test), `C-c c w`
  (`dotnet watch run`), `C-c c c` (clean), `C-c c n` (restore), `C-c c !`
  (arbitrary `dotnet` subcommand). Each prompts for the solution/project file
  with completion (multi-project solutions), remembers the last target per
  workspace, and accepts `C-u` for extra arguments or `C-u C-u` to edit the
  whole command line. Pin a default per repository in `.dir-locals.el` with
  `rk/dotnet-target` (and optionally `rk/dotnet-extra-args`). Install the
  preferred server with `dotnet tool install --global csharp-ls`; the Roslyn
  language server remains a fallback.
- **Elisp:** `C-c C-b` (eval buffer), `C-c C-d` (eval defun), `C-c C-z`
  (ielm REPL), `C-c C-f`/`C-c C-v` (find function/variable)

---

## 11. Org, notes & spell checking

Org mode is configured as a lightweight writing and task system
(`core-org.el`): visual line wrapping is enabled in org buffers, startup uses
indented content folding, emphasis markup is hidden, and completed TODOs log a
timestamp.

| Keys / command | Action |
|----------------|--------|
| `C-c a` | Open the org agenda |
| `C-c l` | Store a link for later insertion |
| `M-x rk/spell-set-dictionary` | Switch among the configured dictionaries |
| `M-x flymake-show-buffer-diagnostics` | List spelling diagnostics when using macOS native checking |
| `M-x ispell-change-dictionary` | Switch the dictionary for Hunspell/Flyspell fallback |
| `M-x flyspell-mode` | Toggle fallback live spell checking in the current buffer |
| `M-x ispell-buffer` | Spell-check the current buffer with the fallback checker |

Org buffers default to the Finnish dictionary (`fi_FI`) for Finnish practice.
The configured dictionaries are:

- `fi_FI` — Finnish
- `sv_SE` — Swedish
- `en_US` — English

On macOS, org buffers prefer the native system spell checker through
`NSSpellChecker`. Misspellings appear as Flymake diagnostics, using the same
diagnostic commands as code buffers (`C-c ! l`, `C-c ! n`, `C-c ! p`). The
Emacs dictionary names above are mapped internally to macOS language IDs:
`fi_FI` → `fi`, `sv_SE` → `sv`, and `en_US` → `en`.

Use `M-x rk/spell-set-dictionary RET sv_SE RET` to switch the current org buffer
to Swedish, and similarly for `fi_FI` or `en_US`.

Hunspell remains the portable fallback, because Emacs' stock `ispell` and
`flyspell` interfaces require an ispell-compatible process. Hunspell and its
dictionaries are system dependencies, not Emacs packages. Install the
`hunspell` executable plus Finnish, Swedish, and English dictionaries with your
OS package manager when you need the fallback path.

Basic task states are `TODO`, `NEXT`, `WAIT`, `DONE`, and `CANCELLED`.
Agenda files live under `~/.org/`, which is created automatically, with
`~/.org/notes.org` as the default notes file. Refile targets include headings up
to level 3 in the current file and agenda files.

---

## 12. Shells

`M-x eshell` (recommended), `M-x shell`, or `M-x term`. All open in the bottom
side window. Line numbers are disabled automatically in shell/term buffers.

- `eshell` runs your normal commands with extra Emacs niceties (e.g. globbing,
  redirecting to buffers).
- Interactive full-screen programs (`htop`, `top`, `less`, `ssh`, `tmux`) are
  handed off to `term` automatically so they don't garble the eshell buffer.

---

## 13. Startup behavior

On startup, Emacs restores your previous desktop/session (see §7) instead of
opening a launcher buffer. Startup timing is reported in `*Messages*` (for
example: `Emacs ready in 0.45 seconds with 5 garbage collections.`).

Module loading is fail-soft: if one module in `lisp/` signals an error, the
error is reported in `*Messages*` (`Error loading …`) and the remaining modules
still load, so Emacs always comes up usable.

On multi-user macOS systems, run Emacs daemon mode as a **per-user
LaunchAgent**, not a system LaunchDaemon. This keeps each user's server socket,
buffers, config, and filesystem permissions isolated. Connect with
`emacsclient -c` for a GUI frame or `emacsclient -t` in the terminal. TTY-only
tweaks are loaded only for direct terminal Emacs sessions, not during daemon
startup before any client frame exists.

---

## 13a. Appearance & themes

This config uses **modus-operandi-tinted** (light) and **modus-vivendi-tinted**
(dark) themes, built into Emacs 31+. Both are WCAG AAA compliant and
optimized for accessibility.

| Keys | Action |
|------|--------|
| `C-c t` | Toggle between light and dark theme |

The toggle disables the current theme and loads the other. The modeline and all
UI elements adapt automatically. If you want to customize theme settings, edit
`core-ui.el` (see `rk/toggle-light-dark-theme` and `rk/apply-ui-face-tweaks`).

The theme is applied while `core-ui.el` loads (not after startup), so the first
frame is already drawn with it — no flash of the default theme.

**Font** — `core-ui.el` is the single source of truth: `rk/font-family` and
`rk/font-size` (default *Iosevka Nerd Font 14*) feed both the frame defaults and
the `default`/`fixed-pitch` faces. If the font isn't installed, the settings are
skipped and Emacs falls back to the system default instead of erroring.

The current line is highlighted by `global-hl-line-mode` using the theme's own
`hl-line` background.

---

## 14. Daily workflows

**Start work on a project**
1. `C-c p t` → open project in a new tab (or `C-c p p` to switch in place).
2. `C-c p f` → jump to a file (completion preview helps).
3. `C-c p s` → search across the project; `C-c i` → jump to a function.
4. `C-c w z` → zoom the editor while you focus.

**Review & fix code**
1. Edit; flymake highlights errors in the fringe.
2. `C-c ! n` / `C-c ! p` to step through issues.
3. `M-x eglot-code-actions` for quick-fixes; `M-.` to read definitions.
4. `C-c v =` to review your diff, `C-c v d` for status.

**Run tests & iterate**
1. Your language's test/build command is available via helpers (see §10). For
   example, Python offers `C-c t a`/`C-c t t` (pytest), Rust uses `M-x
   rk/rust-cargo test`, C# has `C-c c t` (dotnet test).
2. Compile/test output appears in a bottom window and stops at the first failure.
3. Fix errors and re-run: most test runners show line references Emacs can jump to.
