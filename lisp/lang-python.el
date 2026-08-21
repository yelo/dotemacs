;;; lang-python.el --- Python bindings -*- lexical-binding: t; -*-

;; Eglot uses pylsp from the active environment (managed via pyvenv below).
;; ruff handles formatting (ruff-format) and diagnostics via flymake.
;; Install per project: pip install "python-lsp-server[all]"
;; (or: uv add --dev python-lsp-server)
;; Appended (:append t) so eglot-ensure runs after pyvenv activates the .venv
;; and updates exec-path, ensuring pylsp is found in the project virtualenv.
(add-hook 'python-mode-hook    #'eglot-ensure t)
(add-hook 'python-ts-mode-hook #'eglot-ensure t)

;; ── ruff-format: format on save ──
(use-package ruff-format
  :ensure t
  :hook ((python-mode python-ts-mode) . ruff-format-on-save-mode))

;; ── pyvenv: virtual environment management ──
(use-package pyvenv
  :ensure t
  :hook ((python-mode python-ts-mode) . pyvenv-mode)
  :init
  (defun rk/pyvenv-auto-activate ()
    (let ((venv (locate-dominating-file default-directory ".venv")))
      (when venv
        (pyvenv-activate (expand-file-name ".venv" venv)))))
  (add-hook 'python-mode-hook    #'rk/pyvenv-auto-activate)
  (add-hook 'python-ts-mode-hook #'rk/pyvenv-auto-activate))

;; ── pytest commands (project.el-based; no projectile dependency) ──
(defun rk/python-project-root ()
  "Return current project root or `default-directory`."
  (if-let* ((proj (project-current nil default-directory)))
      (project-root proj)
    default-directory))

(defun rk/python-pytest--run (&optional target)
  "Run pytest in the current project, optionally scoped to TARGET."
  (let ((default-directory (rk/python-project-root)))
    (compile
     (if (and target (> (length target) 0))
         (format "python -m pytest %s" (shell-quote-argument target))
       "python -m pytest"))))

(defun rk/pytest-all ()
  "Run all Python tests in the current project."
  (interactive)
  (rk/python-pytest--run))

(defun rk/pytest-one ()
  "Run pytest for the current file/function when available."
  (interactive)
  (if-let* ((file (buffer-file-name))
            (root (rk/python-project-root))
            (rel (file-relative-name file root)))
      (let ((test (python-info-current-defun)))
        (rk/python-pytest--run
         (if (and test (> (length test) 0))
             (format "%s::%s" rel test)
           rel)))
    (user-error "Current buffer is not visiting a file")))

;; ── keybindings ──
(rk/lang 'python '(python-mode-map python-ts-mode-map)
  "e" '(python-shell-send-statement :which-key "send statement")
  "r" '(python-shell-send-region :which-key "send region")
  "b" '(python-shell-send-buffer :which-key "send buffer")
  "f" '(python-shell-send-file :which-key "send file")
  "'" '(run-python :which-key "REPL")
  "d" '(xref-find-definitions :which-key "go to definition")
  "D" '(xref-find-references :which-key "find references")
  "R" '(eglot-rename :which-key "rename")
  "a" '(eglot-code-actions :which-key "code action")
  "v" '(pyvenv-activate :which-key "activate venv")
  "V" '(pyvenv-deactivate :which-key "deactivate venv")
  "T" '(rk/pytest-all :which-key "run all tests")
  "t" '(rk/pytest-one :which-key "run test at point"))
