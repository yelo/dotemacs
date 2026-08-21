;;; core-eglot.el --- Eglot configuration -*- lexical-binding: t; -*-

(use-package eglot
  :ensure nil
  :commands (eglot eglot-ensure eglot-rename eglot-code-actions)
  :hook
  ;; Auto-start eglot for supported language modes.
  ;; Python is handled in lang-python.el (appended after pyvenv activates .venv).
  ;; Rust is handled in lang-rust.el (rustic :hook).
  ((csharp-mode csharp-ts-mode) . eglot-ensure)
  :config
  ;; Use markdown-ts-mode to render hover documentation.
  (setq eglot-doc-markdown-mode 'markdown-ts-view-mode)
  ;; Inline code-action hints can be noisy with some language servers.
  (setq eglot-code-action-indications nil)
  ;; Keep enough protocol logs for troubleshooting.
  (setq eglot-events-buffer-config '(:size 2000000 :format full))

  ;; Language server mappings.
  (add-to-list 'eglot-server-programs '((python-mode python-ts-mode) . ("pylsp")))
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode rustic-mode) . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs '((csharp-mode csharp-ts-mode) . ("csharp-ls"))))

(provide 'core-eglot)
;;; core-eglot.el ends here
