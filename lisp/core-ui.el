;;; core-ui.el --- UI packages -*- lexical-binding: t; -*-

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

(use-package which-key
  :ensure nil  ; built-in since Emacs 30
  :config
  (which-key-mode 1))

(use-package mood-line
  :ensure t
  :init
  (mood-line-mode 1)
  :custom
  (mood-line-format mood-line-format-default-extended)
  (mood-line-glyph-alist mood-line-glyphs-ascii))

;; Emacs 31: collapse minor mode lighters into a single button, replacing minions.
(setq mode-line-collapse-minor-modes t)

(use-package solarized-theme
  :ensure t
  :init
  (add-hook 'emacs-startup-hook
            (lambda ()
              (load-theme 'solarized-gruvbox-dark t))))

(provide 'core-ui)
;;; core-ui.el ends here
