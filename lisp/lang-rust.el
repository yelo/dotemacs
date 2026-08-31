;;; lang-rust.el --- Rust bindings -*- lexical-binding: t; -*-

;; LSP server: rust-analyzer (install with `rustup component add rust-analyzer').

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode) . ("rust-analyzer"))))

(add-hook 'rust-mode-hook #'eglot-ensure)
(add-hook 'rust-ts-mode-hook #'eglot-ensure)

(defun rk/rust-cargo (subcommand)
  "Run `cargo SUBCOMMAND' in the current project root via `compile'."
  (interactive
   (list (completing-read "cargo: "
                          '("build" "run" "test" "check" "clippy" "fmt")
                          nil nil nil nil "build")))
  (let ((default-directory
         (or (locate-dominating-file default-directory "Cargo.toml")
             (when-let* ((proj (project-current nil default-directory)))
               (project-root proj))
             default-directory)))
    (compile (format "cargo %s" subcommand))))

(provide 'lang-rust)
;;; lang-rust.el ends here
