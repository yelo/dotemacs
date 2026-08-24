;;; core-ui.el --- UI defaults -*- lexical-binding: t; -*-

;; ---- Fonts ----
;; Only "Iosevka Nerd Font" is installed; plain Iosevka is not available.
(when (display-graphic-p)
  (defun rk/apply-font-settings (faces)
    "Apply font settings to a list of FACES."
    (dolist (face faces)
      (set-face-attribute face nil
                          :family "Iosevka Nerd Font"
                          :height 135
                          :weight 'regular)))

  (rk/apply-font-settings '(default fixed-pitch)))

(defun rk/apply-ui-face-tweaks ()
  "Apply small readability tweaks after theme load."
  (require 'hl-line)
  (when (facep 'hl-line)
    (set-face-attribute 'hl-line nil
                        :inherit nil
                        :foreground 'unspecified
                        :background (face-attribute 'default :background)
                        :underline nil
                        :overline nil
                        :box nil
                        :extend t
                        :distant-foreground (face-attribute 'default :foreground))))

;; ---- Theme toggle ----
(defun rk/toggle-light-dark-theme ()
  "Toggle between modus-operandi-tinted (light) and modus-vivendi-tinted (dark)."
  (interactive)
  (let ((current (car custom-enabled-themes)))
    (cond
     ((eq current 'modus-operandi-tinted)
      (disable-theme 'modus-operandi-tinted)
      (load-theme 'modus-vivendi-tinted t)
      (rk/apply-ui-face-tweaks)
      (message "Switched to dark mode"))
     ((eq current 'modus-vivendi-tinted)
      (disable-theme 'modus-vivendi-tinted)
      (load-theme 'modus-operandi-tinted t)
      (rk/apply-ui-face-tweaks)
      (message "Switched to light mode"))
     (t
      (load-theme 'modus-operandi-tinted t)
      (rk/apply-ui-face-tweaks)
      (message "Loaded light mode")))))

;; Built-in theme only.
(add-hook 'emacs-startup-hook
          (lambda ()
            (load-theme 'modus-operandi-tinted t)
            (rk/apply-ui-face-tweaks)))

(provide 'core-ui)
;;; core-ui.el ends here
