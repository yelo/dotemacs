;;; core-flymake.el --- Flymake syntax-checking -*- lexical-binding: t; -*-

(use-package flymake
  :ensure nil  ; built-in
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-no-changes-timeout 0.5)
  (flymake-start-on-flymake-mode t)
  (flymake-fringe-indicator-position 'left-fringe))

;; ── SPC e — error navigation and flymake commands ──
(with-eval-after-load 'general
  (rk/leader-keys
    "e"  '(:ignore t                              :wk "errors")
    "el" '(flymake-show-buffer-diagnostics        :wk "list errors")
    "en" '(flymake-goto-next-error                :wk "next error")
    "ep" '(flymake-goto-prev-error                :wk "previous error")
    "eb" '(flymake-start                          :wk "check buffer")
    "ev" '(flymake-show-project-diagnostics       :wk "project diagnostics")
    "es" '(flymake-switch-to-log-buffer           :wk "flymake log")))

(provide 'core-flymake)
;;; core-flymake.el ends here
