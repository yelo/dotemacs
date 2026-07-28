;;; lang-python.el --- Python bindings -*- lexical-binding: t; -*-

(add-hook 'python-mode-hook #'lsp-deferred)

(rk/lang 'python 'python-mode-map
  "e" '(python-shell-send-statement :which-key "send statement")
  "r" '(python-shell-send-region :which-key "send region")
  "b" '(python-shell-send-buffer :which-key "send buffer")
  "f" '(python-shell-send-file :which-key "send file")
  "'" '(run-python :which-key "REPL")
  "d" '(lsp-find-definition :which-key "go to definition")
  "D" '(lsp-find-references :which-key "find references")
  "R" '(lsp-rename :which-key "rename")
  "a" '(lsp-execute-code-action :which-key "code action"))
