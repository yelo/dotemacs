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

;;; Backup and autosave — redirect to system tmp
(defconst rk/emacs-tmp-dir
  (expand-file-name (format "emacs%d" (user-uid)) temporary-file-directory))
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      auto-save-list-file-prefix rk/emacs-tmp-dir
      auto-save-file-name-transforms `((".*" ,rk/emacs-tmp-dir t))
      backup-directory-alist `((".*" . ,rk/emacs-tmp-dir)))

(setq create-lockfiles nil)

;;; Global font and startup frame behavior
(add-to-list 'default-frame-alist '(font . "Iosevka NFM-14"))
(add-to-list 'initial-frame-alist '(font . "Iosevka NFM-14"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

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
