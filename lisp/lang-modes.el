;;; lang-modes.el --- language and mode-local leader bindings -*- lexical-binding: t; -*-

;; Emacs Lisp
(rk/lang 'elisp-mode 'emacs-lisp-mode-map
  "e" '(eval-last-sexp :which-key "eval expression")
  "b" '(eval-buffer :which-key "eval buffer")
  "r" '(eval-region :which-key "eval region")
  "d" '(eval-defun :which-key "eval defun")
  "f" '(find-function :which-key "find function")
  "v" '(find-variable :which-key "find variable")
  "h" '(describe-function :which-key "describe function")
  "w" '(elisp-index-search :which-key "search manual")
  "C" '(check-parens :which-key "check parens")
  "i" '(ielm :which-key "ielm REPL")
  "m" '(macroexpand-last-sexp :which-key "macroexpand"))

;; Python
(add-hook 'python-mode-hook #'lsp-deferred)

(rk/lang 'python 'python-mode-map
  "e" '(python-shell-send-statement :which-key "send statement")
  "r" '(python-shell-send-region :which-key "send region")
  "b" '(python-shell-send-buffer :which-key "send buffer")
  "f" '(python-shell-send-file :which-key "send file")
  "'" '(run-python :which-key "REPL")
  "d" '(lsp-find-definition :which-key "go to definition")
  "D" '(lsp-find-references :which-key "find references")
  "R" '(lsp-rename :which-key "rename")
  "a" '(lsp-execute-code-action :which-key "code action"))

;; Rust
(use-package rustic
  :ensure t
  :hook (rustic-mode . lsp-deferred)
  :init
  (setq rustic-lsp-client 'lsp-mode)
  :config
  (rk/lang 'rustic '(rust-mode-map rustic-mode-map)
    "b" '(rustic-cargo-build :which-key "cargo build")
    "c" '(rustic-cargo-check :which-key "cargo check")
    "r" '(rustic-cargo-run :which-key "cargo run")
    "t" '(rustic-cargo-test :which-key "cargo test")
    "f" '(rustic-cargo-fmt :which-key "cargo fmt")
    "l" '(rustic-cargo-clippy :which-key "cargo clippy")
    "d" '(lsp-find-definition :which-key "go to definition")
    "D" '(lsp-find-references :which-key "find references")
    "R" '(lsp-rename :which-key "rename")
    "a" '(lsp-execute-code-action :which-key "code action")
    "=" '(rustic-cargo-outdated :which-key "cargo outdated")))

;; Minor mode tip:
;; Use `rk/minor-mode-leader-keys` sparingly for truly cross-language commands.
;; For reliability, keep primary workflow keys curated on major mode maps.
