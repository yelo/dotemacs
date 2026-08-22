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

(setq display-buffer-alist
      (append
       '(("\\*[Dd]ashboard\\*"
          (display-buffer-same-window))
         ("\\*\\(Help\\|Apropos\\|info\\|Man .*\\)\\*"
          (display-buffer-in-side-window)
          (side . right)
          (slot . 0)
          (window-width . 0.38)
          (dedicated . t))
         ("\\*\\(xref\\|eldoc\\)\\*"
          (display-buffer-in-side-window)
          (side . right)
          (slot . 1)
          (window-width . 0.38)
          (dedicated . t))
         ("\\(\\*[Cc]ompil\\|\\*\\(Flymake\\|flymake\\|Warnings\\|Messages\\|Backtrace\\|Process List\\|Async Shell Command\\|Compile-Log\\)\\*\\)"
          (display-buffer-in-side-window)
          (side . bottom)
          (slot . 0)
          (window-height . 0.25)
          (dedicated . t))
         ("\\*\\(e?shell\\|term\\)\\*"
          (display-buffer-in-side-window)
          (side . bottom)
          (slot . 1)
          (window-height . 0.30)
          (dedicated . t)))
       display-buffer-alist))

;; ── Speedbar as a side window (Emacs 31) ──

(require 'speedbar)

(setq speedbar-use-images nil
      speedbar-show-unknown-files t
      speedbar-indentation-width 2
      speedbar-update-flag t)

(defun rk/speedbar-open-with-mouse (_event)
  "Open or follow the item clicked in speedbar."
  (interactive "e")
  (mouse-set-point last-input-event)
  (speedbar-edit-line))

(defun rk/speedbar-sync-font-with-ui ()
  "Match speedbar faces to the current default UI font."
  (when (display-graphic-p)
    (let ((family (face-attribute 'default :family nil t))
          (height (face-attribute 'default :height nil t))
          (weight (face-attribute 'default :weight nil t)))
      (dolist (face '(speedbar-face
                      speedbar-button-face
                      speedbar-directory-face
                      speedbar-file-face
                      speedbar-highlight-face
                      speedbar-selected-face
                      speedbar-separator-face
                      speedbar-tag-face))
        (when (facep face)
          (set-face-attribute face nil
                              :family family
                              :height height
                              :weight weight))))))

(defun rk/speedbar-mode-setup ()
  "Apply local speedbar behavior customizations."
  (rk/speedbar-sync-font-with-ui)
  (local-set-key [mouse-1] #'rk/speedbar-open-with-mouse))

(add-hook 'speedbar-mode-hook #'rk/speedbar-mode-setup)

;; Dock speedbar in the left side window instead of a separate frame.
(defun rk/speedbar-toggle ()
  "Toggle speedbar in a left side window."
  (interactive)
  (speedbar-window))

;; ── Window layout helpers ──

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
