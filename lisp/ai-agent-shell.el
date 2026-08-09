;;; ai-agent-shell.el --- AI coding agent shell integration -*- lexical-binding: t; -*-

;; agent-shell: native Emacs shell for ACP-driven coding agents
;; https://github.com/xenodium/agent-shell
;;
;; Preferred agent: opencode (https://opencode.ai)
;;
;; Setup:
;;   1. Install opencode:  curl -fsSL https://opencode.ai/install | bash
;;   2. Add your provider's API key to ~/.local/share/opencode/auth.json
;;      (or run `/connect` inside opencode to be guided through it).

(defun rk/agent-shell-new ()
  "Start a new agent-shell session (never reuse an existing one)."
  (interactive)
  (let ((current-prefix-arg '(4)))
    (call-interactively #'agent-shell)))

(defun rk/agent-shell-toggle ()
  "Toggle visibility of the most recent agent-shell buffer.
If no agent-shell buffer exists, start one."
  (interactive)
  (if-let ((buf (seq-find (lambda (b)
                            (string-prefix-p "*agent-shell" (buffer-name b)))
                          (buffer-list))))
      (if-let ((win (get-buffer-window buf)))
          (delete-window win)
        (pop-to-buffer buf))
    (call-interactively #'agent-shell)))

(defun rk/agent-shell-restart ()
  "Kill the current agent-shell process and buffer, then start a new session."
  (interactive)
  (if-let ((buf (seq-find (lambda (b)
                            (string-prefix-p "*agent-shell" (buffer-name b)))
                          (buffer-list))))
      (let ((dir (buffer-local-value 'default-directory buf)))
        ;; Prevent process and query hooks from blocking the kill.
        (when-let ((proc (get-buffer-process buf)))
          (set-process-query-on-exit-flag proc nil)
          (delete-process proc))
        (let ((kill-buffer-query-functions nil))
          (kill-buffer buf))
        (let ((default-directory dir))
          (agent-shell-new-shell)))
    (agent-shell-new-shell)))

;; opencode default install location (curl -fsSL https://opencode.ai/install | bash)
(add-to-list 'exec-path (expand-file-name "~/.opencode/bin/"))

(use-package agent-shell
  :ensure t
  :commands (agent-shell agent-shell-send-region agent-shell-send-dwim agent-shell-new-shell)
  :config
  ;; Use opencode as the default agent
  (setq agent-shell-preferred-agent-config 'opencode)

  ;; Inherit the parent Emacs environment so PATH, HOME, etc. reach opencode.
  ;; DeepSeek credentials are read natively from ~/.local/share/opencode/auth.json.
  ;; To override the key from Emacs instead, uncomment and set the variable below:
  ;;   (setenv "DEEPSEEK_API_KEY" "YOUR_DEEPSEEK_API_KEY")
  (setq agent-shell-opencode-environment
        (agent-shell-make-environment-variables
         :inherit-env t)))

(rk/leader-keys
  "A"   '(:ignore t :wk "agents")
  "Aa"  '(agent-shell         :wk "start / reuse agent")
  "An"  '(rk/agent-shell-new  :wk "new agent session")
  "At"  '(rk/agent-shell-toggle  :wk "toggle agent window")
  "Ar"  '(rk/agent-shell-restart :wk "restart agent")
  "Ak"  '(kill-current-buffer :wk "kill agent buffer")
  "As"  '(agent-shell-send-region :wk "send region to agent")
  "Ad"  '(agent-shell-send-dwim :wk "send region / context to agent"))

(add-hook 'agent-shell-mode-hook
          (lambda () (display-line-numbers-mode -1)))
