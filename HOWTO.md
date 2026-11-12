# HOWTO: Working with Emacs

A short, practical guide to the workflows and keybindings this configuration
provides. It targets Emacs 31+ and uses built-in features as well as external
packages where they make sense.

> **Rule of thumb:** every keybinding is just a shortcut for a named command.
> If you ever forget a binding, run it with `M-x` and then ask Emacs what key it
> lives on (`C-h w <command>`).

`which-key-mode` displays available key continuations after you press a prefix.

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
| `C-c p s` | Live project search (`consult-ripgrep`; requires `rg`) |
| `C-c p b` | Select project buffers/recent files with Consult |
| `C-c p t` | Open a project in a **new tab** (named after the project) |
| `C-c p l` | Switch to the dedicated **Loose Files** tab |

The `C-c p p` switch menu offers `f`/`d`/`s`/`v`/`g` (find-file, dired,
built-in search, VC status, Magit Git status) and Ghostel.
`C-c p s` searches from the current project root and updates results while you
type. Install `ripgrep` if `rg` is missing; `C-x p s` retains the built-in
project search and its grep results buffer.
Ghostel also binds `C-x p m` to open a terminal in the project and `C-x p M`
to select a Ghostel buffer for that project.

Version control lives under `C-c v`:

| Keys | Action |
|------|--------|
| `C-c v d` | `vc-dir` (status; up-to-date files auto-hidden) |
| `C-c v =` | Diff |
| `C-c v l` | Log |
| `C-c v s` | Magit status (Git repositories) |
| `C-c v w` | Switch VC working tree (Emacs 31) |

In Magit status, `TAB` expands a section or diff hunk; `s` stages the file,
hunk, or selected lines at point, and `u` unstages them. `c c` starts a commit;
finish the message with `C-c C-c` or cancel with `C-c C-k`. `b` opens branch
actions, `r` rebase actions, and `?` shows contextual help. Built-in VC remains
available, including for non-Git repositories.

In a `*grep*` results buffer, press `C-c C-e` to enter Emacs 31's built-in
grep-edit mode, edit the matches directly, then use the mode's apply command
to write the changes back to the files. This replaces the third-party `wgrep`
workflow.

---

## 4. Buffer navigation

| Keys | Action |
|------|--------|
| `C-c f` / `C-x C-f` | Find (open) a file |
| `C-c b b` | Consult buffers, recent files, and bookmarks |
| `C-x b` | Stock buffer switching, with Vertico completion |
| `C-c b k` | Kill (close) the current buffer |
| `C-c b r` | Revert buffer from disk |
| `C-c b l` / `C-x C-b` | List all buffers |
| `C-c b n` / `C-c b p` | Next / previous buffer |
| `C-c r` | Consult recent files (`recentf`) |
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
    If that window is no longer eligible, another non-side, non-dedicated
    editing window in the same frame is selected.

`*Help*` windows auto-focus (`help-window-select`), so no `C-x o` needed to read
them.

Magit uses its normal editing-window display, not the dedicated Help or
compilation side windows.

---

## 6. Workspaces & tabs (`C-x t`)

`tab-bar-mode` is used as a lightweight **project-per-tab workspace** switcher
(see `core-tabs.el`). Each tab holds its own window layout, so switching
projects into a fresh tab keeps unrelated buffers/windows from piling up. A
dedicated **Loose Files** tab is used for files outside any project.

| Keys | Action |
|------|--------|
| `C-x t 2` | New tab (opens the launcher) |
| `C-x t 0` | Close current tab |
| `C-x t o` / `C-x t O` | Next / previous tab |
| `C-x t t` | Recent-tab switcher |
| `C-c p l` | Switch to or create the **Loose Files** tab |

Workflow: `C-c p t` opens the chosen project in a new tab that is
**automatically renamed** to the project name. The tab bar is hidden until you
have more than one tab (`tab-bar-show 1`). Ordinary file opening (`C-c f`,
`C-x C-f`, recent files, and Speedbar) keeps project files in their matching
project tab and sends non-project files to **Loose Files**. Opening a file
outside the active project therefore does not pollute that project workspace.

Accepted file candidates from Consult's recent-file and project-recent-file
sources follow the same routing policy. Previewing candidates or cancelling
selection does not switch/create tabs. Selecting an already-open buffer in
Consult remains a buffer switch, not a new routed file visit.

---

## 7. desktop-mode & session restore

- **`desktop-save-mode`** (on by default, `core-settings.el`) saves your session
  — buffers, window/frame layout — to
  `~/.config/emacs/cache/desktop/desktop` by default and restores it on startup.
  The desktop is created automatically on the first normal exit (`C-x C-c`).
  Use `M-x desktop-save` to save on demand.
- **`save-place-mode`** remembers point per file (§4).
- Frame **colors and fonts are not restored** from the saved session — they
  always come from the current theme and `core-ui.el`, so restoring a session
  saved in dark mode never leaves a light theme on a dark frame.
- **`savehist-mode`** persists minibuffer history, the kill ring, and search
  history across sessions.
- EWW browser history is saved without duplicate removal. This preserves its
  current-page position and avoids an Emacs 31 desktop-save error on quit;
  older restored EWW buffers with a missing position save as the current page.

To start fresh without a restored session, run
`M-x desktop-clear` or remove the `desktop/` entry in your cache directory.
All writable state paths are rooted at `rk/cache-directory` (`M-x
customize-variable RET rk/cache-directory`), so you can switch between a
persistent cache and a tmp-backed ephemeral cache.

---

## 8. Completion & the minibuffer (`core-completion.el`)

**Vertico** replaces Fido with a vertical candidate list inside the minibuffer.
Use `↑`/`↓` to navigate, `TAB` to insert the highlighted candidate into the
prompt, and `RET` to accept it. To submit your literal input (for example a
new file/buffer name), use `M-RET`, or move up to the prompt and press `RET`.
The standard `*Completions*` buffer is still available when explicitly requested.

**Orderless** matches space-separated terms in any order: `M-x file project`
can match `project-find-file`. Matching ignores case and supports literal
terms and fuzzy subsequences: `M-x swb` can match `switch-to-buffer`.
File paths retain basic/partial-path matching for
wildcards and TRAMP rather than using Orderless everywhere.
**Marginalia** adds descriptions and other useful annotations to candidates.
History is still saved by `savehist-mode`.

**Consult** adds navigation with previews:

| Keys | Action |
|------|--------|
| `C-c b b` | Buffers, recent files, and bookmarks; narrow with `b SPC` / `f SPC` / `m SPC` |
| `C-c p b` | Project buffers/recent files |
| `C-c r` | Recent files |
| `C-c i` | Symbols in the current buffer (`consult-imenu`) |
| `C-c p s` | Live ripgrep search in the current project |
| `M-s l` | Search/select a line in the current buffer (`consult-line`) |

Line, symbol, and existing-buffer previews update as you navigate. For
recent files, file registers, and bookmarks, press `M-.` explicitly to preview;
simply moving through those candidates does not open remote connections.
`C-g` cancels and restores the original view. File-source acceptance preserves
the workspace policy (§6); previews do not route files.
`C-s`, `C-x b`, `C-x p s`, and `M-y` retain their stock commands.

**Corfu** displays in-buffer completion candidates near point, using the same
CAPFs/Eglot servers as before. Popups are manual: `TAB` indents or invokes
completion (`tab-always-indent` is `complete`); `M-TAB` invokes completion
directly. The prompt is selected initially. Use `↑`/`↓` to select a candidate,
then `RET` to insert it; `TAB` also inserts an explicitly selected candidate.
With the prompt selected, `TAB` may expand a common prefix and `RET` dismisses
completion without choosing a candidate. `C-g` dismisses the popup.
Candidates are not automatically previewed/committed as you keep typing.

Inline `completion-preview` is disabled, so `M-TAB` no longer accepts ghost
text. Corfu works in graphical and terminal Emacs 31 without an extra package.
Eglot keeps its existing flex matching and ordering override rather than
inheriting Orderless matching from the minibuffer. Ambiguous fuzzy input stays
unchanged until you select a candidate or narrow to a unique match.

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
| `C-c i` | Consult imenu (preview/jump to symbol in buffer) |
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

In-buffer completion is presented by Corfu (§8), but language-server selection,
Eglot, and Flymake are unchanged.

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
  `rk/dotnet-target` (and optionally `rk/dotnet-extra-args`, e.g. `"-c Debug"`).
  Extra arguments are parsed as data and individually shell-quoted. Double-quote
  whole arguments containing whitespace (e.g. `--name "two words"`); shell
  operators, redirection, and expansions are not executed. For intentional shell
  syntax, use `C-u C-u` and edit the full command line.
  Install the preferred server with `dotnet tool install --global csharp-ls`; the Roslyn
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

`M-x eshell` (recommended), `M-x shell`, `M-x term`, or `M-x ghostel`. These
terminals open in the bottom side window, with line numbers disabled. Ghostel
is also available at `C-c s`; its native module can be downloaded on first
use (Emacs must support dynamic modules). In Ghostel's default semi-char mode,
`C-s` searches the scrollback with Consult, and `C-c C-t` enters copy mode.

- `eshell` runs your normal commands with extra Emacs niceties (e.g. globbing,
  redirecting to buffers).
- Interactive full-screen programs (`htop`, `top`, `less`, `ssh`, `tmux`) are
  handed off to `term` automatically so they don't garble the eshell buffer.
- `C-x p m` opens a Ghostel terminal in the current project; `C-x p M` lists
  its Ghostel buffers. Ghostel also appears in the project-switch menu.

**GitHub Copilot with agent-shell** — `C-c p a` starts a Copilot agent session
in the current project. This uses the Copilot CLI's ACP server; install the
CLI and authenticate once with `copilot login`. `agent-shell` and its Emacs
dependencies are installed from MELPA when Emacs starts.

---

## 13. Startup behavior

On startup, Emacs restores your previous desktop/session (see §7) instead of
opening a launcher buffer. Startup timing is reported in `*Messages*` (for
example: `Emacs ready in 0.45 seconds with 5 garbage collections.`).

All discovered `lang-*.el` modules load during init, before files are visited.
Language hooks therefore apply to the first command-line file and to buffers
restored from the desktop, without waiting for an idle timer.

Module loading is fail-soft: if one module in `lisp/` signals an error, the
error is reported in `*Messages*` (`Error loading …`) and the remaining modules
still load, so Emacs always comes up usable.

External completion packages and Magit are declared with `use-package` and
installed through package.el from GNU/NonGNU ELPA when missing. `agent-shell`
and its dependencies are installed from MELPA. Initial installation requires
network access; routine startup does not refresh the archives or update every
package. Consult, Magit, and agent-shell load when invoked, while Vertico,
Orderless, Marginalia, and Corfu are enabled during startup.
Installation/loading failures are reported through normal Emacs warnings and
module-loading messages.

After upgrading Emacs, an older compiled package can still refer to Compat
helpers that the new built-in Compat no longer defines. If Vertico reports
`void-function compat--seconds-to-string` while annotating files, recompile
Marginalia against the current Emacs:

```elisp
(byte-recompile-directory
 (file-name-directory (locate-library "marginalia")) 0 t)
```

Evaluate this with `M-:`, then restart Emacs to unload the old compiled code.
This preserves relative file-age annotations; disabling Vertico is unnecessary.

On multi-user macOS systems, run Emacs daemon mode as a **per-user
LaunchAgent**, not a system LaunchDaemon. This keeps each user's server socket,
buffers, config, and filesystem permissions isolated. Connect with
`emacsclient -c` for a GUI frame or `emacsclient -t` in the terminal. TTY-only
tweaks are loaded only for direct terminal Emacs sessions, not during daemon
startup before any client frame exists.

---

## 13a. Appearance & themes

This config uses the external **Foxglove** theme package:
**foxglove** (light) and **foxglove-dark** (dark). It is installed from
[vegasharmon/foxglove-themes](https://gitlab.com/vegasharmon/foxglove-themes)
with Emacs's built-in `use-package` VC support; its required Modus Themes
dependency is installed by the package manager when needed.

| Keys | Action |
|------|--------|
| `C-c t` | Toggle between `foxglove` and `foxglove-dark` |

The toggle disables the current theme and loads the other. The modeline and all
UI elements adapt automatically. To customize theme settings, see the Foxglove
package documentation; UI face tweaks are in `core-ui.el`.

The theme package and light theme are loaded while `core-ui.el` loads, so the
first frame is already drawn with the selected theme.

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
2. `C-c p f` → jump to a file with Vertico completion.
3. `C-c p s` → search across the project; `C-c i` → jump to a function.
4. `C-c w z` → zoom the editor while you focus.

**Review & fix code**
1. Edit; flymake highlights errors in the fringe.
2. `C-c ! n` / `C-c ! p` to step through issues.
3. `M-x eglot-code-actions` for quick-fixes; `M-.` to read definitions.
4. `C-c v s` → review/stage hunks in Magit; `C-c v =` / `C-c v d` retain
   built-in VC diff/status.

**Run tests & iterate**
1. Your language's test/build command is available via helpers (see §10). For
   example, Python offers `C-c t a`/`C-c t t` (pytest), Rust uses `M-x
   rk/rust-cargo test`, C# has `C-c c t` (dotnet test).
2. Compile/test output appears in a bottom window and stops at the first failure.
3. Fix errors and re-run: most test runners show line references Emacs can jump to.
