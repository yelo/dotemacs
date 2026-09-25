;;; core-tabs.el --- Tab-bar project workspaces -*- lexical-binding: t; -*-

;; Built-in `tab-bar-mode` used as a lightweight project-per-tab workspace
;; switcher: each tab is a separate window layout, and switching projects
;; into a fresh tab keeps unrelated buffers/windows from piling up in one
;; workspace.

(require 'project)

(tab-bar-mode 1)

;; Hide the tab bar entirely until there is more than one tab, and keep it
;; free of mouse-oriented clutter — this is a keyboard-driven config.
(setq tab-bar-show 1
      tab-bar-close-button-show nil
      tab-bar-format '(tab-bar-format-history tab-bar-format-tabs tab-bar-separator))

;; New tabs (e.g. from `tab-bar-new-tab') start in a neutral scratch buffer.
(setq tab-bar-new-tab-choice
      (lambda () (get-buffer-create "*scratch*")))

(defconst rk/loose-files-tab-name "Loose Files"
  "Name of the tab used for files outside a project.")

(defvar rk/tab-workspace-roots nil
  "Alist mapping tab names to their project roots.
A nil root marks the dedicated non-project workspace.")

(defvar rk/tab-routing-in-progress nil
  "Non-nil while file routing is selecting a tab or opening a file.")

(defun rk/tab-current-name ()
  "Return the name of the currently selected tab."
  (cdr (assq 'name (tab-bar--current-tab))))

(defun rk/tab-workspace-root (&optional tab-name)
  "Return the project root recorded for TAB-NAME.
When TAB-NAME is nil, use the current tab."
  (cdr (assoc (or tab-name (rk/tab-current-name)) rk/tab-workspace-roots)))

(defun rk/tab-set-workspace-root (root &optional tab-name)
  "Associate ROOT with TAB-NAME, or the current tab when omitted."
  (let ((name (or tab-name (rk/tab-current-name))))
    (setf (alist-get name rk/tab-workspace-roots nil nil #'equal)
          (and root (file-name-as-directory (expand-file-name root))))))

(defun rk/tab-select-by-name (name)
  "Select the tab named NAME, returning non-nil when it exists."
  (let ((index 0)
        found)
    (dolist (tab (tab-bar-tabs))
      (when (and (null found)
                 (equal name (cdr (assq 'name tab))))
        (setq found index))
      (setq index (1+ index)))
    (when found
      (tab-bar-select-tab (1+ found))
      t)))

(defun rk/tab-project-root-for-file (file)
  "Return the project root containing FILE, or nil."
  (unless (file-remote-p file)
    (when-let* ((directory (file-name-directory (expand-file-name file)))
                (project (project-current nil directory)))
      (file-name-as-directory (expand-file-name (project-root project))))))

(defun rk/tab-file-in-root-p (file root)
  "Return non-nil when FILE is inside ROOT."
  (and root
       (file-in-directory-p (expand-file-name file)
                            (file-name-as-directory (expand-file-name root)))))

(defun rk/tab-find-project-tab (root)
  "Return the tab name associated with project ROOT, if any."
  (car (seq-find
        (lambda (entry)
          (equal (cdr entry) root))
        rk/tab-workspace-roots)))

(defun rk/tab-open-loose-files ()
  "Select or create the dedicated tab for non-project files."
  (interactive)
  (or (rk/tab-select-by-name rk/loose-files-tab-name)
      (progn
        (tab-bar-new-tab)
        (tab-bar-rename-tab rk/loose-files-tab-name)
        (rk/tab-set-workspace-root nil)
        t)))

(defun rk/tab-open-project-root (root)
  "Select or create a tab associated with project ROOT."
  (let ((root (file-name-as-directory (expand-file-name root))))
    (or (when-let* ((name (rk/tab-find-project-tab root)))
          (rk/tab-select-by-name name))
        (progn
          (tab-bar-new-tab)
          (tab-bar-rename-tab
           (file-name-nondirectory (directory-file-name root)))
          (rk/tab-set-workspace-root root)
          t))))

(defun rk/tab-infer-current-workspace ()
  "Record the current tab's project from its current buffer when possible."
  (unless (assoc (rk/tab-current-name) rk/tab-workspace-roots)
    (when-let* ((file (buffer-file-name))
                (root (rk/tab-project-root-for-file file)))
      (rk/tab-set-workspace-root root))))

(defun rk/tab-route-file (file)
  "Select the appropriate tab for FILE.
Project files stay in their project tab; all other files use Loose Files."
  (let* ((root (rk/tab-project-root-for-file file))
         (current-root (progn
                         (rk/tab-infer-current-workspace)
                         (rk/tab-workspace-root))))
    (cond
     ((null root)
      (unless (equal (rk/tab-current-name) rk/loose-files-tab-name)
        (rk/tab-open-loose-files)))
     ((null current-root)
      (rk/tab-open-project-root root))
     ((rk/tab-file-in-root-p file current-root)
      nil)
     (t
      (rk/tab-open-loose-files)))))

(defun rk/find-file-routed (file)
  "Open FILE in the workspace selected by `rk/tab-route-file'."
  (let ((rk/tab-routing-in-progress t))
    (rk/tab-route-file file)
    (find-file-noselect file)))

(defun rk/find-file-route-advice (original file &optional wildcards)
  "Route file visits through the appropriate tab before calling ORIGINAL."
  (if (or rk/tab-routing-in-progress (file-remote-p file))
      (funcall original file wildcards)
    (switch-to-buffer (rk/find-file-routed file))))

(defun rk/project-open-in-new-tab ()
  "Open a project in a new tab, named after the project."
  (interactive)
  (tab-bar-new-tab)
  (condition-case nil
      (progn
        (call-interactively #'project-switch-project)
        (when-let* ((project (project-current))
                    (root (project-root project)))
          (rk/tab-set-workspace-root root)))
    (quit
     ;; Abandon the empty tab if the user cancels project selection.
     (tab-bar-close-tab))))

(defun rk/tab-bar-rename-to-project (&rest _)
  "Rename the current tab to the name of the project just switched to."
  (when-let* ((proj (project-current)))
    (let ((root (project-root proj)))
      (setq rk/tab-workspace-roots
            (assoc-delete-all (rk/tab-current-name) rk/tab-workspace-roots))
      (tab-bar-rename-tab (file-name-nondirectory
                           (directory-file-name root)))
      (rk/tab-set-workspace-root root))))

(advice-add 'project-switch-project :after #'rk/tab-bar-rename-to-project)
(advice-add 'find-file :around #'rk/find-file-route-advice)

(define-key rk/project-map (kbd "t") #'rk/project-open-in-new-tab)
(define-key rk/project-map (kbd "l") #'rk/tab-open-loose-files)

(provide 'core-tabs)
;;; core-tabs.el ends here
