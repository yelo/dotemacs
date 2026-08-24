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
(define-key rk/window-map (kbd "s") #'split-window-below)
(define-key rk/window-map (kbd "v") #'split-window-right)
(define-key rk/window-map (kbd "k") #'delete-window)
(define-key rk/window-map (kbd "K") #'delete-other-windows)
(define-key rk/window-map (kbd "=") #'balance-windows)
(define-key rk/window-map (kbd "z") #'rk/zoom-toggle)
(define-key rk/window-map (kbd "t") #'window-layout-transpose)
(define-key rk/window-map (kbd "r") #'window-layout-rotate-clockwise)
(define-key rk/window-map (kbd "R") #'window-layout-rotate-anticlockwise)
(define-key rk/window-map (kbd "f") #'window-layout-flip-leftright)
(define-key rk/window-map (kbd "F") #'window-layout-flip-topdown)
(define-key rk/window-map (kbd "S") #'rk/speedbar-toggle)

(defvar rk/vc-map (make-sparse-keymap)
  "Version-control shortcuts under C-c v.")
(keymap-global-set "C-c v" rk/vc-map)
(define-key rk/vc-map (kbd "d") #'vc-dir)
(define-key rk/vc-map (kbd "=") #'vc-diff)
(define-key rk/vc-map (kbd "l") #'vc-print-log)

(keymap-global-set "C-c f" #'find-file)

(defvar rk/buffer-map (make-sparse-keymap)
  "Buffer shortcuts under C-c b.")
(keymap-global-set "C-c b" rk/buffer-map)
(define-key rk/buffer-map (kbd "b") #'switch-to-buffer)
(define-key rk/buffer-map (kbd "k") #'kill-buffer)
(define-key rk/buffer-map (kbd "r") #'revert-buffer)
(define-key rk/buffer-map (kbd "l") #'list-buffers)
(define-key rk/buffer-map (kbd "n") #'next-buffer)
(define-key rk/buffer-map (kbd "p") #'previous-buffer)

(keymap-global-set "C-c r" #'recentf-open-files)
(keymap-global-set "C-c i" #'imenu)
(keymap-global-set "C-c t" #'rk/toggle-light-dark-theme)

(provide 'core-keybindings)
;;; core-keybindings.el ends here
