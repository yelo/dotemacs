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
