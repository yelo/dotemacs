;;; lang-csharp.el --- C# / .NET bindings -*- lexical-binding: t; -*-

;; Requires: .NET SDK on $PATH.
;; LSP server: csharp-ls — install with: dotnet tool install --global csharp-ls
;; csharpier: optional format-on-save — dotnet tool install -g csharpier

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((csharp-mode csharp-ts-mode) . ("csharp-ls"))))

(add-hook 'csharp-mode-hook    #'eglot-ensure)
(add-hook 'csharp-ts-mode-hook #'eglot-ensure)

;; ── Formatting: csharpier (optional) ──
(use-package reformatter
  :ensure t
  :config
  (reformatter-define csharpier-format
    :program "dotnet-csharpier"
    :args '("--write-stdout")
    :lighter " CSF"))

(defun rk/csharpier-format-on-save-if-available ()
  "Enable csharpier format-on-save only when dotnet-csharpier is on PATH."
  (when (executable-find "dotnet-csharpier")
    (csharpier-format-on-save-mode 1)))

(add-hook 'csharp-ts-mode-hook #'rk/csharpier-format-on-save-if-available)

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

;; ── SPC m keybindings ──
(rk/lang 'csharp-ts-mode '(csharp-ts-mode-map)
  "b" '(rk/dotnet-build              :which-key "dotnet build")
  "r" '(rk/dotnet-run                :which-key "dotnet run")
  "t" '(rk/dotnet-test               :which-key "dotnet test")
  "f" '(csharpier-format-buffer       :which-key "csharpier format")
  "a" '(eglot-code-actions           :which-key "code action")
  "R" '(eglot-rename                 :which-key "rename")
  "." '(xref-find-definitions        :which-key "go to definition")
  "?" '(xref-find-references         :which-key "find references"))
