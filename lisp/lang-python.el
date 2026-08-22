;;; lang-python.el --- Python bindings -*- lexical-binding: t; -*-

;; LSP server: pylsp — install per project:
;;   pip install "python-lsp-server[all]"
;;   (or: uv add --dev python-lsp-server)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((python-mode python-ts-mode) . ("pylsp"))))

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
