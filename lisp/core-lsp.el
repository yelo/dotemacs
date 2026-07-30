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
  (lsp-diagnostics-provider :flycheck)
  ;; Show lenses above the function definition line (Rider-style).
  (lsp-lens-place-position 'above-line))
