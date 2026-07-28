;;; os-macos.el --- macOS-specific settings -*- lexical-binding: t; -*-

;; Font
(set-frame-font "Iosevka NFM 14")

;; Command key is Super (Cmd+C/V/X/A/Z work as macOS copy/paste)
(setq ns-command-modifier 'super)
;; Option (alt) key is Meta (M-x, etc.)
(setq ns-alternate-modifier 'meta)
(setq mac-option-modifier 'meta)
(setq mac-right-option-modifier 'meta)
