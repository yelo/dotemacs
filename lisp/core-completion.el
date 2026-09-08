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
;; Note: `fido-vertical-mode' forces its own `completion-styles' inside the
;; minibuffer, so the list below effectively governs *in-buffer* completion
;; (CAPF) and the category overrides, not minibuffer matching.
(setq completion-styles '(basic partial-completion flex initials substring)
      completion-category-defaults nil
      completion-category-overrides
      '((file (styles basic partial-completion))
        (eglot-capf (styles rk/flex-noinsert basic initials substring))))

;; Keep the vertical minibuffer UI, while also making the standard
;; `*Completions*' buffer useful in contexts that display it.
(setq completion-eager-update t
      completion-eager-display t
      completion-auto-select 'second-tab
      completion-auto-help 'always
      completion-show-help nil
      completions-detailed t
      completions-group t
      completions-format 'one-column
      completions-max-height 20
      completions-sort 'historical
      minibuffer-visible-completions t)

;; File and buffer candidates for built-in completion commands.
;; `recentf-mode' normally runs a cleanup pass when enabled, which stats every
;; saved entry — including remote/TRAMP paths, which can stall startup. Defer
;; cleanup to idle time and never touch remote files.
(setq recentf-max-saved-items 500
      recentf-auto-cleanup 300
      recentf-keep '(file-remote-p file-readable-p))
(recentf-mode 1)

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
