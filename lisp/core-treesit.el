;;; core-treesit.el --- Tree-sitter integration -*- lexical-binding: t; -*-

;; treesit-auto: automatically install grammars and remap major modes to their
;; tree-sitter equivalents when the grammar is available.
(use-package treesit-auto
  :ensure t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode 1))

;; Maximize syntax highlighting detail (levels 1-4, default is 3).
(setq treesit-font-lock-level 4)
