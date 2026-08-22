;;; lang-elisp.el --- Emacs Lisp bindings -*- lexical-binding: t; -*-

(with-eval-after-load 'elisp-mode
  (define-key emacs-lisp-mode-map (kbd "C-c C-z") #'ielm)
  (define-key emacs-lisp-mode-map (kbd "C-c C-b") #'eval-buffer)
  (define-key emacs-lisp-mode-map (kbd "C-c C-r") #'eval-region)
  (define-key emacs-lisp-mode-map (kbd "C-c C-d") #'eval-defun)
  (define-key emacs-lisp-mode-map (kbd "C-c C-f") #'find-function)
  (define-key emacs-lisp-mode-map (kbd "C-c C-v") #'find-variable))

(provide 'lang-elisp)
;;; lang-elisp.el ends here
