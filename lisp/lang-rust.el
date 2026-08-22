;;; lang-rust.el --- Rust bindings -*- lexical-binding: t; -*-

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode) . ("rust-analyzer"))))

(add-hook 'rust-mode-hook #'eglot-ensure)
(add-hook 'rust-ts-mode-hook #'eglot-ensure)

(defun rk/rust-cargo (subcommand)
  "Run cargo SUBCOMMAND in the current project."
  (interactive "sCargo subcommand: ")
  (let ((default-directory
         (if-let* ((proj (project-current nil default-directory)))
             (project-root proj)
           default-directory)))
    (compile (format "cargo %s" subcommand))))

(provide 'lang-rust)
;;; lang-rust.el ends here
