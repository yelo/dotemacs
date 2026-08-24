;;; core-completion.el --- Completion framework -*- lexical-binding: t; -*-

;; Keep flex ordering from completion backends.
(defun rk/completion-preserve-order (completions)
  "Return COMPLETIONS unchanged."
  completions)

(add-to-list 'completion-styles-alist
             '(rk/flex-noinsert
               completion-flex-try-completion
               completion-flex-all-completions
               "Flex completion without inserting ambiguous merged candidates."
               (display-sort-function . rk/completion-preserve-order)
               (cycle-sort-function . rk/completion-preserve-order)))

;; Built-in minibuffer completion UI.
(fido-vertical-mode 1)
(setq enable-recursive-minibuffers t)

;; Persist minibuffer history, plus kill-ring and search history.
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(savehist-mode 1)

;; Built-in completion styles only.
(setq completion-styles '(basic partial-completion flex initials substring)
      completion-category-defaults nil
      completion-category-overrides
      '((file (styles basic partial-completion))
        (eglot-capf (styles rk/flex-noinsert basic initials substring))))

;; fido-vertical-mode renders candidates inside the minibuffer itself.
;; Disable eager *Completions* display to avoid a duplicate pane.
(setq completion-eager-update nil
      completion-eager-display nil
      completion-auto-select t
      completion-show-help nil
      completions-format 'one-column
      completions-max-height 10
      completions-sort 'historical
      minibuffer-visible-completions nil)

;; File and buffer candidates for built-in completion commands.
(recentf-mode 1)
(setq recentf-max-saved-items 500)

;; Completion at point remains the built-in CAPF stack.
(setq tab-always-indent 'complete)

;; Emacs 30: inline completion preview.
;; Tab is reserved for tab-always-indent/complete; bind preview-insert to M-Tab.
(setq completion-preview-minimum-symbol-length 2)
(with-eval-after-load 'completion-preview
  (keymap-unset completion-preview-active-mode-map "<tab>" t)
  (keymap-unset completion-preview-active-mode-map "TAB" t)
  (keymap-set completion-preview-active-mode-map "M-<tab>" #'completion-preview-insert))
(add-hook 'prog-mode-hook #'completion-preview-mode)

(provide 'core-completion)
;;; core-completion.el ends here
