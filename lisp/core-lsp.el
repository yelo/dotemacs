;;; core-lsp.el --- LSP configuration -*- lexical-binding: t; -*-

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook
  ;; Enable Code Lens (usage counts, implementations) above functions.
  (lsp-mode . lsp-lens-mode)
  :custom
  (lsp-auto-guess-root t)
  (lsp-restart 'auto-restart)
  (lsp-diagnostics-provider :flymake)
  ;; Show lenses above the function definition line (Rider-style).
  (lsp-lens-place-position 'above-line))

;; Emacs 31 eglot improvements.
(with-eval-after-load 'eglot
  ;; Use markdown-ts-mode to render hover documentation.
  (setq eglot-doc-markdown-mode 'markdown-ts-view-mode)
  ;; Inline code-action hints can be noisy with some language servers.
  (setq eglot-code-action-indications nil)
  ;; eglot-events-buffer-config replaces the deprecated eglot-events-buffer-size.
  (setq eglot-events-buffer-config '(:size 2000000 :format full)))

(provide 'core-lsp)
;;; core-lsp.el ends here
