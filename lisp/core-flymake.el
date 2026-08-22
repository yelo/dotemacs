;;; core-flymake.el --- Flymake syntax-checking -*- lexical-binding: t; -*-

(add-hook 'prog-mode-hook #'flymake-mode)
(setq flymake-no-changes-timeout 0.5
      flymake-start-on-flymake-mode t
      flymake-fringe-indicator-position 'left-fringe)

;; Minimal global shortcuts.
(keymap-global-set "C-c ! l" #'flymake-show-buffer-diagnostics)
(keymap-global-set "C-c ! n" #'flymake-goto-next-error)
(keymap-global-set "C-c ! p" #'flymake-goto-prev-error)
(keymap-global-set "C-c ! s" #'flymake-start)

(provide 'core-flymake)
;;; core-flymake.el ends here
