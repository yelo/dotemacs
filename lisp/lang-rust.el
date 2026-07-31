;;; lang-rust.el --- Rust bindings -*- lexical-binding: t; -*-

(use-package rustic
  :ensure t
  :hook (rustic-mode . lsp-deferred)
  :init
  (setq rustic-lsp-client 'lsp-mode)
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
    "d" '(lsp-find-definition :which-key "go to definition")
    "D" '(lsp-find-references :which-key "find references")
    "R" '(lsp-rename :which-key "rename")
    "a" '(lsp-execute-code-action :which-key "code action")
    "=" '(rustic-cargo-outdated :which-key "cargo outdated")))
