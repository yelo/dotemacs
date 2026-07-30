;;; core-flycheck.el --- Flycheck syntax-checking -*- lexical-binding: t; -*-

(use-package flycheck
  :ensure t
  :hook (after-init . global-flycheck-mode)
  :custom
  (flycheck-display-errors-delay 0.3)
  (flycheck-idle-change-delay 0.5))

;; ── SPC e — error navigation and flycheck commands ──
(with-eval-after-load 'general
  (rk/leader-keys
    "e"  '(:ignore t                          :wk "errors")
    "el" '(flycheck-list-errors               :wk "list errors")
    "en" '(flycheck-next-error                :wk "next error")
    "ep" '(flycheck-previous-error            :wk "previous error")
    "ee" '(flycheck-explain-error-at-point    :wk "explain error")
    "eb" '(flycheck-buffer                    :wk "check buffer")
    "ev" '(flycheck-verify-setup              :wk "verify setup")
    "es" '(flycheck-select-checker            :wk "select checker")
    "ed" '(flycheck-disable-checker           :wk "disable checker")
    "ec" '(flycheck-clear                     :wk "clear errors")))

(provide 'core-flycheck)
;;; core-flycheck.el ends here
