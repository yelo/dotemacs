;;; core-completion.el --- Completion framework -*- lexical-binding: t; -*-

;; Built-in minibuffer completion UI.
(fido-vertical-mode 1)
(setq enable-recursive-minibuffers t)

;; Persist minibuffer history, plus kill-ring and search history.
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(savehist-mode 1)

;; Built-in completion styles only.
(setq completion-styles '(basic partial-completion initials substring)
      completion-category-defaults nil
      completion-category-overrides '((file (styles basic partial-completion))))

;; Emacs 31: refresh and show completions eagerly while typing.
(setq completion-eager-update t
      completion-eager-display t
      minibuffer-visible-completions 'up-down)

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
