;;; core-treesit.el --- Tree-sitter integration -*- lexical-binding: t; -*-

;; Emacs 31: automatically switch to tree-sitter major modes when grammars are
;; available.  Keep the list guarded so a missing grammar or optional built-in
;; mode does not affect startup on a trimmed Emacs build.
(require 'treesit)
(setq treesit-enabled-modes t)

;; Maximize syntax highlighting detail (levels 1-4, default is 3).
(setq treesit-font-lock-level 4)

(dolist (remap '((c-mode c-ts-mode c)
                 (c++-mode c++-ts-mode cpp)
                 (c-or-c++-mode c-or-c++-ts-mode cpp)
                 (css-mode css-ts-mode css)
                 (java-mode java-ts-mode java)
                 (js-mode js-ts-mode javascript)
                 (json-mode json-ts-mode json)
                 (python-mode python-ts-mode python)
                 (rust-mode rust-ts-mode rust)
                 (sh-mode bash-ts-mode bash)
                 (typescript-mode typescript-ts-mode typescript)
                 (yaml-mode yaml-ts-mode yaml)
                 (toml-mode toml-ts-mode toml)))
  (let ((source (nth 0 remap))
        (target (nth 1 remap))
        (language (nth 2 remap)))
    (when (and (or (fboundp target)
                   (locate-library (symbol-name target)))
               (treesit-language-available-p language))
      (setf (alist-get source major-mode-remap-alist) target))))

(provide 'core-treesit)
;;; core-treesit.el ends here
