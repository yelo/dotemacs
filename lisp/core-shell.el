;;; core-shell.el --- Shell and terminal configuration -*- lexical-binding: t; -*-

(require 'use-package)

;; eshell — Emacs's built-in shell.
(setq eshell-prefer-lisp-functions nil
      eshell-destroy-buffer-when-process-dies t
      eshell-history-size 10000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input 'all
      eshell-scroll-to-bottom-on-output 'all)

;; Hand full-screen/interactive programs off to term instead of garbling
;; their output in the eshell buffer.
(with-eval-after-load 'em-term
  (dolist (cmd '("htop" "top" "less" "ssh" "tmux"))
    (add-to-list 'eshell-visual-commands cmd)))

;; Built-in terminal modes do not benefit from line numbers.
(add-hook 'shell-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'term-mode-hook (lambda () (display-line-numbers-mode -1)))

(use-package ghostel
  :vc (:url "https://github.com/dakra/ghostel"
       :lisp-dir "lisp")
  :bind (("C-c s" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s" . consult-line))
  :hook (ghostel-mode . (lambda () (display-line-numbers-mode -1))))

(use-package ghostel-project
  :ensure nil
  :after ghostel
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :config
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands
               '(ghostel-project-list-buffers "Ghostel buffers") t))

(provide 'core-shell)
;;; core-shell.el ends here
