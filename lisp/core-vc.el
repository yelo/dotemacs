;;; core-vc.el --- Version control -*- lexical-binding: t; -*-

(use-package project
  :ensure nil  ; built-in since Emacs 28
  :custom
  (project-switch-commands
   '((project-find-file    "Find file"    "f")
     (project-dired        "Dired"        "d")
     (consult-ripgrep      "Ripgrep"      "g")
     (magit-project-status "Magit"        "m"))))

(use-package magit
  :ensure t
  :commands (magit-status magit-blame-addition magit-log-current magit-commit-create magit-project-status)
  :bind (("C-x g" . magit-status)))
