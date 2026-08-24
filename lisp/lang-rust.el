;;; lang-rust.el --- Rust bindings -*- lexical-binding: t; -*-

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode) . ("rust-analyzer"))))

(add-hook 'rust-mode-hook #'eglot-ensure)
(add-hook 'rust-ts-mode-hook #'eglot-ensure)

(provide 'lang-rust)
;;; lang-rust.el ends here
