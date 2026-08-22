;;; core-keybindings.el --- Minimal built-in keybindings -*- lexical-binding: t; -*-

;; Keep stock Emacs bindings and add a few mnemonic prefixes.

(defvar rk/project-map (make-sparse-keymap)
  "Project shortcuts under C-c p.")
(keymap-global-set "C-c p" rk/project-map)
(define-key rk/project-map (kbd "f") #'project-find-file)
(define-key rk/project-map (kbd "p") #'project-switch-project)
(define-key rk/project-map (kbd "d") #'project-dired)
(define-key rk/project-map (kbd "s") #'project-find-regexp)

(defvar rk/window-map (make-sparse-keymap)
  "Window shortcuts under C-c w.")
(keymap-global-set "C-c w" rk/window-map)
(define-key rk/window-map (kbd "o") #'other-window)
(define-key rk/window-map (kbd "2") #'split-window-below)
(define-key rk/window-map (kbd "3") #'split-window-right)
(define-key rk/window-map (kbd "0") #'delete-window)
(define-key rk/window-map (kbd "1") #'delete-other-windows)
(define-key rk/window-map (kbd "=") #'balance-windows)

(defvar rk/vc-map (make-sparse-keymap)
  "Version-control shortcuts under C-c v.")
(keymap-global-set "C-c v" rk/vc-map)
(define-key rk/vc-map (kbd "d") #'vc-dir)
(define-key rk/vc-map (kbd "=") #'vc-diff)
(define-key rk/vc-map (kbd "l") #'vc-print-log)

(keymap-global-set "C-c f" #'find-file)
(keymap-global-set "C-c b" #'switch-to-buffer)
(keymap-global-set "C-c r" #'recentf-open-files)

(provide 'core-keybindings)
;;; core-keybindings.el ends here
