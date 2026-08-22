;;; core-shell.el --- Shell and terminal configuration -*- lexical-binding: t; -*-

(let ((fish "/opt/homebrew/bin/fish"))
  (when (file-executable-p fish)
    (setq explicit-shell-file-name fish)))

;; eshell — Emacs's built-in shell.
(setq eshell-prefer-lisp-functions nil
      eshell-destroy-buffer-when-process-dies t
      eshell-history-size 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input 'all
      eshell-scroll-to-bottom-on-output 'all)

;; Built-in terminal modes do not benefit from line numbers.
(add-hook 'shell-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'term-mode-hook (lambda () (display-line-numbers-mode -1)))

;; Emacs 31: persist IELM input history across sessions.
(setq ielm-history-file-name
      (expand-file-name "ielm-history" user-emacs-directory))

(provide 'core-shell)
;;; core-shell.el ends here
