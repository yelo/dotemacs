;;; core-files.el --- File management -*- lexical-binding: t; -*-

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

;; dirvish-side removed in favour of speedbar-window (Emacs 31).
;; Speedbar is configured in core-windows.el and toggled via SPC f t.

(use-package dired-preview
  :ensure t
  :hook (dired-mode . dired-preview-mode))

(provide 'core-files)
;;; core-files.el ends here
