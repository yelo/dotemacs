;;; Bootstrap package.el
(require 'package)
(setq package-enable-at-startup nil)
(setq package-quickstart t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(unless package--initialized (package-initialize))

;;; Bootstrap use-package
(unless (require 'use-package nil 'noerror)
  (unless package-archive-contents
    (package-refresh-contents))
  (package-install 'use-package)
  (require 'use-package))
(setq use-package-always-ensure t)

;;; Custom file — keep auto-generated settings out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file nil t)

(setq byte-compile-warnings '(cl-functions))
(require 'cl-lib)

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
                "core-vc"
                "core-shell"))
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
