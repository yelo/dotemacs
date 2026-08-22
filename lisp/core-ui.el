;;; core-ui.el --- UI defaults -*- lexical-binding: t; -*-

;; ---- Fonts ----
;; Only "Iosevka Nerd Font" is installed; plain Iosevka is not available.
(when (display-graphic-p)
  (set-face-attribute 'default nil
                      :family "Iosevka Nerd Font"
                      :height 135
                      :weight 'regular)
  (set-face-attribute 'fixed-pitch nil
                      :family "Iosevka Nerd Font"
                      :height 135
                      :weight 'regular))

;; Emacs 31: collapse minor mode lighters into a single button.
(setq mode-line-collapse-minor-modes t)

;; Built-in theme only.
(add-hook 'emacs-startup-hook
          (lambda ()
            (load-theme 'wombat t)))

(provide 'core-ui)
;;; core-ui.el ends here
