;;; core-dashboard.el --- Built-in startup experience -*- lexical-binding: t; -*-

(require 'button)

(setq inhibit-startup-screen t
      initial-scratch-message "")

(defconst rk/startup-quotes
  '("Keep it simple. Keep it built-in."
    "Small keymaps, big focus."
    "Refactor fearlessly; validate relentlessly."
    "Treat warnings as invitations to improve."
    "Today’s shortcut is tomorrow’s muscle memory."
    "Edit with intent, ship with confidence.")
  "Short rotating startup tips/quotes.")

(defun rk/startup-quote-of-day ()
  "Return a deterministic quote for the current day."
  (let* ((day (1- (string-to-number (format-time-string "%j"))))
         (year (string-to-number (format-time-string "%Y")))
         (idx (mod (+ day year) (length rk/startup-quotes))))
    (nth idx rk/startup-quotes)))

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
  (local-set-key (kbd "q") #'quit-window)
  (local-set-key (kbd "t") #'tetris)
  (local-set-key (kbd "z") #'zone)
  (local-set-key (kbd "s") #'snake)
  (run-mode-hooks 'special-mode-hook))

(defun rk/startup-buffer-refresh ()
  "Render startup buffer content."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert "Vanilla Emacs 31\n")
    (insert "Built-in only • minimal interactive launcher\n\n")
    (insert (format "Tip of the day: %s\n\n" (rk/startup-quote-of-day)))
    (insert "Actions\n")
    (rk/startup--insert-action "f" "Find file" #'find-file)
    (rk/startup--insert-action "r" "Recent files" #'rk/startup-open-recent-files)
    (rk/startup--insert-action "p" "Switch project" #'project-switch-project)
    (rk/startup--insert-action "i" "Open init.el" #'rk/open-init-file)
    (insert "\nFun (built-ins)\n")
    (rk/startup--insert-action "t" "Tetris" #'tetris)
    (rk/startup--insert-action "s" "Snake" #'snake)
    (rk/startup--insert-action "z" "Zone out" #'zone)
    (insert "\nPress q to close this window.\n")
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
