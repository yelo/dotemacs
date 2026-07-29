;;; core-keybindings.el --- Keybinding framework and leader keys -*- lexical-binding: t; -*-

(eval-and-compile
  (eval-when-compile (require 'cl-lib))

  (defmacro rk/feature-leader-keys (feature keymaps &rest bindings)
    "Define local-leader keys under `SPC m` after FEATURE is loaded.
FEATURE is a symbol suitable for `with-eval-after-load` (typically a quoted
feature name like 'python).  KEYMAPS is a keymap symbol or list of symbols.
BINDINGS are alternating KEY and DEF pairs, where KEY is relative to `SPC m`."
    (declare (indent 2))
    (let (expanded)
      (while bindings
        (let ((key (pop bindings))
              (def (pop bindings)))
          (push key expanded)
          (push def expanded)))
      `(with-eval-after-load ,feature
         (let* ((rk--keymaps (if (listp ,keymaps) ,keymaps (list ,keymaps)))
                (rk--major-modes
                 (mapcar (lambda (km)
                           (intern (replace-regexp-in-string "-map\\'" ""
                                                             (symbol-name km))))
                         rk--keymaps)))
           (rk/local-leader-keys
            :major-modes rk--major-modes
            ,@(nreverse expanded))))))

  (defmacro rk/major-mode-leader-keys (feature keymaps &rest bindings)
    "Define major-mode local-leader keys under `SPC m` after FEATURE loads."
    (declare (indent 2))
    `(rk/feature-leader-keys ,feature ,keymaps ,@bindings))

  (defmacro rk/minor-mode-leader-keys (feature keymaps &rest bindings)
    "Define minor-mode local-leader keys under `SPC m` after FEATURE loads."
    (declare (indent 2))
    `(rk/feature-leader-keys ,feature ,keymaps ,@bindings))

  (defmacro rk/lang (feature keymaps &rest bindings)
    "Tiny wrapper for language-focused major-mode local-leader bindings."
    (declare (indent 2))
    `(rk/major-mode-leader-keys ,feature ,keymaps ,@bindings)))

(use-package general
  :ensure t
  :after (meow which-key)
  :config
  (general-create-definer rk/leader-keys
    :keymaps '(meow-normal-state-keymap meow-motion-state-keymap)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer rk/local-leader-keys
    :keymaps '(meow-normal-state-keymap meow-motion-state-keymap)
    :prefix "SPC m"
    :global-prefix "C-SPC m")

  ;; ── Show-keymap helper (robust across Emacs versions) ──

  (defun rk/show-keymap (keymap &optional prefix-title)
    "Display KEYMAP entries using which-key.
When PREFIX-TITLE is given, it is shown as the which-key heading."
    (interactive)
    (if (and (fboundp 'which-key--show-keymap)
             (not (get 'which-key--show-keymap 'byte-obsolete-info)))
        (which-key--show-keymap (symbol-name keymap)
                                (if (symbolp keymap)
                                    (symbol-value keymap)
                                  keymap)
                                nil prefix-title " command")
      ;; Fallback for versions that lack which-key--show-keymap
      (if (fboundp 'which-key-show-major-mode)
          (which-key-show-major-mode)
        (describe-keymap keymap))))

  ;; ── Dynamic SPC m major-mode menu ──

  (defun rk/show-major-mode-bindings ()
    "Show current major-mode's keymap via which-key.
Equivalent to Doom's <leader> m behavior."
    (interactive)
    (let ((mode-map (intern (format "%s-map" major-mode))))
      (if (and (boundp mode-map) (keymapp (symbol-value mode-map)))
          (rk/show-keymap mode-map (format "(%s) keys" major-mode))
        ;; Fallback: let which-key resolve it
        (if (fboundp 'which-key-show-major-mode)
            (which-key-show-major-mode)
          (message "No keymap found for %s" major-mode)))))

  (defun rk/show-minor-mode-bindings (mode)
    "Show bindings for minor-mode MODE via which-key."
    (interactive
     (let* ((mm (seq-filter (lambda (m) (and (boundp m) (symbol-value m)))
                            (mapcar #'car minor-mode-alist)))
            (choice (completing-read "Minor mode: " mm nil t)))
       (list (intern choice))))
    (condition-case nil
        (let ((map (intern (format "%s-map" mode))))
          (if (and (boundp map) (keymapp (symbol-value map)))
              (rk/show-keymap map (format "(%s) keys" mode))
            (message "No keymap for minor-mode %s" mode)))
      (error (message "Failed to show keymap for %s" mode))))

   ;; ── Top-level leader bindings ──

  (general-define-key
   :keymaps '(meow-normal-state-keymap meow-motion-state-keymap)
   :prefix "SPC"
   :global-prefix "C-SPC"

   "SPC"  '(:ignore t :wk "M-x")

   ;; files
   "f"    '(:ignore t :wk "files")
   "ft"   '(dirvish-side               :wk "toggle file tree")
   "ff"   '(consult-fd                 :wk "fuzzy find file")
   "fF"   '(find-file                  :wk "find file")
   "fr"   '(consult-recent-file        :wk "fuzzy recent files")

   ;; actions
   "a"    '(:ignore t :wk "actions")
   "a."   '(embark-act                 :wk "act")
   "a;"   '(embark-dwim                :wk "dwim")

   ;; buffers
   "b"    '(:ignore t :wk "buffers")
   "bb"   '(consult-buffer             :wk "switch buffer")
   "bB"   '(consult-buffer-other-window :wk "buffer other window")
   "bd"   '(kill-current-buffer        :wk "kill this buffer")
   "bi"   '(ibuffer                    :wk "ibuffer")
   "bn"   '(next-buffer                :wk "next")
   "bp"   '(previous-buffer            :wk "previous")
   "br"   '(revert-buffer              :wk "revert")

   ;; windows
   "w"    '(:ignore t :wk "windows")
   ;; navigation (htns — Dvorak home row)
   "wh"   '(windmove-left              :wk "left")
   "wt"   '(windmove-up                :wk "up")
   "wn"   '(windmove-down              :wk "down")
   "ws"   '(windmove-right             :wk "right")
   ;; layouts
   "wl"   '(rk/2-column-layout         :wk "2 columns")
   "wL"   '(rk/3-column-layout         :wk "3 columns")
   "wr"   '(rk/2-row-layout            :wk "2 rows")
   "wd"   '(rk/toggle-window-split     :wk "toggle split")
   "wz"   '(rk/zoom-toggle             :wk "zoom toggle")
   ;; window history (winner-mode)
   "wu"   '(winner-undo              :wk "undo layout")
   "wU"   '(winner-redo              :wk "redo layout")
   ;; actions
   "ww"   '(other-window               :wk "cycle")
   "w|"   '(split-window-right         :wk "split right")
   "w-"   '(split-window-below         :wk "split below")
   "wc"   '(delete-window              :wk "close")
   "wo"   '(delete-other-windows       :wk "only")
   "w="   '(balance-windows            :wk "balance")

   ;; project (project.el — built-in)
   "p"    '(:ignore t :wk "project")
   "pf"   '(project-find-file       :wk "find file in project")
   "pp"   '(project-switch-project  :wk "switch project")
   "pd"   '(project-dired           :wk "project dired")
   "ps"   '(consult-ripgrep         :wk "search in project")

   ;; search
   "s"    '(:ignore t :wk "search")
   "ss"   '(consult-line               :wk "search buffer")
   "sg"   '(consult-ripgrep            :wk "ripgrep")

   ;; major-mode (SPC m)
   "m"    '(:ignore t :wk "major-mode")
   "mm"   '(rk/show-major-mode-bindings :wk "mode keybindings")
   "mb"   '(rk/show-minor-mode-bindings :wk "minor-mode keybindings")
   "m?"   '(describe-mode              :wk "describe mode")

   ;; git
   "g"    '(:ignore t :wk "git")
   "gs"   '(magit-status               :wk "status")
   "gb"   '(magit-blame-addition       :wk "blame")
   "gl"   '(magit-log-current          :wk "log current")
   "gc"   '(magit-commit-create        :wk "commit")

   ;; help
   "h"    '(:ignore t :wk "help")
   "hf"   '(describe-function          :wk "describe function")
   "hv"   '(describe-variable          :wk "describe variable")
   "hk"   '(describe-key               :wk "describe key")
   "hs"   '(describe-symbol            :wk "describe symbol")
   "hp"   '(describe-package           :wk "describe package")
   "hm"   '(describe-mode              :wk "describe mode")
   "hi"   '(info                       :wk "info")
   "h?"   '(which-key-show-top-level   :wk "show keybindings")))
