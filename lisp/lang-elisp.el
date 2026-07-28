;;; lang-elisp.el --- Emacs Lisp bindings -*- lexical-binding: t; -*-

(rk/lang 'elisp-mode 'emacs-lisp-mode-map
  "e" '(eval-last-sexp :which-key "eval expression")
  "b" '(eval-buffer :which-key "eval buffer")
  "r" '(eval-region :which-key "eval region")
  "d" '(eval-defun :which-key "eval defun")
  "f" '(find-function :which-key "find function")
  "v" '(find-variable :which-key "find variable")
  "h" '(describe-function :which-key "describe function")
  "w" '(elisp-index-search :which-key "search manual")
  "C" '(check-parens :which-key "check parens")
  "i" '(ielm :which-key "ielm REPL")
  "m" '(macroexpand-last-sexp :which-key "macroexpand"))
