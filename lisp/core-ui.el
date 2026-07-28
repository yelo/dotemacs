(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package moody
  :ensure t
  :config
  (moody-replace-mode-line-front-space)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

(use-package minions
  :ensure t
  :init (minions-mode)
  :config
  (setq minions-mode-lighter "#"))

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-gruvbox-dark t))
