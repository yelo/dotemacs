(use-package which-key
  :ensure t
  :config
  (which-key-mode 1))

(use-package mood-line
  :ensure t
  :init
  (mood-line-mode 1)
  :custom
  (mood-line-format mood-line-format-default-extended)
  (mood-line-glyph-alist mood-line-glyphs-ascii))

(use-package minions
  :ensure t
  :init (minions-mode)
  :config
  (setq minions-mode-lighter "#"))

(use-package solarized-theme
  :ensure t
  :config
  (load-theme 'solarized-gruvbox-dark t))
