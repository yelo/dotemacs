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
  (delete-region (point) (save-excursion (backward-word) (point))))

(keymap-global-set "M-DEL" 'rk/backward-kill-word)
(keymap-global-set "C-DEL" 'rk/backward-kill-word)
(keymap-global-set "C->"   'indent-rigidly-right-to-tab-stop)
(keymap-global-set "C-<"   'indent-rigidly-left-to-tab-stop)

;; Emacs 31: kill word backwards with C-w when no region is active (no more
;; "mark not active" errors).
(setq kill-region-dwim 'emacs-word)

;; Emacs 31: don't highlight mismatched parens inside comments and strings.
(setq show-paren-not-in-comments-or-strings 'on-mismatch)

;; Emacs 31: mark the affected region after `delete-pair', making it easy
;; to act on (e.g. C-x C-x to highlight it) right after deleting delimiters.
(setq delete-pair-push-mark t)

;; Emacs 31: inverse of M-q (fill-paragraph).
(keymap-global-set "M-Q" #'unfill-paragraph)

;; Emacs 31: show fold indicators and line counts in the fringe.
(setq hs-show-indicators t)
(setq hs-display-lines-hidden t)
(add-hook 'prog-mode-hook #'hs-minor-mode) ; hs-show-indicators needs this to do anything

;; Stop at camelCase/snake_case boundaries when moving/killing words.
(global-subword-mode 1)

;; Make incremental search more informative and forgiving.
(setq lazy-count-prefix-format "(%s/%s) "
      isearch-lazy-count t
      isearch-allow-motion t
      isearch-allow-scroll t
      isearch-repeat-on-direction-change t
      isearch-wrap-pause 'no-ding)
(with-eval-after-load 'isearch
  (keymap-set isearch-mode-map
              "C-."
              #'isearch-forward-thing-at-point))

;; Show the current function/method name in the mode line.
;; `which-function-mode' is a *global* mode: enabling it from `prog-mode-hook'
;; would toggle it off again on every other prog buffer.
(which-function-mode 1)

(provide 'core-editing)
;;; core-editing.el ends here
