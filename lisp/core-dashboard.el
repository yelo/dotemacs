;;; core-dashboard.el --- Built-in startup experience -*- lexical-binding: t; -*-

(require 'button)

(setq inhibit-startup-screen t
      initial-scratch-message "")

(defun rk/startup-status-line ()
  "Return combined startup status line."
  (format "Emacs 31 • Started in %s • %d garbage collections"
          (emacs-init-time "%0.2f seconds")
          gcs-done))

(defun rk/startup-open-recent-files ()
  "Open the recent files menu."
  (interactive)
  (require 'recentf)
  (recentf-open-files))

(defun rk/open-init-file ()
  "Open init.el quickly."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(defun rk/startup--insert-action (key label fn)
  "Insert one startup action row using KEY, LABEL and FN."
  (insert (format " [%s] " key))
  (insert-text-button label
                      'action (lambda (_btn) (call-interactively fn))
                      'follow-link t)
  (insert "\n"))

(defun rk/startup-buffer-mode ()
  "Major mode for the minimal startup launcher."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'rk/startup-buffer-mode
        mode-name "RK-Start")
  (use-local-map (copy-keymap special-mode-map))
  (setq buffer-read-only t
        truncate-lines t)
  (local-set-key (kbd "f") #'find-file)
  (local-set-key (kbd "r") #'rk/startup-open-recent-files)
  (local-set-key (kbd "p") #'project-switch-project)
  (local-set-key (kbd "i") #'rk/open-init-file)
  (run-mode-hooks 'special-mode-hook))

(defun rk/startup-buffer-refresh ()
  "Render startup buffer content."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert (rk/startup-status-line))
    (insert "\n\n")
    (insert "Actions\n")
    (rk/startup--insert-action "f" "Find file" #'find-file)
    (rk/startup--insert-action "r" "Recent files" #'rk/startup-open-recent-files)
    (rk/startup--insert-action "p" "Switch project" #'project-switch-project)
    (rk/startup--insert-action "i" "Open init.el" #'rk/open-init-file)
    (goto-char (point-min))))

(defun rk/startup-buffer ()
  "Open the minimal startup launcher buffer."
  (interactive)
  (let ((buf (get-buffer-create "*rk-startup*")))
    (with-current-buffer buf
      (rk/startup-buffer-mode)
      (rk/startup-buffer-refresh))
    (pop-to-buffer buf)))

(defun rk/startup-initial-buffer ()
  "Return startup buffer for `initial-buffer-choice`."
  (let ((buf (get-buffer-create "*rk-startup*")))
    (with-current-buffer buf
      (rk/startup-buffer-mode)
      (rk/startup-buffer-refresh))
    buf))

(setq initial-buffer-choice #'rk/startup-initial-buffer)

(provide 'core-dashboard)
;;; core-dashboard.el ends here
