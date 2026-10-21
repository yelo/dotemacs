;;; core-completion.el --- Completion framework -*- lexical-binding: t; -*-

(require 'use-package)
(require 'project)
(require 'savehist)
(require 'recentf)

(declare-function consult--file-state "consult")
(declare-function consult--project-root "consult" (&optional prompt))
(declare-function consult--customize-put "consult" (cmds prop form))
(declare-function rk/tab-route-file "core-tabs" (file))

(defun rk/completion-flex-try-noinsert (string table pred point)
  "Flex-complete STRING from TABLE without expanding ambiguous matches.
PRED and POINT have the same meaning as in `completion-try-completion'."
  (let ((matches (completion-flex-all-completions string table pred point)))
    (cond
     ((null matches) nil)
     ((consp (cdr matches)) (cons string point))
     (t (completion-flex-try-completion string table pred point)))))

;; Keep flex ordering from completion backends.
(defun rk/completion-preserve-order (completions)
  "Return COMPLETIONS unchanged."
  completions)

(setf (alist-get 'rk/flex-noinsert completion-styles-alist)
      '(rk/completion-flex-try-noinsert
        completion-flex-all-completions
        "Flex completion without inserting ambiguous merged candidates."
        (display-sort-function . rk/completion-preserve-order)
        (cycle-sort-function . rk/completion-preserve-order)))

(fido-vertical-mode -1)
(fido-mode -1)
(icomplete-mode -1)

(use-package vertico
  :ensure t
  :demand t
  :config
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :demand t
  :config
  (marginalia-mode 1))

(which-key-mode 1)
(setq enable-recursive-minibuffers t)

;; Persist minibuffer history, plus kill-ring and search history.
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(savehist-mode 1)

(use-package orderless
  :ensure t
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles basic partial-completion))
     (eglot-capf (styles rk/flex-noinsert basic initials substring)))))

(setq completion-ignore-case t)

;; Vertico renders candidates inside the minibuffer.  Do not also open a
;; duplicate `*Completions*' window for every minibuffer completion.
(setq completion-eager-update nil
      completion-eager-display nil
      completion-auto-select t
      completion-auto-help 'lazy
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

(setq tab-always-indent 'complete)

(global-completion-preview-mode -1)
(use-package corfu
  :ensure t
  :demand t
  :custom
  (corfu-auto nil)
  (corfu-preselect 'prompt)
  (corfu-preview-current nil)
  (corfu-on-exact-match nil)
  (global-corfu-minibuffer nil)
  :config
  (global-corfu-mode 1))

(defun rk/consult-project-search ()
  "Search the current project with Consult and ripgrep."
  (interactive)
  (unless (executable-find "rg")
    (user-error "Install ripgrep (rg) for Consult search; use C-x p s for built-in search"))
  (let ((default-directory (project-root (project-current t))))
    (call-interactively #'consult-ripgrep)))

(defun rk/consult-file-state ()
  "Return a Consult file state that routes only accepted local files."
  ;; Reuse Consult's preview lifecycle; routing on `preview' would change tabs
  ;; even when the user cancels the minibuffer.
  (let ((state (consult--file-state)))
    (lambda (action candidate)
      (when (and (eq action 'return) candidate
                 (not (file-remote-p candidate)))
        (rk/tab-route-file candidate))
      (funcall state action candidate))))

(use-package consult
  :ensure t
  :commands (consult-buffer consult-project-buffer consult-recent-file
             consult-imenu consult-line consult-ripgrep)
  :config
  (consult-customize
   consult-recent-file :state (rk/consult-file-state)
   consult-source-recent-file consult-source-project-recent-file
   consult-source-project-recent-file-hidden
   :state #'rk/consult-file-state)
  (consult-customize
   consult-source-recent-file :new #'find-file
   consult-source-project-recent-file consult-source-project-recent-file-hidden
   :new (lambda (file)
          (find-file (expand-file-name file (consult--project-root)))))
  (consult-customize
   consult-recent-file
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   consult-source-project-recent-file-hidden
   :preview-key "M-."))

(provide 'core-completion)
;;; core-completion.el ends here
