;;; init.el --- Main configuration entry point -*- lexical-binding: t; -*-

;;; Path constants
(defconst rk/emacs-dir user-emacs-directory
  "The Emacs configuration directory.")

(defconst rk/lisp-dir (expand-file-name "lisp/" rk/emacs-dir)
  "The directory containing Emacs Lisp modules.")

;;; Custom file — keep auto-generated settings out of init.el
(setq custom-file (expand-file-name "custom.el" rk/emacs-dir))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file nil t)

;; Avoid loading stale byte-compiled files when source is newer.
(setq load-prefer-newer t)

(when (getenv "RK_PROFILE_STARTUP")
  (require 'profiler)
  (profiler-start 'cpu+mem))

;; Load a module without letting one broken file abort the rest of startup.
(defun rk/load-module (file &optional noerror-missing)
  "Load Lisp FILE, reporting errors instead of aborting init.
With NOERROR-MISSING non-nil, a missing file is not an error."
  (condition-case err
      (load file noerror-missing)
    (error
     (message "Error loading %s: %s" file (error-message-string err)))))

;; Core modules (order matters for dependencies)
(dolist (core '("core-settings"
                "core-ui"
                "core-modeline"
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
                "core-markdown"
                "core-tabs"))
  (rk/load-module (expand-file-name core rk/lisp-dir)))

;; TTY / terminal-mode enhancements (only when running without a window system)
(unless (display-graphic-p)
  (rk/load-module (expand-file-name "core-tty" rk/lisp-dir) t))

;; OS-specific modules
(pcase system-type
  ('darwin
   (rk/load-module (expand-file-name "os-macos" rk/lisp-dir)))
  ('gnu/linux
   (rk/load-module (expand-file-name "os-linux" rk/lisp-dir) t))
  ('windows-nt
   (rk/load-module (expand-file-name "os-windows" rk/lisp-dir) t)))

(defvar rk/extra-modules-loaded nil
  "Non-nil once optional language modules have been loaded.")

(defun rk/load-module-family (prefix)
  "Load all optional modules from lisp/ that start with PREFIX."
  (dolist (file (directory-files rk/lisp-dir t (format "^%s-.*\\.el$" prefix)))
    (rk/load-module file t)))

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
