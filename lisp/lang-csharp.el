;;; lang-csharp.el --- C# / .NET bindings -*- lexical-binding: t; -*-

;; Requires: .NET SDK on $PATH.
;; LSP server: roslyn-language-server (csharp-roslyn) —
;; install with: dotnet tool install --global roslyn-language-server --prerelease
;; csharpier: optional format-on-save — dotnet tool install -g csharpier

(defun rk/csharp--eglot-server-command ()
  "Return preferred C# LSP server command for Eglot.
Prefer roslyn-language-server; fallback to csharp-ls if Roslyn isn't installed yet."
  (cond
   ((executable-find "roslyn-language-server")
    '("roslyn-language-server" "--stdio"))
   ((file-executable-p (expand-file-name "~/.dotnet/tools/roslyn-language-server"))
    (list (expand-file-name "~/.dotnet/tools/roslyn-language-server") "--stdio"))
   ((executable-find "csharp-ls")
    '("csharp-ls"))
   ((file-executable-p (expand-file-name "~/.dotnet/tools/csharp-ls"))
    (list (expand-file-name "~/.dotnet/tools/csharp-ls")))
   (t
    '("roslyn-language-server" "--stdio"))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((csharp-mode csharp-ts-mode) . ,(rk/csharp--eglot-server-command))))

;; Prefer tree-sitter mode for .cs files.
(add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-ts-mode))

(add-hook 'csharp-mode-hook    #'eglot-ensure)
(add-hook 'csharp-ts-mode-hook #'eglot-ensure)

;; ── dotnet build/run/test helpers ──
(defun rk/dotnet--project-root ()
  "Return the project root (nearest .sln or .csproj ancestor, else project.el root)."
  (or (locate-dominating-file default-directory
                               (lambda (dir)
                                 (directory-files dir nil "\\.\\(sln\\|csproj\\)$")))
      (when-let* ((proj (project-current nil default-directory)))
        (project-root proj))
      default-directory))

(defun rk/dotnet-build ()
  "Run `dotnet build` in the project root."
  (interactive)
  (let ((default-directory (rk/dotnet--project-root)))
    (compile "dotnet build")))

(defun rk/dotnet-run ()
  "Run `dotnet run` in the project root."
  (interactive)
  (let ((default-directory (rk/dotnet--project-root)))
    (compile "dotnet run")))

(defun rk/dotnet-test ()
  "Run `dotnet test` in the project root."
  (interactive)
  (let ((default-directory (rk/dotnet--project-root)))
    (compile "dotnet test")))

(with-eval-after-load 'csharp-mode
  (when (boundp 'csharp-mode-map)
    (define-key csharp-mode-map (kbd "C-c b") #'rk/dotnet-build)
    (define-key csharp-mode-map (kbd "C-c r") #'rk/dotnet-run)
    (define-key csharp-mode-map (kbd "C-c t") #'rk/dotnet-test))
  (when (boundp 'csharp-ts-mode-map)
    (define-key csharp-ts-mode-map (kbd "C-c b") #'rk/dotnet-build)
    (define-key csharp-ts-mode-map (kbd "C-c r") #'rk/dotnet-run)
    (define-key csharp-ts-mode-map (kbd "C-c t") #'rk/dotnet-test)))

(provide 'lang-csharp)
;;; lang-csharp.el ends here
