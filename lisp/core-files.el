;;; core-files.el --- File management -*- lexical-binding: t; -*-

(with-eval-after-load 'dired
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

;; Keep file management simple: built-in dired + speedbar side window.

(setq auto-revert-verbose nil)
(add-hook 'emacs-startup-hook #'global-auto-revert-mode)

(provide 'core-files)
;;; core-files.el ends here
