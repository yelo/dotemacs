;;; lang-csharp.el --- C# / .NET bindings -*- lexical-binding: t; -*-

;; Requires: .NET SDK on $PATH.
;; OmniSharp Roslyn: auto-downloads via M-x lsp-install-server RET cs RET
;; netcoredbg:       auto-downloads on first M-x dap-debug (needs libxml2 Emacs)
;; csharpier:        optional format-on-save — dotnet tool install -g csharpier

;; ── LSP: OmniSharp Roslyn via lsp-mode ──
(with-eval-after-load 'lsp-mode
  ;; lsp-csharp is bundled with lsp-mode; enable it for csharp-ts-mode.
  (require 'lsp-csharp))

(add-hook 'csharp-ts-mode-hook #'lsp-deferred)

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

;; ── Debugging: dap-mode + netcoredbg (auto-downloads on first use) ──
(use-package dap-mode
  :ensure t
  :after lsp-mode
  :commands (dap-debug dap-breakpoint-toggle)
  :config
  (require 'dap-netcore)
  (dap-auto-configure-mode 1))

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
  "d" '(dap-debug                    :which-key "dap debug")
  "D" '(dap-breakpoint-toggle        :which-key "toggle breakpoint")
  "a" '(lsp-execute-code-action      :which-key "code action")
  "R" '(lsp-rename                   :which-key "rename")
  "." '(lsp-find-definition          :which-key "go to definition")
  "?" '(lsp-find-references          :which-key "find references"))
