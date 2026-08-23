;;; core-shell.el --- Shell and terminal configuration -*- lexical-binding: t; -*-

;; eshell — Emacs's built-in shell.
(setq eshell-prefer-lisp-functions nil
      eshell-destroy-buffer-when-process-dies t
      eshell-history-size 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input 'all
      eshell-scroll-to-bottom-on-output 'all)

;; Hand full-screen/interactive programs off to term instead of garbling
;; their output in the eshell buffer.
(with-eval-after-load 'em-term
  (dolist (cmd '("htop" "top" "less" "ssh" "tmux"))
    (add-to-list 'eshell-visual-commands cmd)))

;; Built-in terminal modes do not benefit from line numbers.
(add-hook 'shell-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'term-mode-hook (lambda () (display-line-numbers-mode -1)))

(provide 'core-shell)
;;; core-shell.el ends here
