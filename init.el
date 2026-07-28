;; https://sanemacs.com
(load "~/.emacs.d/sanemacs.el" nil t)
(setq byte-compile-warnings '(cl-functions))
(require 'cl-lib)

;; Core modules (order matters for dependencies)
(dolist (core '("core-settings"
                "core-ui"
                "core-dashboard"
                "core-files"
                "core-editing"
                "core-keybindings"
                "core-completion"
                "core-lsp"
                "core-vc"))
  (load (expand-file-name core (expand-file-name "lisp/" user-emacs-directory))))

;; OS-specific modules
(when (eq system-type 'darwin)
  (load (expand-file-name "os-macos" (expand-file-name "lisp/" user-emacs-directory))))

;; Language modules (auto-discovered — add/remove files freely)
(dolist (file (directory-files (expand-file-name "lisp/" user-emacs-directory) t "^lang-.*\\.el$"))
  (load file nil t))

;; AI/agent modules (auto-discovered — add/remove files freely)
(dolist (file (directory-files (expand-file-name "lisp/" user-emacs-directory) t "^ai-.*\\.el$"))
  (load file nil t))
