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

;; Built-in minibuffer completion UI via native *Completions* buffer.
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

;; Native *Completions* buffer settings: eager display, one-column layout,
;; historical sorting, and arrow-key navigation from inside the minibuffer.
(setq completion-eager-update t
      completion-eager-display t
      completion-auto-select t
      completion-show-help nil
      completions-format 'one-column
      completions-max-height 10
      completions-sort 'historical
      ;; Up/down navigate *Completions* while point stays in the minibuffer.
      minibuffer-visible-completions 'up-down)

;; Navigate candidates with C-n/C-p while typing in the minibuffer.
(define-key minibuffer-local-completion-map (kbd "C-n") #'minibuffer-next-completion)
(define-key minibuffer-local-completion-map (kbd "C-p") #'minibuffer-previous-completion)

;; Show depth indicator when recursing into a second minibuffer.
(minibuffer-depth-indicate-mode 1)
;; Hide "(default foo)" in prompt while typing; restore if input is erased.
(minibuffer-electric-default-mode 1)

;; Keep point out of the read-only prompt text.
(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

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
