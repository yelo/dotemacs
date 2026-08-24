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

;; Cmd+click (s-mouse-1) → go to definition via xref/eglot.
(defun rk/mouse-goto-definition (event)
  "Go to definition of the symbol at mouse EVENT position."
  (interactive "e")
  (mouse-set-point event)
  (xref-find-definitions (xref-backend-identifier-at-point
                          (xref-find-backend))))

(when (key-valid-p "<s-mouse-1>")
  (keymap-global-set "<s-mouse-1>" #'rk/mouse-goto-definition))

(provide 'core-eglot)
;;; core-eglot.el ends here
