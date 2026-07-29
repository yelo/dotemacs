;;; core-windows.el --- Window management, layouts, popups -*- lexical-binding: t; -*-

;; ── Built-in window history (undo/redo configurations) ──

(winner-mode 1)

;; ── Help / describe buffers open on the right side ──

(add-to-list 'display-buffer-alist
             '("\\*\\(Help\\*\\(?:<.+>\\)?\\|Apropos\\*\\(?:<.+>\\)?\\|info\\*\\(?:<.+>\\)?\\|Man .+\\*\\)"
               (display-buffer-in-side-window)
               (side . right)
               (window-width . 0.40)
               (slot . 0)))

(add-to-list 'display-buffer-alist
             '("\\*[Dd]ashboard\\*"
               (display-buffer-same-window)))

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

;; ── Popper popup management ──

(use-package popper
  :ensure t
  :bind (:map popper-mode-map
              ("C-`"   . popper-toggle-latest)
              ("M-`"   . popper-cycle)
              ("C-M-`" . popper-toggle-type))
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*"
     "\\*Warnings\\*"
     "\\*Backtrace\\*"
     "\\*Compil"
     "\\*compil"
     "Output\\*$"
     "\\*Async Shell Command\\*"
     "\\*eldoc\\*"
     "\\*Flycheck\\*"
     "\\*Echo Area\\*"
     "\\*Process List\\*"))
  (popper-group-function #'popper-group-by-directory)
  (popper-display-function #'popper-select-popup-at-bottom)
  :init
  (popper-mode 1)
  (popper-echo-mode -1))

(provide 'core-windows)
;;; core-windows.el ends here
