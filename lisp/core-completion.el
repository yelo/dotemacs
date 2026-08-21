;;; core-completion.el --- Completion framework -*- lexical-binding: t; -*-

(use-package vertico
  :ensure t
  :hook (emacs-startup . vertico-mode)
  :custom
  (vertico-cycle t)
  (enable-recursive-minibuffers t))

(use-package savehist
  :ensure nil
  :hook (emacs-startup . savehist-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (orderless-matching-styles '(orderless-flex orderless-literal orderless-regexp)))

(use-package marginalia
  :ensure t
  :preface
  ;; Compatibility shim for stale byte-compiled package combinations where
  ;; Marginalia calls compat--seconds-to-string directly.
  (unless (fboundp 'compat--seconds-to-string)
    (defalias 'compat--seconds-to-string #'seconds-to-string))
  :hook (emacs-startup . marginalia-mode))

(use-package consult
  :ensure t
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("C-c k" . consult-ripgrep)
         ("M-x" . execute-extended-command)
         ("C-c M-x" . consult-mode-command))
  :custom
  (consult-preview-key 'any)
  (consult-project-function (lambda (_)
    (when-let (p (project-current)) (project-root p)))))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim))
  :config
  (use-package embark-consult
    :ensure t
    :hook
    (embark-collect-mode . consult-preview-at-point-mode)))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :hook (emacs-startup . global-corfu-mode)
  :bind (:map corfu-map
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous)))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file t)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev t)
  (add-to-list 'completion-at-point-functions #'cape-keyword t))

(use-package tempel
  :ensure t
  :bind (("M-+" . tempel-complete)
         ("C-c t i" . tempel-insert))
  :init
  (add-to-list 'completion-at-point-functions #'tempel-expand t))

(use-package tempel-collection
  :ensure t
  :after tempel)

(setq tab-always-indent 'complete)

;; Emacs 30: inline ghost-text completion preview (works alongside corfu)
(use-package completion-preview
  :ensure nil  ; built-in since Emacs 30
  :hook (prog-mode . completion-preview-mode)
  :custom
  (completion-preview-minimum-symbol-length 2))
