;;; core-vc.el --- Version control -*- lexical-binding: t; -*-

(setq project-switch-commands
      '((project-find-file    "Find file"    "f")
        (project-dired        "Dired"        "d")
        (project-find-regexp  "Search"       "s")
        (vc-dir               "VC status"    "v")))

;; ── Emacs 31 VC improvements ──

;; Automatically hide up-to-date files on vc-dir refresh (no more manual g+H).
(setq vc-dir-auto-hide-up-to-date t)

;; Allow rewriting already-published history (Jujutsu / force-push workflows).
(setq vc-allow-rewriting-published-history t)

;; Note: xref-edit-mode is available in Emacs 31 — press 'e' in *xref* buffers
;; to edit results inline (like grep-edit-mode). No configuration needed.

(provide 'core-vc)
;;; core-vc.el ends here
