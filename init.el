;;; init.el --- Main configuration entry point -*- lexical-binding: t; -*-

;;; Custom file — keep auto-generated settings out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file nil t)

;; Avoid loading stale byte-compiled files when source is newer.
(setq load-prefer-newer t)

(setq byte-compile-warnings '(not cl-functions))
(require 'cl-lib)

(when (getenv "RK_PROFILE_STARTUP")
  (require 'profiler)
  (profiler-start 'cpu+mem))

;; Core modules (order matters for dependencies)
(dolist (core '("core-settings"
                "core-ui"
                "core-dashboard"
                "core-files"
                "core-editing"
                "core-windows"
                "core-keybindings"
                "core-completion"
                "core-eglot"
                "core-flymake"
                "core-treesit"
                "core-vc"
                "core-shell"
                "core-markdown"))
  (load (expand-file-name core (expand-file-name "lisp/" user-emacs-directory))))

;; TTY / terminal-mode enhancements (only when running without a window system)
(unless (display-graphic-p)
  (load (expand-file-name "core-tty" (expand-file-name "lisp/" user-emacs-directory)) nil t))

;; OS-specific modules
(pcase system-type
  ('darwin
   (load (expand-file-name "os-macos" (expand-file-name "lisp/" user-emacs-directory))))
  ('gnu/linux
   (load (expand-file-name "os-linux" (expand-file-name "lisp/" user-emacs-directory)) nil t))
  ('windows-nt
   (load (expand-file-name "os-windows" (expand-file-name "lisp/" user-emacs-directory)) nil t)))

(defvar rk/extra-modules-loaded nil
  "Non-nil once optional language modules have been loaded.")

(defun rk/load-module-family (prefix)
  "Load all optional modules from lisp/ that start with PREFIX."
  (dolist (file (directory-files (expand-file-name "lisp/" user-emacs-directory)
                                 t
                                 (format "^%s-.*\\.el$" prefix)))
    (load file nil t)))

(defun rk/load-extra-modules ()
  "Load optional language modules once."
  (unless rk/extra-modules-loaded
    (setq rk/extra-modules-loaded t)
    (rk/load-module-family "lang")))

;; Keep startup critical path minimal; load optional modules right after startup
;; or immediately when the first file is opened.
(add-hook 'emacs-startup-hook
          (lambda ()
            (run-with-idle-timer 0.2 nil #'rk/load-extra-modules)))
(add-hook 'find-file-hook #'rk/load-extra-modules)

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (emacs-init-time "%0.2f seconds")
                     gcs-done)
            (when (getenv "RK_PROFILE_STARTUP")
              (profiler-stop)
              (profiler-report))))
