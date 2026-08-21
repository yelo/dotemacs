;;; lang-rust.el --- Rust bindings -*- lexical-binding: t; -*-

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode rustic-mode) . ("rust-analyzer"))))

(use-package rustic
  :ensure t
  :hook (rustic-mode . eglot-ensure)
  :init
  ;; Use flymake for diagnostics (replaces flycheck-rust)
  (setq rustic-flycheck-setup-mode-line-p nil)
  :config
  (rk/lang 'rustic '(rust-mode-map rustic-mode-map)
    "b" '(rustic-cargo-build :which-key "cargo build")
    "c" '(rustic-cargo-check :which-key "cargo check")
    "r" '(rustic-cargo-run :which-key "cargo run")
    "t" '(rustic-cargo-test :which-key "cargo test")
    "f" '(rustic-cargo-fmt :which-key "cargo fmt")
    "l" '(rustic-cargo-clippy :which-key "cargo clippy")
    "d" '(xref-find-definitions :which-key "go to definition")
    "D" '(xref-find-references :which-key "find references")
    "R" '(eglot-rename :which-key "rename")
    "a" '(eglot-code-actions :which-key "code action")
    "=" '(rustic-cargo-outdated :which-key "cargo outdated")))
