;;; core-editing.el --- Editing defaults -*- lexical-binding: t; -*-

(setq-default tab-width 4)
(electric-pair-mode 1)            ; built-in bracket/quote pairing

(setq show-paren-delay 0)
(setq show-paren-context-when-offscreen 'overlay) ; show matching paren in overlay when off-screen (Emacs 29)
(show-paren-mode 1)

;;; Kill word backward without polluting the kill ring
(defun rk/backward-kill-word ()
  "Delete word backward without copying it to the kill ring."
  (interactive "*")
  (push-mark)
  (backward-word)
  (delete-region (point) (mark)))

(keymap-global-set "M-DEL" 'rk/backward-kill-word)
(keymap-global-set "C-DEL" 'rk/backward-kill-word)
(keymap-global-set "C->"   'indent-rigidly-right-to-tab-stop)
(keymap-global-set "C-<"   'indent-rigidly-left-to-tab-stop)

;; Emacs 31: kill word backwards with C-w when no region is active (no more
;; "mark not active" errors).
(setq kill-region-dwim 'emacs-word)

;; Emacs 31: don't highlight mismatched parens inside comments and strings.
(setq show-paren-not-in-comments-or-strings 'on-mismatch)

;; Emacs 31: show fold indicators and line counts in the fringe.
(setq hs-show-indicators t)
(setq hs-display-lines-hidden t)

(provide 'core-editing)
;;; core-editing.el ends here
