;;; os-macos.el --- macOS-specific settings -*- lexical-binding: t; -*-

;; Extend exec-path with directories that GUI Emacs doesn't inherit from the shell.
(dolist (dir (list (expand-file-name "~/.dotnet/tools")
                   "/opt/homebrew/bin"
                   "/usr/local/bin"))
  (when (file-directory-p dir)
    (add-to-list 'exec-path dir)
    (setenv "PATH" (concat dir ":" (getenv "PATH")))))

;; C# language servers launched via dotnet tooling may require DOTNET_ROOT
;; to find the SDK when Emacs is launched as a GUI app without shell env.
;; DOTNET_ROOT must point at the directory containing the real `dotnet` host
;; (e.g. .../libexec), NOT a `bin/` shim dir -- Homebrew's `bin/dotnet` is a
;; wrapper script that only sets DOTNET_ROOT for its own child process, so
;; naively deriving the root from `executable-find` would pick the wrong dir.
(defun rk/valid-dotnet-root-p (dir)
  "Return non-nil if DIR contains a real dotnet host binary."
  (and dir (stringp dir)
       (file-executable-p (expand-file-name "dotnet" dir))))

(unless (rk/valid-dotnet-root-p (getenv "DOTNET_ROOT"))
  (when-let* ((dotnet-root (seq-find #'rk/valid-dotnet-root-p
                                      '("/opt/homebrew/opt/dotnet/libexec"
                                        "/usr/local/opt/dotnet/libexec"
                                        "/usr/local/share/dotnet"
                                        "/opt/homebrew/share/dotnet"))))
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
