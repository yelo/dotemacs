;;; lang-csharp.el --- C# / .NET bindings -*- lexical-binding: t; -*-

;; Requires: .NET SDK on $PATH.
;; LSP server: csharp-ls —
;; install with: dotnet tool install --global csharp-ls
;; csharpier: optional format-on-save — dotnet tool install -g csharpier

(require 'eglot)

(defun rk/csharp--eglot-server-command ()
  "Return preferred C# LSP server command for Eglot.
Prefer csharp-ls; fall back to roslyn-language-server when necessary."
  (cond
   ((executable-find "csharp-ls")
    '("csharp-ls" "--features" "metadata-uris"))
   ((file-executable-p (expand-file-name "~/.dotnet/tools/csharp-ls"))
    (list (expand-file-name "~/.dotnet/tools/csharp-ls")
          "--features" "metadata-uris"))
   ((executable-find "roslyn-language-server")
    '("roslyn-language-server" "--stdio"))
   ((file-executable-p (expand-file-name "~/.dotnet/tools/roslyn-language-server"))
    (list (expand-file-name "~/.dotnet/tools/roslyn-language-server") "--stdio"))
   (t
    '("csharp-ls" "--features" "metadata-uris"))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((csharp-mode csharp-ts-mode) . ,(rk/csharp--eglot-server-command))))

;; Prefer tree-sitter mode for .cs files.
(add-to-list 'auto-mode-alist '("\\.cs\\'" . csharp-ts-mode))

(add-hook 'csharp-mode-hook    #'eglot-ensure)
(add-hook 'csharp-ts-mode-hook #'eglot-ensure)

;; ── Hover documentation ──

(defvar-local rk/csharp--hover-cache nil
  "Cached Eglot hover documentation, keyed by buffer tick and position.")

(defun rk/csharp--hover-documentation (position)
  "Return Eglot hover documentation at POSITION, or nil when unavailable."
  (let* ((key (cons (buffer-chars-modified-tick) position))
         (cached (assoc key rk/csharp--hover-cache)))
    (if cached
        (cdr cached)
      (let* ((server (eglot-current-server))
             (params (list :textDocument
                           (list :uri (eglot-path-to-uri buffer-file-name))
                           :position (eglot--pos-to-lsp-position position)))
             (hover
              (condition-case err
                  (eglot--request server :textDocument/hover params
                                  :timeout 1 :cancel-on-input t)
                (jsonrpc-error
                 (message "C# hover request failed: %s"
                          (error-message-string err))
                 nil)))
             (documentation
              (when-let* ((contents (plist-get hover :contents))
                          (text (eglot--format-markup contents))
                          ((not (string-empty-p text))))
                text)))
        (push (cons key documentation) rk/csharp--hover-cache)
        documentation))))

(defun rk/csharp-tooltip-at-mouse (event)
  "Show Eglot documentation for the C# symbol under mouse EVENT.
Return non-nil when a C# tooltip was shown, allowing other tooltip handlers
to handle buffers without Eglot C# documentation."
  (let* ((position (event-end event))
         (window (posn-window position))
         (point (posn-point position)))
    (when (and (windowp window)
               (integer-or-marker-p point)
               (display-graphic-p (window-frame window)))
      (with-current-buffer (window-buffer window)
        (when (and (derived-mode-p 'csharp-mode 'csharp-ts-mode)
                   buffer-file-name
                   (featurep 'eglot)
                   (eglot-managed-p))
          (when-let* ((documentation (rk/csharp--hover-documentation point)))
            (tooltip-show documentation)
            t))))))

(when (display-graphic-p)
  (require 'tooltip)
  (tooltip-mode 1)
  (add-hook 'tooltip-functions #'rk/csharp-tooltip-at-mouse))

;; ── dotnet build/run/test helpers ──
;;
;; Multi-project solutions: every command takes an explicit target
;; (solution or project file).  The target is chosen with completion over
;; the files found below the workspace root, defaults to the last target
;; used in that workspace, and can be pinned per project via
;; `.dir-locals.el':
;;
;;   ((nil . ((rk/dotnet-target . "src/Api/Api.csproj")
;;            (rk/dotnet-extra-args . "-c Debug"))))

(defvar rk/dotnet-target nil
  "Default `dotnet' target (solution or project file) for this buffer.
Relative paths are resolved against the workspace root.  Usually set
from `.dir-locals.el'.")
(put 'rk/dotnet-target 'safe-local-variable #'stringp)

(defvar rk/dotnet-extra-args nil
  "Extra arguments appended to every `dotnet' command in this buffer.
Usually set from `.dir-locals.el'.")
(put 'rk/dotnet-extra-args 'safe-local-variable #'stringp)

(defvar rk/dotnet-project-file-regexp "\\.\\(sln\\|slnx\\|slnf\\|csproj\\|fsproj\\|vbproj\\)\\'"
  "Regexp matching MSBuild solution/project files.")

(defvar rk/dotnet--last-target (make-hash-table :test #'equal)
  "Maps workspace root -> last target used there.")

(defun rk/dotnet--root ()
  "Return the workspace root for dotnet commands.
Prefers the outermost directory containing a solution file, then
project.el's root, then the nearest project file directory."
  (or (rk/dotnet--dominating-dir "\\.\\(sln\\|slnx\\|slnf\\)\\'")
      (when-let* ((proj (project-current nil default-directory)))
        (project-root proj))
      (rk/dotnet--dominating-dir rk/dotnet-project-file-regexp)
      default-directory))

(defun rk/dotnet--dominating-dir (regexp)
  "Return the topmost ancestor directory of `default-directory' holding REGEXP.
Searching upward keeps the highest match so a solution above nested
projects wins.  Return nil when nothing matches."
  (let ((dir default-directory) found)
    (while dir
      (when (directory-files dir nil regexp t)
        (setq found dir))
      (let ((parent (file-name-directory (directory-file-name dir))))
        (setq dir (unless (equal parent dir) parent))))
    (and found (file-name-as-directory found))))

(defun rk/dotnet--targets (root)
  "Return solution/project files under ROOT, relative to it."
  (let (files)
    (dolist (f (ignore-errors
                 (directory-files-recursively
                  root rk/dotnet-project-file-regexp nil
                  (lambda (dir)
                    (not (member (file-name-nondirectory dir)
                                 '("bin" "obj" ".git" "node_modules")))))))
      (push (file-relative-name f root) files))
    (sort files #'string<)))

(defun rk/dotnet--default-target (root)
  "Return the preferred default target for ROOT, or nil."
  (or (when (and rk/dotnet-target (not (string-empty-p rk/dotnet-target)))
        (if (file-name-absolute-p rk/dotnet-target)
            (file-relative-name rk/dotnet-target root)
          rk/dotnet-target))
      (gethash root rk/dotnet--last-target)
      (car (rk/dotnet--targets root))))

(defun rk/dotnet--read-target (root verb)
  "Read a target for VERB below ROOT with completion."
  (let* ((targets (rk/dotnet--targets root))
         (default (rk/dotnet--default-target root))
         (choice (completing-read
                  (format "dotnet %s target (empty = %s): " verb
                          (abbreviate-file-name root))
                  targets nil nil default)))
    (if (string-empty-p choice) nil choice)))

(defvar rk/dotnet-project-flag-verbs '("run" "watch" "watch run")
  "Subcommands that take the project via `--project' instead of positionally.")

(defun rk/dotnet--command (verb target args)
  "Build the shell command string for VERB on TARGET with ARGS."
  (string-join
   (delq nil (list "dotnet" verb
                   (when target
                     (if (member verb rk/dotnet-project-flag-verbs)
                         (concat "--project " (shell-quote-argument target))
                       (shell-quote-argument target)))
                   (and args (not (string-empty-p args)) args)))
   " "))

(defun rk/dotnet--compile (verb &optional arg)
  "Run `dotnet VERB' on a target chosen interactively.
With one prefix ARG also prompt for extra arguments; with two prefix
args, edit the whole command line before running it."
  (let* ((root (rk/dotnet--root))
         (target (rk/dotnet--read-target root verb))
         (args (if (and arg (>= (prefix-numeric-value arg) 4))
                   (read-string (format "dotnet %s args: " verb)
                                (or rk/dotnet-extra-args ""))
                 rk/dotnet-extra-args))
         (command (rk/dotnet--command verb target args))
         (default-directory root))
    (when target (puthash root target rk/dotnet--last-target))
    (compile (if (and arg (>= (prefix-numeric-value arg) 16))
                 (read-string "Compile command: " command)
               command))))

(defmacro rk/dotnet--defcommand (name verb docstring)
  "Define interactive command NAME running `dotnet VERB'."
  (declare (indent defun))
  `(defun ,name (&optional arg)
     ,(concat docstring "\n\nThe target is read with completion (empty input runs at
the workspace root).  With \\[universal-argument] also prompt for extra
arguments, with \\[universal-argument] \\[universal-argument] edit the
full command line.")
     (interactive "P")
     (rk/dotnet--compile ,verb arg)))

(rk/dotnet--defcommand rk/dotnet-build "build" "Run `dotnet build' on a solution or project.")
(rk/dotnet--defcommand rk/dotnet-run "run" "Run `dotnet run' on a project.")
(rk/dotnet--defcommand rk/dotnet-test "test" "Run `dotnet test' on a solution or project.")
(rk/dotnet--defcommand rk/dotnet-clean "clean" "Run `dotnet clean' on a solution or project.")
(rk/dotnet--defcommand rk/dotnet-restore "restore" "Run `dotnet restore' on a solution or project.")
(rk/dotnet--defcommand rk/dotnet-watch "watch run" "Run `dotnet watch run' on a project.")

(defun rk/dotnet-command (verb &optional arg)
  "Run an arbitrary `dotnet' VERB (e.g. \"publish\", \"format\") on a target."
  (interactive "sdotnet subcommand: \nP")
  (rk/dotnet--compile verb arg))

;; ── Keybindings ──
;; Under a `C-c c' prefix so C# buffers don't shadow the global `C-c b'
;; (buffers), `C-c r' (recent files) and `C-c t' (theme toggle) bindings.
(defvar rk/csharp-map (make-sparse-keymap)
  "C# / .NET shortcuts under C-c c.")
(define-key rk/csharp-map (kbd "b") #'rk/dotnet-build)
(define-key rk/csharp-map (kbd "r") #'rk/dotnet-run)
(define-key rk/csharp-map (kbd "t") #'rk/dotnet-test)
(define-key rk/csharp-map (kbd "w") #'rk/dotnet-watch)
(define-key rk/csharp-map (kbd "c") #'rk/dotnet-clean)
(define-key rk/csharp-map (kbd "n") #'rk/dotnet-restore)
(define-key rk/csharp-map (kbd "!") #'rk/dotnet-command)

(with-eval-after-load 'csharp-mode
  (when (boundp 'csharp-mode-map)
    (define-key csharp-mode-map (kbd "C-c c") rk/csharp-map))
  (when (boundp 'csharp-ts-mode-map)
    (define-key csharp-ts-mode-map (kbd "C-c c") rk/csharp-map)))

(provide 'lang-csharp)
;;; lang-csharp.el ends here
