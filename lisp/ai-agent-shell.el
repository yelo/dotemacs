;; agent-shell: native Emacs shell for ACP-driven coding agents
;; https://github.com/xenodium/agent-shell
;;
;; Preferred agent: opencode (https://opencode.ai)
;; Provider:        DeepSeek (deepseek/deepseek-chat)
;;
;; Setup:
;;   1. Install opencode:  curl -fsSL https://opencode.ai/install | bash
;;   2. Add your DeepSeek API key to ~/.local/share/opencode/auth.json:
;;        { "deepseek": { "type": "api", "key": "YOUR_DEEPSEEK_API_KEY" } }
;;      Get a key at https://platform.deepseek.com/api_keys
;;      (Or run `/connect` inside opencode to be guided through it.)

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
  "Kill the current agent-shell process and restart it."
  (interactive)
  (if-let ((buf (seq-find (lambda (b)
                            (string-prefix-p "*agent-shell" (buffer-name b)))
                          (buffer-list))))
      (with-current-buffer buf
        (when (fboundp 'agent-shell-restart)
          (agent-shell-restart))
        (unless (fboundp 'agent-shell-restart)
          ;; Fallback: kill the buffer and open a fresh session
          (kill-buffer buf)
          (call-interactively #'agent-shell)))
    (message "No agent-shell buffer found")))

(use-package agent-shell
  :ensure t
  :config
  ;; opencode default install location (curl -fsSL https://opencode.ai/install | bash)
  (add-to-list 'exec-path (expand-file-name "~/.opencode/bin/"))

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
  "Ak"  '(kill-current-buffer :wk "kill agent buffer"))
