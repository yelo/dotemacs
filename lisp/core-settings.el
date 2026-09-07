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
;; Only in code buffers: in text/Markdown, trailing whitespace is meaningful
;; (two trailing spaces are a hard line break) and stripping it in shared
;; repositories produces noisy, unrelated diffs.
(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)))

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

(defun rk/cache-setopt (&rest var-key-pairs)
  "Set multiple variables from cache-paths alist.
Each pair should be (SYMBOL CACHE-KEY) where SYMBOL is set to (rk/cache-path CACHE-KEY)."
  (while var-key-pairs
    (let ((var (pop var-key-pairs))
          (key (pop var-key-pairs)))
      (set var (rk/cache-path key)))))

;; Direct cache-path variable mappings
(rk/cache-setopt
 'savehist-file 'savehist-file
 'recentf-save-file 'recentf-save-file
 'save-place-file 'save-place-file
 'bookmark-default-file 'bookmark-default-file
 'project-list-file 'project-list-file
 'ielm-history-file-name 'ielm-history-file-name
 'url-history-file 'url-history-file
 'nsm-settings-file 'nsm-settings-file
 'eshell-directory-name 'eshell-directory-name
 'eshell-history-file-name 'eshell-history-file-name)

;; Special cache-path configurations
(setq backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      auto-save-list-file-prefix
      (expand-file-name ".saves-" (rk/cache-path 'auto-save-list-directory))
      auto-save-file-name-transforms `((".*" ,(rk/cache-path 'auto-save-directory) t))
      backup-directory-alist `((".*" . ,(rk/cache-path 'backup-directory))))

(setq create-lockfiles nil)

;;; Fonts are configured in one place: `core-ui.el'.

;;; Restore previous session state (including frame/window state when available)
(setq desktop-dirname (rk/cache-path 'desktop-directory)
      desktop-path (list desktop-dirname) ; list of directories to save/restore from
      desktop-base-file-name "desktop"
;; Restore the existing session without asking about saving it on exit.
desktop-save 'if-exists
desktop-load-locked-desktop t
desktop-restore-eager 5)
(desktop-save-mode 1)

;; Colors and fonts come from the theme and `core-ui.el', never from the saved
;; session. Without this, restoring a frameset repaints the new frame with the
;; colors that were active when the session was saved — e.g. a dark background
;; under a freshly loaded light theme.
(with-eval-after-load 'frameset
  (setq frameset-filter-alist (copy-alist frameset-filter-alist))
  (dolist (param '(background-color foreground-color cursor-color
                   background-mode font font-parameter fontsize
                   scroll-bar-foreground scroll-bar-background))
    (setf (alist-get param frameset-filter-alist) :never)))

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
  (load-file (expand-file-name "init.el" rk/emacs-dir)))

(provide 'core-settings)
;;; core-settings.el ends here
