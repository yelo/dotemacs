;;; core-markdown.el --- Markdown support -*- lexical-binding: t; -*-

;; Emacs 31 ships a built-in markdown-ts-mode (experimental).
;; It provides org-like navigation, live syntax-highlighted fenced code
;; blocks, and inline image display.
;;
;; markdown-ts-view-mode is a read-only variant used by eglot for hover docs.
;; Both are loaded here so they are available before eglot needs them.

(require 'markdown-ts-mode nil t)

(when (featurep 'markdown-ts-mode)
  ;; Make markdown-ts-mode the default everywhere markdown-mode would be used.
  (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.mdx\\'" . markdown-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.mkd\\'" . markdown-ts-mode)))

(provide 'core-markdown)
;;; core-markdown.el ends here
