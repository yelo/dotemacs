;;; os-macos.el --- macOS-specific settings -*- lexical-binding: t; -*-

;; Command key is Super (Cmd+C/V/X/A/Z work as macOS copy/paste)
(setq ns-command-modifier 'super)
;; Option (alt) key is Meta (M-x, etc.)
(setq ns-alternate-modifier 'meta)
(setq mac-option-modifier 'meta)
(setq mac-right-option-modifier 'meta)

(provide 'os-macos)
;;; os-macos.el ends here
