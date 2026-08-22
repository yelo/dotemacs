;;; core-tabs.el --- Tab-bar project workspaces -*- lexical-binding: t; -*-

;; Built-in `tab-bar-mode` used as a lightweight project-per-tab workspace
;; switcher: each tab is a separate window layout, and switching projects
;; into a fresh tab keeps unrelated buffers/windows from piling up in one
;; workspace.

(tab-bar-mode 1)

;; Hide the tab bar entirely until there is more than one tab, and keep it
;; free of mouse-oriented clutter — this is a keyboard-driven config.
(setq tab-bar-show 1
      tab-bar-close-button-show nil
      tab-bar-format '(tab-bar-format-history tab-bar-format-tabs tab-bar-separator))

;; New tabs (e.g. from `tab-bar-new-tab') start at the dashboard rather than
;; cloning the current window layout.
(setq tab-bar-new-tab-choice
      (lambda () (get-buffer-create "*rk-startup*")))

(defun rk/project-open-in-new-tab ()
  "Open a project in a new tab, named after the project."
  (interactive)
  (tab-bar-new-tab)
  (condition-case nil
      (call-interactively #'project-switch-project)
    (quit
     ;; Abandon the empty tab if the user cancels project selection.
     (tab-bar-close-tab))))

(defun rk/tab-bar-rename-to-project (&rest _)
  "Rename the current tab to the name of the project just switched to."
  (when-let* ((proj (project-current)))
    (tab-bar-rename-tab (file-name-nondirectory
                         (directory-file-name (project-root proj))))))

(advice-add 'project-switch-project :after #'rk/tab-bar-rename-to-project)

(define-key rk/project-map (kbd "t") #'rk/project-open-in-new-tab)

(provide 'core-tabs)
;;; core-tabs.el ends here
