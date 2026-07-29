;;; core-lsp.el --- LSP configuration -*- lexical-binding: t; -*-

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :custom
  (lsp-auto-guess-root t)
  (lsp-restart 'auto-restart))
