;;; core-completion.el --- Completion framework -*- lexical-binding: t; -*-

;; Keep flex ordering from completion backends.
(defun rk/completion-preserve-order (completions)
  "Return COMPLETIONS unchanged."
  completions)

(defun rk/completion-flex-noinsert-metadata (metadata)
  "Prefer backend-provided ordering for METADATA."
  (let ((meta (if (and (consp metadata) (eq (car metadata) 'metadata))
                  (cdr metadata)
                metadata)))
    `(metadata
      (display-sort-function . rk/completion-preserve-order)
      (cycle-sort-function . rk/completion-preserve-order)
      ,@meta)))

(defun rk/completion-flex-try-noinsert (string table pred point)
  "Try flex completion while avoiding ambiguous insertion."
  (let ((result (completion-flex-try-completion string table pred point)))
    (if (and (consp result)
             (> (cdr result) point)
             (> (length (completion-flex-all-completions string table pred point)) 1))
        (cons string point)
      result)))

(add-to-list 'completion-styles-alist
             '(rk/flex-noinsert
               rk/completion-flex-try-noinsert
               completion-flex-all-completions
               "Flex completion without inserting ambiguous merged candidates."
               (completion--adjust-metadata . rk/completion-flex-noinsert-metadata)))

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

;; Emacs 31: refresh and show completions eagerly while typing.
(setq completion-eager-update t
      completion-eager-display t
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
(setq completion-preview-minimum-symbol-length 2)
(add-hook 'prog-mode-hook #'completion-preview-mode)

(provide 'core-completion)
;;; core-completion.el ends here
