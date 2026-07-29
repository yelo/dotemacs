;;; lang-python.el --- Python bindings -*- lexical-binding: t; -*-

(add-hook 'python-mode-hook #'lsp-deferred)

;; ── ruff-format: format on save ──
(use-package ruff-format
  :ensure t
  :hook (python-mode . ruff-format-on-save-mode))

;; ── pyvenv: virtual environment management ──
(use-package pyvenv
  :ensure t
  :hook (python-mode . pyvenv-mode)
  :config
  (defun rk/pyvenv-auto-activate ()
    (let ((venv (locate-dominating-file default-directory ".venv")))
      (when venv
        (pyvenv-activate (expand-file-name ".venv" venv)))))
  (add-hook 'python-mode-hook #'rk/pyvenv-auto-activate))

;; ── pytest: test runner ──
(use-package pytest
  :ensure t
  :hook (python-mode . pytest-mode))

;; ── lsp-ruff: LSP-based linting via ruff (bundled with lsp-mode) ──
(use-package lsp-ruff
  :ensure nil
  :after lsp-mode
  :custom
  (lsp-ruff-lint-enable t))

;; ── keybindings ──
(rk/lang 'python 'python-mode-map
  "e" '(python-shell-send-statement :which-key "send statement")
  "r" '(python-shell-send-region :which-key "send region")
  "b" '(python-shell-send-buffer :which-key "send buffer")
  "f" '(python-shell-send-file :which-key "send file")
  "'" '(run-python :which-key "REPL")
  "d" '(lsp-find-definition :which-key "go to definition")
  "D" '(lsp-find-references :which-key "find references")
  "R" '(lsp-rename :which-key "rename")
  "a" '(lsp-execute-code-action :which-key "code action")
  "v" '(pyvenv-activate :which-key "activate venv")
  "V" '(pyvenv-deactivate :which-key "deactivate venv")
  "T" '(pytest-pytest :which-key "run all tests")
  "t" '(pytest-pytest-one :which-key "run test at point"))
