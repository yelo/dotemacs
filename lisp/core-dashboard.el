;;; core-dashboard.el --- Built-in startup experience -*- lexical-binding: t; -*-

;; Keep startup simple in built-in mode.
(setq inhibit-startup-screen t
      initial-scratch-message
      ";; Vanilla Emacs 31 configuration loaded.\n;; Built-in features only.\n\n")

(defun rk/open-init-file ()
  "Open init.el quickly."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(provide 'core-dashboard)
;;; core-dashboard.el ends here
