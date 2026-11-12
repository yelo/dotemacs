;;; lang-swift.el --- Swift / SwiftUI (iOS) bindings -*- lexical-binding: t; -*-

;; Requires: Xcode or Swift toolchain on $PATH.
;; LSP server: sourcekit-lsp (ships with the toolchain; `xcrun --find sourcekit-lsp').
;; Grammar: installed on demand — M-x rk/swift-install-grammar.
;; Pinned to 0.7.1: newer grammars break swift-ts-mode keyword highlighting.

(require 'use-package)
(require 'treesit)

(add-to-list 'treesit-language-source-alist
             '(swift "https://github.com/alex-pinkus/tree-sitter-swift"
                     "0.7.1-with-generated-files"))

(defun rk/swift-install-grammar ()
  "Install the Swift tree-sitter grammar."
  (interactive)
  (treesit-install-language-grammar 'swift))

(use-package swift-ts-mode
  :ensure t
  :mode "\\.swift\\'"
  :hook (swift-ts-mode . eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(swift-ts-mode . ("sourcekit-lsp"))))

(defun rk/swift--root ()
  "Return the nearest directory with Package.swift or an Xcode project."
  (or (locate-dominating-file default-directory "Package.swift")
      (locate-dominating-file
       default-directory
       (lambda (dir) (directory-files dir nil "\\.xcodeproj\\'" t)))
      (when-let* ((proj (project-current nil default-directory)))
        (project-root proj))
      default-directory))

(defun rk/swift-package (subcommand)
  "Run `swift SUBCOMMAND' (SwiftPM) in the package root via `compile'."
  (interactive
   (list (completing-read "swift: "
                          '("build" "run" "test" "package resolve"
                            "package clean")
                          nil nil nil nil "build")))
  (let ((default-directory (rk/swift--root)))
    (compile (format "swift %s" subcommand))))

(defun rk/swift-xcodebuild (subcommand)
  "Run `xcodebuild SUBCOMMAND' after choosing a scheme; use `C-u' via edit.
The command line is editable before running so destination can be set."
  (interactive
   (list (completing-read "xcodebuild: " '("build" "test" "clean" "-list")
                          nil nil nil nil "build")))
  (let ((default-directory (rk/swift--root)))
    (compile (read-string "Compile command: "
                          (format "xcodebuild %s -scheme " subcommand)))))

(defvar rk/swift-map (make-sparse-keymap)
  "Swift shortcuts under C-c c.")
(define-key rk/swift-map (kbd "b") (lambda () (interactive) (rk/swift-package "build")))
(define-key rk/swift-map (kbd "r") (lambda () (interactive) (rk/swift-package "run")))
(define-key rk/swift-map (kbd "t") (lambda () (interactive) (rk/swift-package "test")))
(define-key rk/swift-map (kbd "x") #'rk/swift-xcodebuild)
(define-key rk/swift-map (kbd "!") #'rk/swift-package)

(with-eval-after-load 'swift-ts-mode
  (define-key swift-ts-mode-map (kbd "C-c c") rk/swift-map))

(provide 'lang-swift)
;;; lang-swift.el ends here
