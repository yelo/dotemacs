;;; core-settings.el --- Sensible defaults -*- lexical-binding: t; -*-

;;; Useful defaults
(setq inhibit-startup-screen t)
(setq initial-scratch-message "")
(setq-default frame-title-format '("%b"))
(setq ring-bell-function 'ignore)
(setq-default cursor-type 'bar)
(setq use-short-answers t)           ; answer prompts with y/n instead of yes/no
(delete-selection-mode 1)         ; typing replaces selected region
(global-auto-revert-mode t)       ; reload files changed on disk
(setq auto-revert-use-notify t)   ; use OS filesystem notifications instead of polling
(global-display-line-numbers-mode 1)
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

;;; Initial frame size
(setq initial-frame-alist
      (append initial-frame-alist
              '((left . 350)
                (top . 100)
                (width . 190)
                (height . 50))))

;;; Emacs 29/30 built-in quality-of-life modes
(pixel-scroll-precision-mode 1)   ; smooth pixel-level scrolling (Emacs 29)
(context-menu-mode 1)             ; right-click context menus (Emacs 28)
(global-so-long-mode 1)           ; graceful handling of very long lines (Emacs 27)
(repeat-mode 1)                   ; make built-in commands repeatable (Emacs 28)

(defun reload-config ()
  "Reload init.el without restarting Emacs."
  (interactive)
  (load-file (expand-file-name "init.el" user-emacs-directory)))
