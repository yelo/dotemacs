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
  :config
  (dirvish-override-dired-mode)
  (setq dirvish-mode-line-format nil)
  (setq dirvish-mode-line-height 21)
  (setq dirvish-attributes
        '(subtree-state
          nerd-icons
          collapse
          git-msg
          file-time
          file-size))
  (setq dirvish-subtree-state-style 'nerd)
  (setq dirvish-default-layout '(1 0.11 0.55))
  (setq dirvish-hide-details t))

(use-package dirvish-side
  :ensure nil
  :after dirvish
  :config
  (setq dirvish-side-width 35)
  (setq dirvish-side-auto-expand t)
  (setq dirvish-side-display-alist '((side . left) (slot . -1)))
  (defun rk/dirvish-side--setup-keys ()
    "Set up keybindings for dirvish side sessions."
    (local-set-key (kbd "RET") 'dired-find-file-other-window)
    (local-set-key (kbd "<mouse-1>") 'dired-mouse-find-file-other-window)
    (local-set-key (kbd "<mouse-2>") 'dired-mouse-find-file-other-window))
  (add-hook 'dired-mode-hook
            (lambda ()
              (when (and (dirvish-curr)
                         (eq 'side (dv-type (dirvish-curr))))
                (rk/dirvish-side--setup-keys)))))

(use-package dirvish-fd
  :ensure nil
  :after dirvish
  :config
  (setq dirvish-fd-switches "--hidden"))
