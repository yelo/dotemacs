;;; core-windows.el --- Window management, layouts, popups -*- lexical-binding: t; -*-

;; ── Built-in window history (undo/redo configurations) ──

(winner-mode 1)

;; ── Prefer not to switch to another buffer when closing a popup window ──
(setq quit-restore-window-no-switch t)

;; ── Kill (not bury) buffers shown in our dedicated Help/Info/xref side
;;    windows when quit, so they don't pile up in the buffer list ──
(setq quit-window-kill-buffer
      '(help-mode apropos-mode Info-mode Man-mode xref--xref-buffer-mode))

;; ── Fast window navigation with Shift+arrow keys ──
(windmove-default-keybindings 'shift)

;; ── Auto-focus docked *Help* windows instead of requiring C-x o ──
(setq help-window-select t)

;; ── Auto-scroll compile/flymake output continuously ──
(setq compilation-scroll-output t)

;; ── Emacs 31: prefer vertical (stacked) ad-hoc splits ──
;; Most of this frame's real estate is already claimed by side windows
;; (see `display-buffer-alist' below), so keep the remaining editing area
;; splitting top/bottom by default rather than the new 'longest' default,
;; which would favor side-by-side splits on our normally-landscape frames.
(setq split-window-preferred-direction 'vertical)

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
;; File opens from Speedbar are routed to the last non-side editing window
;; in the same frame to avoid jarring target-window changes.

(require 'speedbar)

(setq speedbar-use-images nil
      speedbar-prefer-window t
      speedbar-show-unknown-files t
      speedbar-indentation-width 2
      speedbar-update-flag t)

(defun rk/speedbar--editing-window-p (window &optional frame)
  "Return non-nil if WINDOW is an eligible editing window (not a minibuffer, side, or dedicated window).
If FRAME is provided, also check that WINDOW is in FRAME."
  (and (window-live-p window)
       (or (not frame) (eq (window-frame window) frame))
       (not (window-minibuffer-p window))
       (not (window-parameter window 'window-side))
       (not (window-dedicated-p window))))

(defun rk/speedbar--remember-editing-window (&optional frame)
  "Remember the selected eligible editing window for FRAME."
  (let* ((target-frame (or frame (selected-frame)))
         (window (frame-selected-window target-frame)))
    (when (rk/speedbar--editing-window-p window target-frame)
      (set-frame-parameter target-frame 'rk/speedbar-last-edit-window window))))

(defun rk/speedbar--target-editing-window (frame)
  "Return the best deterministic Speedbar target window in FRAME.

Strategy: Use the last-remembered editing window if still valid, otherwise find
the first available eligible editing window. This avoids jarring window switches."
  (let ((remembered (frame-parameter frame 'rk/speedbar-last-edit-window)))
    (if (rk/speedbar--editing-window-p remembered frame)
        remembered
      (seq-find (lambda (w) (rk/speedbar--editing-window-p w frame))
                (window-list frame 'nomini frame)))))

(defun rk/speedbar-find-file-in-frame-deterministic (original file)
  "Open FILE in a deterministic editing window for the current Speedbar frame."
  (let* ((target-frame (or (and (frame-live-p dframe-attached-frame)
                                dframe-attached-frame)
                           (selected-frame)))
         (target-window (rk/speedbar--target-editing-window target-frame)))
    (if (window-live-p target-window)
        (let ((buffer (find-file-noselect file)))
          (select-frame-set-input-focus target-frame)
          (select-window target-window)
          (switch-to-buffer buffer)
          (set-frame-parameter target-frame 'rk/speedbar-last-edit-window
                               target-window))
      (funcall original file))))

(add-hook 'window-selection-change-functions
          #'rk/speedbar--remember-editing-window)
(rk/speedbar--remember-editing-window (selected-frame))
(advice-add 'speedbar-find-file-in-frame :around
            #'rk/speedbar-find-file-in-frame-deterministic)

(defun rk/speedbar-toggle ()
  "Toggle Speedbar in a side window on the current frame."
  (interactive)
  (let ((speedbar-prefer-window t))
    (speedbar-window-mode)))

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
