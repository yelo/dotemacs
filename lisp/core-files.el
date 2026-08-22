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
      (setq dired-listing-switches "-alh --group-directories-first")))
  ;; dired-x: adds C-x C-j (dired-jump) and dired-omit-mode to hide clutter.
  (require 'dired-x)
  (setq dired-omit-files (concat dired-omit-files "\\|^\\.\\.?$"))
  (add-hook 'dired-mode-hook #'dired-omit-mode))

;; Keep file management simple: built-in dired + speedbar side window.

(setq auto-revert-verbose nil)
(add-hook 'emacs-startup-hook #'global-auto-revert-mode)

;; Remember point position per file across sessions (Emacs built-in).
(save-place-mode 1)

;; Give same-named buffers from different directories/projects clearer names
;; than the default file<2> suffix style.
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

(provide 'core-files)
;;; core-files.el ends here
