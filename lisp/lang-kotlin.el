;;; lang-kotlin.el --- Kotlin / Compose / Gradle (Android) bindings -*- lexical-binding: t; -*-

;; Requires: JDK on $PATH; Android projects ship a ./gradlew wrapper.
;; LSP server: kotlin-lsp (JetBrains, `brew install JetBrains/utils/kotlin-lsp')
;;   or kotlin-language-server (`brew install kotlin-language-server').
;; Grammar: installed on demand — M-x rk/kotlin-install-grammar.

(require 'use-package)
(require 'treesit)

(add-to-list 'treesit-language-source-alist
             '(kotlin "https://github.com/fwcd/tree-sitter-kotlin"))

(defun rk/kotlin-install-grammar ()
  "Install the Kotlin tree-sitter grammar."
  (interactive)
  (treesit-install-language-grammar 'kotlin))

(use-package kotlin-ts-mode
  :ensure t
  :mode ("\\.kts?\\'" . kotlin-ts-mode)
  :hook (kotlin-ts-mode . eglot-ensure))

;; Gradle build scripts: Groovy DSL (.gradle) uses groovy-mode; Kotlin DSL
;; (.gradle.kts) is matched by kotlin-ts-mode above.
(use-package groovy-mode
  :ensure t
  :mode "\\.gradle\\'")

(defun rk/kotlin--eglot-server-command ()
  "Return the first available Kotlin LSP server command."
  (cond
   ((executable-find "kotlin-lsp") '("kotlin-lsp" "--stdio"))
   ((executable-find "kotlin-language-server") '("kotlin-language-server"))
   (t '("kotlin-lsp" "--stdio"))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((kotlin-ts-mode kotlin-mode) . ,(rk/kotlin--eglot-server-command))))

;; ── Gradle helpers ──

(defvar rk/gradle-last-task "assembleDebug"
  "Last Gradle task run via `rk/gradle'.")

(defun rk/gradle--root ()
  "Return the directory containing the Gradle wrapper or settings file."
  (or (locate-dominating-file default-directory "gradlew")
      (locate-dominating-file default-directory "settings.gradle.kts")
      (locate-dominating-file default-directory "settings.gradle")
      (when-let* ((proj (project-current nil default-directory)))
        (project-root proj))
      default-directory))

(defun rk/gradle (task)
  "Run Gradle TASK from the project root, preferring ./gradlew."
  (interactive
   (list (completing-read
          "gradle: "
          '("assembleDebug" "installDebug" "test" "testDebugUnitTest"
            "connectedAndroidTest" "lint" "ktlintCheck" "clean" "build"
            "tasks" "dependencies")
          nil nil nil nil rk/gradle-last-task)))
  (let* ((default-directory (rk/gradle--root))
         (cmd (if (file-executable-p (expand-file-name "gradlew"))
                  "./gradlew"
                "gradle")))
    (setq rk/gradle-last-task task)
    (compile (format "%s %s" cmd task))))

(defmacro rk/gradle--defcommand (name task doc)
  "Define NAME running Gradle TASK with docstring DOC."
  `(defun ,name () ,doc (interactive) (rk/gradle ,task)))

(rk/gradle--defcommand rk/gradle-build "assembleDebug" "Run `assembleDebug'.")
(rk/gradle--defcommand rk/gradle-install "installDebug" "Run `installDebug'.")
(rk/gradle--defcommand rk/gradle-test "testDebugUnitTest" "Run unit tests.")
(rk/gradle--defcommand rk/gradle-clean "clean" "Run `clean'.")

(defvar rk/kotlin-map (make-sparse-keymap)
  "Kotlin / Gradle shortcuts under C-c c.")
(define-key rk/kotlin-map (kbd "b") #'rk/gradle-build)
(define-key rk/kotlin-map (kbd "i") #'rk/gradle-install)
(define-key rk/kotlin-map (kbd "t") #'rk/gradle-test)
(define-key rk/kotlin-map (kbd "c") #'rk/gradle-clean)
(define-key rk/kotlin-map (kbd "!") #'rk/gradle)

(with-eval-after-load 'kotlin-ts-mode
  (define-key kotlin-ts-mode-map (kbd "C-c c") rk/kotlin-map))
(with-eval-after-load 'groovy-mode
  (define-key groovy-mode-map (kbd "C-c c") rk/kotlin-map))

(provide 'lang-kotlin)
;;; lang-kotlin.el ends here
