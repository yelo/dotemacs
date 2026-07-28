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
  (load-theme 'solarized-light t))

(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh")
  (setq dired-dwim-target t)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'top)
  (setq delete-by-moving-to-trash t)
  (let ((gls (executable-find "gls")))
    (when gls
      (setq insert-directory-program gls)
      (setq dired-listing-switches "-alh --group-directories-first"))))

(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-mode-line-height 12)
  (setq dirvish-attributes
        '(nerd-icons
          subtree-state
          git-msg
          file-time
          file-size
          all-the-icons
          collapse))
  (setq dirvish-subtree-state-style 'nerd)
  (setq dirvish-default-layout '(0 0.3 0.7))
  (setq dirvish-side-display-alist
        '((window-width . 0.3)
          (side . right)
          (slot . 1)))
  (setq dirvish-hide-details t))

(use-package dirvish-side
  :ensure nil
  :after dirvish)

(use-package dirvish-fd
  :ensure nil
  :after dirvish
  :config
  (setq dirvish-fd-switches "--hidden"))
