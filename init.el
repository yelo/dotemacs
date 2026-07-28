;; https://sanemacs.com
(load "~/.emacs.d/sanemacs.el" nil t)
(setq byte-compile-warnings '(cl-functions))
(require 'cl-lib)

;; Core modules (order matters for dependencies)
(dolist (core '("core-settings"
                 "core-ui"
                 "core-dashboard"
                 "core-editing"
                 "core-keybindings"
                 "core-completion"
                 "core-dev"
                 "core-vc"))
  (load (expand-file-name core (expand-file-name "lisp/" user-emacs-directory))))

;; Language modules (auto-discovered — add/remove files freely)
(dolist (file (directory-files (expand-file-name "lisp/" user-emacs-directory) t "^lang-.*\\.el$"))
  (load file nil t))
