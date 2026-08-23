;;; core-modeline.el --- Mode-line (statusbar) appearance -*- lexical-binding: t; -*-

;; A segmented, vanilla `mode-line-format' tuned to complement the built-in
;; `modus-operandi-tinted' theme (see `core-ui.el'). No external packages: everything here
;; is built from `format-mode-line', `propertize', and standard mode-line
;; constructs. Nerd Font glyphs are used for icons in graphical frames only;
;; terminal frames fall back to plain text/unicode so nothing looks broken
;; without the font (see `core-tty.el' for the equivalent GUI/TTY split).

(column-number-mode 1)
(line-number-mode 1)

;;; Faces

(defface rk/modeline-status-modified
  '((t :inherit warning))
  "Face for the mode-line buffer-status icon when the buffer is modified."
  :group 'mode-line-faces)

(defface rk/modeline-status-readonly
  '((t :inherit error))
  "Face for the mode-line buffer-status icon when the buffer is read-only."
  :group 'mode-line-faces)

(defface rk/modeline-status-saved
  '((t :inherit shadow))
  "Face for the mode-line buffer-status icon when the buffer is unmodified."
  :group 'mode-line-faces)

(defface rk/modeline-vc-branch
  '((t :inherit shadow :weight semi-bold))
  "Face for the VC branch segment in the mode-line."
  :group 'mode-line-faces)

(defface rk/modeline-mode-name
  '((t :inherit shadow))
  "Face for the major-mode name segment in the mode-line."
  :group 'mode-line-faces)

;;; Segments

(defun rk/modeline--glyph (icon fallback)
  "Return ICON in graphical frames with a Nerd Font, else FALLBACK."
  (if (display-graphic-p) icon fallback))

(defun rk/modeline-buffer-status ()
  "Small icon reflecting modified / read-only / saved buffer state."
  (cond
   (buffer-read-only
    (propertize (rk/modeline--glyph "\uf023" "RO")
                'face 'rk/modeline-status-readonly
                'help-echo "Buffer is read-only"))
   ((buffer-modified-p)
    (propertize (rk/modeline--glyph "\uf0c7" "*")
                'face 'rk/modeline-status-modified
                'help-echo "Buffer has unsaved changes"))
   (t
    (propertize (rk/modeline--glyph "\uf00c" "-")
                'face 'rk/modeline-status-saved
                'help-echo "Buffer is saved"))))

(defun rk/modeline-vc-branch ()
  "VC branch segment, empty when the buffer is not version-controlled."
  (when (and vc-mode buffer-file-name)
    (let ((branch (string-trim
                   (substring-no-properties vc-mode
                                             (+ (if (eq (vc-backend buffer-file-name) 'Git) 4 1) 1)))))
      (propertize (format "%s %s" (rk/modeline--glyph "\ue0a0" "@") branch)
                  'face 'rk/modeline-vc-branch
                  'help-echo (format "VC branch: %s" branch)))))

(defun rk/modeline-mode-name ()
  "Simplified major-mode name (minor-mode lighters are handled separately)."
  (propertize (format-mode-line mode-name) 'face 'rk/modeline-mode-name))

(defun rk/modeline-position ()
  "Compact line:column and buffer-percentage position segment."
  (format-mode-line
   '("%l:%c " (-3 "%p"))))

;;; Assembly

(setq-default mode-line-format
              '((:eval (rk/modeline-buffer-status))
                " "
                mode-line-buffer-identification
                (:eval (when-let* ((vc (rk/modeline-vc-branch))) (concat "  " vc)))
                mode-line-format-right-align
                (:eval (rk/modeline-mode-name))
                "  "
                mode-line-misc-info
                (:eval (rk/modeline-position))))

(provide 'core-modeline)
;;; core-modeline.el ends here
