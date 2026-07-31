;;; core-windows.el --- Window management, layouts, popups -*- lexical-binding: t; -*-

;; ── Built-in window history (undo/redo configurations) ──

(winner-mode 1)

;; ── Prefer not to switch to another buffer when closing a popup window ──
(setq quit-restore-window-no-switch t)

;; ── display-buffer-alist: single source of truth for window placement ──
;;
;; Layout:
;;   LEFT  (slot -1, 25%):  Speedbar — file tree, imenu, VC
;;   RIGHT (slot  0, 38%):  Help, Apropos, Info, Man, Eldoc, xref
;;   BOTTOM (slot 0, 25%):  Compilation, flymake, eshell, Messages, Warnings

;; Dashboard always reuses its own window
(add-to-list 'display-buffer-alist
             '("\\*[Dd]ashboard\\*"
               (display-buffer-same-window)))

;; Right side: documentation and navigation
(add-to-list 'display-buffer-alist
             '("\\*\\(Help\\|Apropos\\|info\\|Man .*\\)\\*"
               (display-buffer-in-side-window)
               (side . right)
               (slot . 0)
               (window-width . 0.38)
               (dedicated . t)))

;; Right side: xref and eldoc
(add-to-list 'display-buffer-alist
             '("\\*\\(xref\\|eldoc\\)\\*"
               (display-buffer-in-side-window)
               (side . right)
               (slot . 1)
               (window-width . 0.38)
               (dedicated . t)))

;; Bottom: diagnostics, output, process buffers
(add-to-list 'display-buffer-alist
             '("\\*\\(Flymake\\|flymake\\|Warnings\\|Messages\\|Backtrace\\|Process List\\|Async Shell Command\\|Compile-Log\\)\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)
               (dedicated . t)))

;; Bottom: compilation
(add-to-list 'display-buffer-alist
             '("\\*[Cc]ompil"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)
               (dedicated . t)))

;; Bottom: eshell / shell
(add-to-list 'display-buffer-alist
             '("\\*\\(e?shell\\|vterm\\|eat\\|term\\)\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (slot . 1)
               (window-height . 0.30)
               (dedicated . t)))

;; ── Speedbar as a side window (Emacs 31) ──

(use-package speedbar
  :ensure nil
  :custom
  (speedbar-use-images nil)
  (speedbar-show-unknown-files t)
  (speedbar-indentation-width 2)
  (speedbar-update-flag t)
  :config
  ;; Dock speedbar in the left side window instead of a separate frame
  (when (fboundp 'speedbar-window)
    (defun rk/speedbar-toggle ()
      "Toggle speedbar in a left side window."
      (interactive)
      (speedbar-window))))

;; ── Window layout helpers ──

(defun rk/toggle-window-split ()
  "Flip between vertical (side-by-side) and horizontal (stacked) split."
  (interactive)
  (if (= (count-windows) 1)
      (message "Only one window")
    (let* ((this-buf (window-buffer))
           (next-buf (window-buffer (next-window)))
           (this-edges (window-edges))
           (next-edges (window-edges (next-window)))
           (this-second (not (and (<= (car this-edges) (car next-edges))
                                 (<= (cadr this-edges) (cadr next-edges)))))
           (split-fn (if (= (car this-edges) (car (window-edges (next-window))))
                         'split-window-horizontally
                       'split-window-vertically)))
      (delete-other-windows)
      (funcall split-fn)
      (when this-second (other-window 1))
      (set-window-buffer (selected-window) this-buf)
      (when (= (count-windows) 2)
        (set-window-buffer (next-window) next-buf)))))

(defun rk/2-column-layout ()
  "Two equal side-by-side columns."
  (interactive)
  (delete-other-windows)
  (split-window-right)
  (balance-windows))

(defun rk/3-column-layout ()
  "Three equal columns."
  (interactive)
  (delete-other-windows)
  (split-window-right)
  (split-window-right)
  (balance-windows))

(defun rk/2-row-layout ()
  "Two equal rows stacked vertically."
  (interactive)
  (delete-other-windows)
  (split-window-below)
  (balance-windows))

(defvar rk/zoom--saved-config nil
  "Saved window configuration for `rk/zoom-toggle'.")

(defun rk/zoom-toggle ()
  "Maximize current window, or restore from saved configuration."
  (interactive)
  (if (and rk/zoom--saved-config (one-window-p))
      (progn
        (set-window-configuration rk/zoom--saved-config)
        (setq rk/zoom--saved-config nil)
        (message "Restored window layout"))
    (setq rk/zoom--saved-config (current-window-configuration))
    (delete-other-windows)
    (message "Zoomed — press again to restore")))

(provide 'core-windows)
;;; core-windows.el ends here
