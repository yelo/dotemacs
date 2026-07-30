;;; lang-python.el --- Python bindings -*- lexical-binding: t; -*-

;; Only use pylsp from the project's .venv.
;; ruff handles formatting (ruff-format) and diagnostics (flycheck python-ruff)
;; already; no need for the ruff LSP server on top of that.
;; Install per project: pip install "python-lsp-server[all]"
;; (or: uv add --dev python-lsp-server)
(defun rk/python-lsp-setup ()
  (setq-local lsp-enabled-clients '(pylsp)))

(add-hook 'python-mode-hook    #'rk/python-lsp-setup)
(add-hook 'python-ts-mode-hook #'rk/python-lsp-setup)

;; Append so lsp starts after pyvenv has activated the .venv and updated exec-path.
(add-hook 'python-mode-hook    #'lsp-deferred t)
(add-hook 'python-ts-mode-hook #'lsp-deferred t)

;; ── ruff-format: format on save ──
(use-package ruff-format
  :ensure t
  :hook ((python-mode python-ts-mode) . ruff-format-on-save-mode))

;; ── pyvenv: virtual environment management ──
(use-package pyvenv
  :ensure t
  :hook ((python-mode python-ts-mode) . pyvenv-mode)
  :config
  (defun rk/pyvenv-auto-activate ()
    (let ((venv (locate-dominating-file default-directory ".venv")))
      (when venv
        (pyvenv-activate (expand-file-name ".venv" venv)))))
  (add-hook 'python-mode-hook    #'rk/pyvenv-auto-activate)
  (add-hook 'python-ts-mode-hook #'rk/pyvenv-auto-activate))

;; ── pytest: test runner ──
(use-package pytest
  :ensure t)

;; ── keybindings ──
(rk/lang 'python '(python-mode-map python-ts-mode-map)
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
  "T" '(pytest-all :which-key "run all tests")
  "t" '(pytest-one :which-key "run test at point"))
