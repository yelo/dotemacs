;;; os-macos.el --- macOS-specific settings -*- lexical-binding: t; -*-

;; Extend exec-path with directories that GUI Emacs doesn't inherit from the
;; shell.  Rather than hardcoding locations, ask macOS itself: `path_helper'
;; builds PATH from /etc/paths and /etc/paths.d, which is exactly what a login
;; shell uses.  Installers register themselves there (the .NET SDK ships
;; /etc/paths.d/dotnet), so honouring that ordering means Emacs resolves the
;; same tools, in the same precedence, as the terminal does.
(defun rk/macos--system-path ()
  "Return the login PATH entries macOS defines, or nil.
Uses `path_helper' so /etc/paths and /etc/paths.d ordering is preserved."
  (when (file-executable-p "/usr/libexec/path_helper")
    (let ((out (with-output-to-string
                 (with-current-buffer standard-output
                   (call-process "/usr/libexec/path_helper" nil t nil "-s")))))
      (when (string-match "PATH=\"\\([^\"]*\\)\"" out)
        (mapcar #'expand-file-name
                (split-string (match-string 1 out) ":" t))))))

(let ((dirs (rk/macos--system-path)))
  ;; Preserve `path_helper' ordering: walk backwards so each entry is pushed
  ;; ahead of the ones already added, leaving inherited entries last.
  (dolist (dir (reverse dirs))
    (when (file-directory-p dir)
      (setq exec-path (cons dir (delete dir exec-path)))))
  (when dirs
    (setenv "PATH" (string-join (delete-dups
                                 (append (seq-filter #'file-directory-p dirs)
                                         (split-string (or (getenv "PATH") "") ":" t)))
                                ":"))))

;; C# language servers launched via dotnet tooling may require DOTNET_ROOT to
;; find the SDK when Emacs is launched as a GUI app without shell env.  Derive
;; it from whichever `dotnet' PATH actually resolves to instead of guessing a
;; location: a stale or hardcoded DOTNET_ROOT points the host at a single SDK
;; install and breaks projects whose global.json pins a version living in a
;; different one.
;;
;; DOTNET_ROOT must name the directory holding the real `dotnet' host next to
;; its `sdk' directory, NOT a `bin/' shim dir -- Homebrew's `bin/dotnet' is a
;; wrapper script that hardcodes its own keg-only root, so we only accept a
;; directory that genuinely looks like a .NET installation.
(defun rk/dotnet-root-p (dir)
  "Return non-nil if DIR looks like a real .NET installation root."
  (and dir (stringp dir)
       (file-executable-p (expand-file-name "dotnet" dir))
       (file-directory-p (expand-file-name "sdk" dir))))

(defun rk/macos--dotnet-root ()
  "Return the installation root of the `dotnet' found on `exec-path', or nil."
  (when-let* ((dotnet (executable-find "dotnet"))
              (dir (file-name-directory (file-truename dotnet))))
    (and (rk/dotnet-root-p dir) (directory-file-name dir))))

;; Prefer the root belonging to the `dotnet' we will actually run; only fall
;; back to an inherited DOTNET_ROOT when it still points at a usable install.
(when-let* ((dotnet-root (or (rk/macos--dotnet-root)
                             (let ((env (getenv "DOTNET_ROOT")))
                               (and (rk/dotnet-root-p env) env)))))
  (setenv "DOTNET_ROOT" dotnet-root)
  ;; Global-tool apphosts use this to avoid mistaking Homebrew's bin/dotnet
  ;; shim for the real host beside the SDK.
  (setenv "DOTNET_HOST_PATH" (expand-file-name "dotnet" dotnet-root)))

;; Command key is Super (Cmd+C/V/X/A/Z work as macOS copy/paste)
(setq ns-command-modifier 'super)
;; Left Option (alt) is Meta (M-x, etc.)
(setq ns-alternate-modifier 'meta)
(setq mac-option-modifier 'meta)
;; Right Option retained as AltGr so unicode hex / composed chars work
(setq mac-right-option-modifier 'none)

(provide 'os-macos)
;;; os-macos.el ends here
