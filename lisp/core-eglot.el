;;; core-eglot.el --- Eglot configuration -*- lexical-binding: t; -*-

;; Global eglot settings only. Per-language server programs and eglot-ensure
;; hooks live in the respective lang-*.el modules.
(with-eval-after-load 'eglot
  ;; Use markdown-ts-mode to render hover documentation.
  (setq eglot-doc-markdown-mode 'markdown-ts-view-mode)
  ;; Inline code-action hints can be noisy with some language servers.
  (setq eglot-code-action-indications nil)
  ;; Keep enough protocol logs for troubleshooting.
  (setq eglot-events-buffer-config '(:size 2000000 :format full)))

(provide 'core-eglot)
;;; core-eglot.el ends here
