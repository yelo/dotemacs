(use-package nerd-icons
  :ensure t)

(use-package dashboard
  :ensure t
  :after nerd-icons
  :init
  (setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))
  :config
  (dashboard-setup-startup-hook)

  ;; ---- Banner ----
  (setq dashboard-startup-banner
        '(official logo logo-ansi-truecolor logo-braille))
  (setq dashboard-banner-logo-title "Welcome, Jimmy! Let's hack something great today.")

  ;; ---- Layout ----
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  (setq dashboard-hide-cursor t)
  (setq dashboard-page-separator "\n")

  ;; ---- Icons ----
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-show-shortcuts t)

  ;; ---- Sections ----
  (setq dashboard-items
        '((recents   . 5)
          (bookmarks . 5)
          (projects  . 5)
          (agenda    . 5)))
  (setq dashboard-projects-backend 'projectile)

  (setq dashboard-item-shortcuts
        '((recents   . "r")
          (bookmarks . "m")
          (projects  . "p")
          (agenda    . "a")))

  ;; ---- Footer: system stats ----
  (setq dashboard-init-info
        (lambda ()
          (let* ((pkgs   (if (bound-and-true-p package-alist)
                             (length package-activated-list)
                           0))
                 (ver    emacs-version)
                 (host   (or (system-name) "localhost"))
                 (uptime (emacs-uptime "%hh %mm"))
                 (init-time (if (fboundp 'emacs-init-time)
                                (emacs-init-time "%0.2fs")
                              "?")))
            (format "%d packages  ·  Emacs %s  ·  Started in %s  ·  %s "
                    pkgs ver init-time host))))

  ;; ---- Footer messages (not shown since init-info replaces footer) ----
  (setq dashboard-set-footer t)

  ;; ---- Navigator buttons ----
  (setq dashboard-set-navigator t)
  (setq dashboard-navigator-buttons
        `(((,(concat (nerd-icons-octicon "nf-oct-file" :height 1.0 :v-adjust 0.0) "  ")
            "New file"
            "Create a new file"
            (lambda (&rest _) (call-interactively 'find-file))
            nil " " " ")
           (,(concat (nerd-icons-octicon "nf-oct-history" :height 1.0 :v-adjust 0.0) "  ")
            "Recents"
            "Open recent file"
            (lambda (&rest _) (counsel-recentf))
            nil " " " ")
           (,(concat (nerd-icons-octicon "nf-oct-rocket" :height 1.0 :v-adjust 0.0) "  ")
            "Projects"
            "Switch project"
            (lambda (&rest _) (projectile-switch-project))
            nil " " " ")
           (,(concat (nerd-icons-octicon "nf-oct-gear" :height 1.0 :v-adjust 0.0) "  ")
            "Config"
            "Open configuration (init.el + lisp/)"
            (lambda (&rest _)
              (let ((lisp-dir (expand-file-name "lisp/" user-emacs-directory)))
                (dirvish lisp-dir)
                (split-window-right)
                (other-window 1)
                (find-file (expand-file-name "init.el" user-emacs-directory))))
            nil " " " "))))

  ;; ---- Disable line numbers in dashboard ----
  (add-hook 'dashboard-mode-hook (lambda () (display-line-numbers-mode -1)))

  ;; ---- Widget layout ----
  (setq dashboard-startupify-list
        '(dashboard-insert-banner
          dashboard-insert-newline
          dashboard-insert-banner-title
          dashboard-insert-newline
          dashboard-insert-navigator
          dashboard-insert-newline
          dashboard-insert-init-info
          dashboard-insert-items
          dashboard-insert-newline
          dashboard-insert-footer)))
