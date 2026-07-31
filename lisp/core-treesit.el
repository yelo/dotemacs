;;; core-treesit.el --- Tree-sitter integration -*- lexical-binding: t; -*-

;; Emacs 31: automatically switch to tree-sitter major modes when grammars are
;; available, and offer to install missing grammars on demand.
(setq treesit-enabled-modes t)
(setq treesit-auto-install-grammar 'ask)

;; Maximize syntax highlighting detail (levels 1-4, default is 3).
(setq treesit-font-lock-level 4)

(provide 'core-treesit)
;;; core-treesit.el ends here
