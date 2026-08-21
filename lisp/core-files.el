;;; core-files.el --- File management -*- lexical-binding: t; -*-

(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches "-alh")
  (setq dired-dwim-target t)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'top)
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq delete-by-moving-to-trash t)
  (let ((gls (executable-find "gls")))
    (when gls
      (setq insert-directory-program gls)
      (setq dired-listing-switches "-alh --group-directories-first"))))

(use-package dirvish
  :ensure t
  :commands (dirvish dirvish-side)
  :hook (dired-mode . dirvish-override-dired-mode)
  :custom
  (dirvish-mode-line-format nil)
  (dirvish-mode-line-height 21)
  (dirvish-attributes
   '(subtree-state
     nerd-icons
     collapse
     git-msg
     file-time
     file-size))
  (dirvish-subtree-state-style 'nerd)
  (dirvish-default-layout '(1 0.11 0.55))
  (dirvish-hide-details t))

;; dirvish-side removed in favour of speedbar-window (Emacs 31).
;; Speedbar is configured in core-windows.el and toggled via SPC f t.

(use-package autorevert
  :ensure nil
  :custom
  (auto-revert-verbose nil)
  :hook (emacs-startup . global-auto-revert-mode))

(provide 'core-files)
;;; core-files.el ends here
