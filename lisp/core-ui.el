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

(defun rk/apply-ui-face-tweaks ()
  "Apply small readability tweaks after theme load."
  (require 'hl-line)
  (when (facep 'hl-line)
    (set-face-attribute 'hl-line nil
                        :inherit nil
                        :foreground 'unspecified
                        :background "#3a3a3a"
                        :underline nil
                        :overline nil
                        :box nil
                        :extend t)))

;; Built-in theme only.
(add-hook 'emacs-startup-hook
          (lambda ()
            (load-theme 'wombat t)
            (rk/apply-ui-face-tweaks)))

(provide 'core-ui)
;;; core-ui.el ends here
