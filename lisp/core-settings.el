;;; core-settings.el --- Sensible defaults -*- lexical-binding: t; -*-

;;; Useful defaults
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(setq-default frame-title-format '("%b"))
(setq ring-bell-function 'ignore)
(setq-default cursor-type 'bar)
(setq use-short-answers t)           ; answer prompts with y/n instead of yes/no
(delete-selection-mode 1)         ; typing replaces selected region
(setq auto-revert-use-notify t)   ; use OS filesystem notifications instead of polling
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; Centralized writable-state paths (persistent or ephemeral)
(defconst rk/emacs-ephemeral-cache-dir
  (expand-file-name (format "emacs%d-cache/" (user-uid)) temporary-file-directory)
  "Ephemeral cache directory for this user.")

(defcustom rk/cache-directory
  (expand-file-name "cache/" user-emacs-directory)
  "Root directory for Emacs writable state files."
  :type `(choice
          (const :tag "Persistent cache under user-emacs-directory"
                 ,(expand-file-name "cache/" user-emacs-directory))
          (const :tag "Ephemeral cache under temporary-file-directory"
                 ,rk/emacs-ephemeral-cache-dir)
          (directory :tag "Custom cache directory"))
  :group 'convenience)

(when (and (stringp custom-file)
           (file-readable-p custom-file))
  (load custom-file 'noerror 'nomessage))

(defconst rk/cache-paths
  '((backup-directory . "backup/")
    (auto-save-directory . "auto-save/files/")
    (auto-save-list-directory . "auto-save/sessions/")
    (desktop-directory . "desktop/")
    (savehist-file . "history/savehist")
    (recentf-save-file . "history/recentf")
    (save-place-file . "history/save-place")
    (bookmark-default-file . "bookmarks")
    (project-list-file . "project/list")
    (ielm-history-file-name . "history/ielm")
    (url-history-file . "network/url/history")
    (nsm-settings-file . "network/security.data")
    (eshell-directory-name . "eshell/")
    (eshell-history-file-name . "eshell/history")
    (tramp-persistency-file-name . "tramp/persistency"))
  "Mapping of writable state keys to relative paths under `rk/cache-directory'.")

(defun rk/cache-path (key)
  "Return absolute cache path associated with KEY."
  (let ((rel (alist-get key rk/cache-paths)))
    (unless rel
      (error "Unknown cache path key: %s" key))
    (expand-file-name rel rk/cache-directory)))

(defun rk/cache-ensure-directories ()
  "Create `rk/cache-directory' and all mapped directories."
  (make-directory rk/cache-directory t)
  (dolist (entry rk/cache-paths)
    (let* ((rel (cdr entry))
           (path (rk/cache-path (car entry)))
           (dir (if (directory-name-p rel)
                    path
                  (file-name-directory path))))
      (when dir
        (make-directory dir t)))))

(rk/cache-ensure-directories)

(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      auto-save-list-file-prefix
      (expand-file-name ".saves-" (rk/cache-path 'auto-save-list-directory))
      auto-save-file-name-transforms `((".*" ,(rk/cache-path 'auto-save-directory) t))
      backup-directory-alist `((".*" . ,(rk/cache-path 'backup-directory)))
      savehist-file (rk/cache-path 'savehist-file)
      recentf-save-file (rk/cache-path 'recentf-save-file)
      save-place-file (rk/cache-path 'save-place-file)
      bookmark-default-file (rk/cache-path 'bookmark-default-file)
      project-list-file (rk/cache-path 'project-list-file)
      ielm-history-file-name (rk/cache-path 'ielm-history-file-name)
      url-history-file (rk/cache-path 'url-history-file)
      nsm-settings-file (rk/cache-path 'nsm-settings-file)
      eshell-directory-name (rk/cache-path 'eshell-directory-name)
      eshell-history-file-name (rk/cache-path 'eshell-history-file-name))

(setq create-lockfiles nil)

;;; Global font and startup frame behavior
(add-to-list 'default-frame-alist '(font . "Iosevka NFM-14"))
(add-to-list 'initial-frame-alist '(font . "Iosevka NFM-14"))

;;; Restore previous session state (including frame/window state when available)
(setq desktop-dirname (rk/cache-path 'desktop-directory)
      desktop-path (list desktop-dirname)
      desktop-base-file-name "desktop"
      desktop-save t
      desktop-load-locked-desktop t
      desktop-restore-eager 5)
(desktop-save-mode 1)

(with-eval-after-load 'tramp
  (setopt tramp-persistency-file-name
          (rk/cache-path 'tramp-persistency-file-name)))

;;; Emacs 29/30 built-in quality-of-life defaults
(setq scroll-margin 0
      scroll-conservatively 101
      scroll-preserve-screen-position t
      next-screen-context-lines 3
      maximum-scroll-margin 0.0)  ; disable scroll-past-end-of-buffer

(defun rk/enable-post-startup-modes ()
  "Enable non-critical global modes after startup."
  (global-display-line-numbers-mode 1)
  (global-hl-line-mode 1)
  (pixel-scroll-precision-mode 1) ; smooth pixel-level scrolling (Emacs 29)
  (context-menu-mode 1)           ; right-click context menus (Emacs 28)
  (global-so-long-mode 1)         ; graceful handling of very long lines (Emacs 27)
  (repeat-mode 1))                ; make built-in commands repeatable (Emacs 28)

(add-hook 'emacs-startup-hook #'rk/enable-post-startup-modes)

;;; Emacs 31 settings
;; No surprise fan spin-up from background native compilation on battery.
(setq native-comp-async-on-battery-power nil)
;; Don't pop up a warnings buffer for routine native-comp warnings.
(setq native-comp-async-report-warnings-errors 'silent)
;; Keyboard-only prompts: no GUI dialog boxes for save/kill confirmations.
(setq use-dialog-box nil)
;; Live lossage view — useful when screen-sharing or teaching.
(setq view-lossage-auto-refresh t)
;; Show help-at-point documentation via ElDoc.
(setq eldoc-help-at-pt t)
;; Tooltips in terminal frames.
(tty-tip-mode 1)

(defun reload-config ()
  "Reload init.el without restarting Emacs."
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory)))

(defun rk/startup-profile-recipe ()
  "Show terminal commands to benchmark and profile startup."
  (interactive)
  (message
   "Measure: emacs --init-directory %s --eval '(kill-emacs)'; Profile: RK_PROFILE_STARTUP=1 emacs --init-directory %s"
   user-emacs-directory user-emacs-directory))

(provide 'core-settings)
;;; core-settings.el ends here
