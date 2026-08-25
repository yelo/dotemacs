;;; lang-python.el --- Python bindings -*- lexical-binding: t; -*-

(require 'cl-lib)

;; LSP server: pylsp — install per project:
;;   pip install "python-lsp-server[all]"
;;   (or: uv add --dev python-lsp-server)

;; ── Virtualenv auto-detection (built-in only; no pyvenv/pet, etc.) ──
(defconst rk/python-venv-names '(".venv" "venv" "env")
  "Directory names checked, in order, for a project-root virtualenv.")

(defun rk/python-venv-root ()
  "Return the virtualenv directory under the current project root, or nil.
Checks `rk/python-venv-names' in order and returns the first
existing directory match."
  (when-let* ((proj (project-current nil default-directory))
              (root (project-root proj)))
    (cl-loop for name in rk/python-venv-names
             for dir = (expand-file-name name root)
             when (file-directory-p dir)
             return (file-name-as-directory dir))))

(defun rk/python-venv-bin-dir (venv-root)
  "Return the bin/Scripts directory for VENV-ROOT."
  (file-name-as-directory
   (expand-file-name (if (eq system-type 'windows-nt) "Scripts" "bin")
                      venv-root)))

(defun rk/python-setup-venv ()
  "Configure buffer-local venv paths when a project virtualenv is found."
  (when-let* ((venv (rk/python-venv-root))
              (bin (rk/python-venv-bin-dir venv)))
    (setq-local python-shell-virtualenv-root venv)
    (setq-local exec-path (cons (directory-file-name bin) exec-path))
    (setq-local process-environment
                (cons (concat "PATH=" (directory-file-name bin)
                              path-separator (getenv "PATH"))
                      process-environment))))

(defun rk/python-eglot-server-program (_interactive)
  "Return the eglot contact for pylsp, preferring a project venv's copy."
  (let* ((venv (rk/python-venv-root))
         (venv-pylsp (and venv
                           (expand-file-name
                            (if (eq system-type 'windows-nt) "pylsp.exe" "pylsp")
                            (rk/python-venv-bin-dir venv)))))
    (list (if (and venv-pylsp (file-executable-p venv-pylsp))
              venv-pylsp
            "pylsp"))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . rk/python-eglot-server-program)))

(add-hook 'python-mode-hook    #'rk/python-setup-venv)
(add-hook 'python-ts-mode-hook #'rk/python-setup-venv)

;; Appended (:append t) so project-local settings are applied first.
(add-hook 'python-mode-hook    #'eglot-ensure t)
(add-hook 'python-ts-mode-hook #'eglot-ensure t)

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

(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-c t a") #'rk/pytest-all)
  (define-key python-mode-map (kbd "C-c t t") #'rk/pytest-one)
  (when (boundp 'python-ts-mode-map)
    (define-key python-ts-mode-map (kbd "C-c t a") #'rk/pytest-all)
    (define-key python-ts-mode-map (kbd "C-c t t") #'rk/pytest-one)))

(provide 'lang-python)
;;; lang-python.el ends here
