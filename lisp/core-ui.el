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
  (load-theme 'solarized-gruvbox-colors t))

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
  (defun rk/dirvish-side-find-entry ()
    "Open file in other window, navigate directory in same window."
    (interactive)
    (let ((file (dired-get-file-for-visit)))
      (if (file-directory-p file)
          (dired-find-file)
        (dired-find-file-other-window))))
  (defun rk/dirvish-side-mouse-find-entry (event)
    "Open file in other window, navigate directory in same window."
    (interactive "e")
    (let (window pos file)
      (save-excursion
        (setq window (posn-window (event-end event))
              pos (posn-point (event-end event)))
        (unless (windowp window) (error "No file chosen"))
        (set-buffer (window-buffer window))
        (goto-char pos)
        (setq file (dired-get-file-for-visit)))
      (select-window window)
      (if (file-directory-p file)
          (dired-find-file)
        (dired-find-file-other-window))))
  (defun rk/dirvish-side--setup-keys ()
    "Set up keybindings for dirvish side sessions."
    (local-set-key (kbd "RET") 'rk/dirvish-side-find-entry)
    (local-set-key (kbd "<mouse-1>") 'rk/dirvish-side-mouse-find-entry)
    (local-set-key (kbd "<mouse-2>") 'rk/dirvish-side-mouse-find-entry))
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
