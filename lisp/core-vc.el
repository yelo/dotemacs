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

;; ── blamer: inline git author annotations (Code Vision style) ──
(use-package blamer
  :ensure t
  :custom
  ;; Delay before rendering the annotation after the cursor stops.
  (blamer-idle-time 0.3)
  ;; Minimum column offset before the virtual text starts.
  (blamer-min-offset 70)
  ;; Show both author name and abbreviated commit summary.
  (blamer-type 'both)
  (blamer-max-commit-message-length 60)
  ;; Format strings — keep them concise.
  (blamer-author-formatter "  ● %s")
  (blamer-commit-formatter ", %s")
  (blamer-datetime-formatter " · %s")
  :init
  (global-blamer-mode 1))
