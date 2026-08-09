;;; os-macos.el --- macOS-specific settings -*- lexical-binding: t; -*-

;; Command key is Super (Cmd+C/V/X/A/Z work as macOS copy/paste)
(setq ns-command-modifier 'super)
;; Left Option (alt) is Meta (M-x, etc.)
(setq ns-alternate-modifier 'meta)
(setq mac-option-modifier 'meta)
;; Right Option retained as AltGr so unicode hex / composed chars work
(setq mac-right-option-modifier 'none)

(provide 'os-macos)
;;; os-macos.el ends here
