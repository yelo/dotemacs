;; eshell — Emacs's built-in shell
(use-package eshell
  :ensure nil
  :custom
  ;; Use fish for external/visual commands routed through a real terminal.
  (explicit-shell-file-name "/opt/homebrew/bin/fish")
  ;; Prefer external commands over Lisp equivalents (e.g. `ls`, `cp`).
  (eshell-prefer-lisp-functions nil)
  ;; Destroy the buffer when the process exits.
  (eshell-destroy-buffer-when-process-dies t)
  ;; Keep a large history and avoid duplicates.
  (eshell-history-size 10000)
  (eshell-hist-ignoredups t)
  ;; Scroll to the bottom on new output.
  (eshell-scroll-to-bottom-on-input 'all)
  (eshell-scroll-to-bottom-on-output 'all))

;; eat — fast terminal emulator; integrates with eshell for visual commands
(use-package eat
  :ensure t
  :custom
  ;; Use fish as the shell inside eat buffers.
  (eat-term-shell-command "/opt/homebrew/bin/fish")
  ;; Restore the window layout when eat exits.
  (eat-kill-buffer-on-exit t)
  :config
  ;; Route eshell visual commands (ssh, htop, …) through eat instead of term.
  (eat-eshell-mode 1)
  ;; Keep the cursor style in sync with the running program.
  (eat-eshell-visual-command-mode 1))
