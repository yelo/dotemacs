;;; init.el --- Main configuration entry point -*- lexical-binding: t; -*-

;;; Bootstrap package.el
(require 'package)
(setq package-quickstart t)
;; package-quickstart.el is auto-generated; run M-x package-quickstart-refresh
;; after installing packages to rebuild it (absent file → full scan, works fine).
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(unless package--initialized (package-initialize))

;;; use-package is built-in since Emacs 29
(require 'use-package)
(setq use-package-always-ensure t)

;;; Custom file — keep auto-generated settings out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file nil t)

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
                "core-lsp"
                "core-flycheck"
                "core-treesit"
                "core-vc"
                "core-shell"))
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
  "Non-nil once optional language and AI modules have been loaded.")

(defun rk/load-module-family (prefix)
  "Load all optional modules from lisp/ that start with PREFIX."
  (dolist (file (directory-files (expand-file-name "lisp/" user-emacs-directory)
                                 t
                                 (format "^%s-.*\\.el$" prefix)))
    (load file nil t)))

(defun rk/load-extra-modules ()
  "Load optional language and AI modules once."
  (unless rk/extra-modules-loaded
    (setq rk/extra-modules-loaded t)
    (rk/load-module-family "lang")
    (rk/load-module-family "ai")))

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
