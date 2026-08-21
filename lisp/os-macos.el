;;; os-macos.el --- macOS-specific settings -*- lexical-binding: t; -*-

;; Extend exec-path with directories that GUI Emacs doesn't inherit from the shell.
(dolist (dir (list (expand-file-name "~/.dotnet/tools")
                   "/opt/homebrew/bin"
                   "/usr/local/bin"))
  (when (file-directory-p dir)
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir ":" (getenv "PATH")))))

;; MSBuild.Locator (used by csharp-ls) requires DOTNET_ROOT to find the SDK
;; when Emacs is launched as a GUI app without the shell environment.
(let ((dotnet-root (seq-find #'file-directory-p
                              '("/usr/local/share/dotnet"
                                "/opt/homebrew/share/dotnet"))))
  (when dotnet-root
    (setenv "DOTNET_ROOT" dotnet-root)))

;; Command key is Super (Cmd+C/V/X/A/Z work as macOS copy/paste)
(setq ns-command-modifier 'super)
;; Left Option (alt) is Meta (M-x, etc.)
(setq ns-alternate-modifier 'meta)
(setq mac-option-modifier 'meta)
;; Right Option retained as AltGr so unicode hex / composed chars work
(setq mac-right-option-modifier 'none)

(provide 'os-macos)
;;; os-macos.el ends here
