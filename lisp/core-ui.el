;;; core-ui.el --- UI defaults -*- lexical-binding: t; -*-

;; ---- Fonts ----
;; Single source of truth for the UI font: both the frame alists (used when new
;; frames are created, including the very first one) and the `default' /
;; `fixed-pitch' faces are derived from these two constants.

(defconst rk/font-family "Iosevka Nerd Font"
  "Font family used for all fixed-pitch UI faces.")

(defconst rk/font-size 14
  "Font size in points for `rk/font-family'.")

(defun rk/font-available-p (family &optional frame)
  "Return non-nil if FAMILY is installed on FRAME (or the selected frame).
Always nil for non-graphical frames, since font queries are meaningless
there (notably the placeholder frame present during daemon startup)."
  (and (display-graphic-p frame)
       (member family (font-family-list frame))
       t))

(defun rk/apply-font-settings (&optional frame)
  "Apply `rk/font-family' to frame alists and FRAME's faces.
Does nothing when the font is not installed, so Emacs still starts
cleanly on machines without it. Also does nothing for non-graphical
frames (e.g. the placeholder frame under `emacs --daemon', or a
`-nw' client frame), since font settings do not apply to them; the
frame alists still carry the spec so later graphical frames pick it
up, and `rk/apply-font-settings' is re-run per new frame via
`after-make-frame-functions' to cover daemon clients."
  (when (rk/font-available-p rk/font-family frame)
    (let ((spec (format "%s-%d" rk/font-family rk/font-size)))
      (add-to-list 'default-frame-alist `(font . ,spec))
      (add-to-list 'initial-frame-alist `(font . ,spec)))
    (dolist (face '(default fixed-pitch))
      (set-face-attribute face frame
                          :family rk/font-family
                          :height (* rk/font-size 10)
                          :weight 'regular))))

(rk/apply-font-settings)
(add-hook 'after-make-frame-functions #'rk/apply-font-settings)

(defun rk/apply-ui-face-tweaks ()
  "Apply small readability tweaks after theme load.
Keeps the theme's `hl-line' background (so the current line stays
visible) while removing the underline/overline/box artifacts that
some themes add on top of it."
  (require 'hl-line)
  (when (facep 'hl-line)
    (set-face-attribute 'hl-line nil
                        :underline nil
                        :overline nil
                        :box nil
                        :extend t)))

;; ---- Theme toggle ----
(defun rk/toggle-foxglove-theme ()
  "Toggle between the Foxglove light and dark themes."
  (interactive)
  (let ((current (car custom-enabled-themes)))
    (mapc #'disable-theme custom-enabled-themes)
    (if (eq current 'foxglove)
        (progn
          (load-theme 'foxglove-dark t)
          (message "Switched to Foxglove dark"))
      (load-theme 'foxglove t)
      (message "Switched to Foxglove light"))
    (rk/apply-ui-face-tweaks)))

;; `:vc' installs Foxglove and its missing Modus Themes dependency. Load it
;; here, not from `emacs-startup-hook', to theme the first frame.
(require 'use-package)
(use-package foxglove-themes
  :vc (:url "https://gitlab.com/vegasharmon/foxglove-themes")
  :demand t)

(load-theme 'foxglove t)
(rk/apply-ui-face-tweaks)

(provide 'core-ui)
;;; core-ui.el ends here
