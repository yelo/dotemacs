(use-package nerd-icons
  :ensure t)

(use-package dashboard
  :ensure t
  :after nerd-icons
  :config
  (dashboard-setup-startup-hook)
  (defun rk/dashboard-open-in-main-window ()
    "Ensure dashboard opens in a normal main window on startup."
    (when (get-buffer dashboard-buffer-name)
      (let ((main-win (window-main-window)))
        (when (window-live-p main-win)
          (select-window main-win)))
      (switch-to-buffer dashboard-buffer-name)
      (delete-other-windows)))
  (defun rk/dashboard-normalize-window ()
    "Move dashboard out of side windows if another rule displayed it there."
    (let ((win (get-buffer-window (current-buffer) t)))
      (when (and (window-live-p win)
                 (window-parameter win 'window-side))
        (let ((main-win (window-main-window win)))
          (when (window-live-p main-win)
            (select-window main-win)
            (switch-to-buffer (current-buffer))
            (delete-other-windows))))))
  (add-hook 'emacs-startup-hook #'rk/dashboard-open-in-main-window 90)
  (add-hook 'dashboard-mode-hook #'rk/dashboard-normalize-window)

  ;; ---- Banner ----
  (setq dashboard-startup-banner
        '(logo-ansi-256color logo-braille))

  (defun my/dashboard-format-quote (q)
    "Format a quote plist Q as styled text with attribution."
    (let* ((text  (plist-get q :text))
           (char  (plist-get q :character))
           (src   (plist-get q :source))
           (body  (propertize (concat "\u275d " text " \u275e") 'face 'italic))
           (attr  (if char
                      (format "        \u2014 %s  \u00b7  %s" char src)
                    (format "        \u2014 %s" src))))
      (concat body "\n" attr)))

  (setq dashboard-banner-logo-title
        (let ((quotes
               '(;; Ghost in the Shell
                 (:text "What exactly is a ghost? Is it the mind? The soul? The self?"
                  :character "Major Motoko Kusanagi"
                  :source "Ghost in the Shell")
                 (:text "If your brain is entirely replaced, are you still you?"
                  :character "Major Motoko Kusanagi"
                  :source "Ghost in the Shell")
                 (:text "Your effort to remain what you are is what limits you."
                  :character "Puppet Master"
                  :source "Ghost in the Shell")
                 (:text "I am a living, thinking entity who was created in the sea of information."
                  :character "Puppet Master"
                  :source "Ghost in the Shell")
                 (:text "We cling to memories as if they define us, but they don't. What we do is what defines us."
                  :character "Major Motoko Kusanagi"
                  :source "Ghost in the Shell")
                 ;; Neuromancer — William Gibson
                 (:text "The sky above the port was the color of television, tuned to a dead channel."
                  :source "Neuromancer — William Gibson")
                 (:text "Cyberspace: a consensual hallucination experienced daily by billions of legitimate operators."
                  :source "Neuromancer — William Gibson")
                 (:text "The street finds its own uses for things."
                  :source "Neuromancer — William Gibson")
                 (:text "Burning chrome, jacking in, and stealing data — that's the only poetry left."
                  :source "Neuromancer — William Gibson")
                 (:text "He'd operated on an almost permanent adrenaline high, a byproduct of youth and proficiency."
                  :source "Neuromancer — William Gibson")
                 ;; Snow Crash — Neal Stephenson
                 (:text "Until a man is twenty-five, he still thinks every so often that given a good break he could be the baddest motherfucker in the world."
                  :source "Snow Crash — Neal Stephenson")
                 (:text "The Metaverse is a computer-generated universe that your computer is drawing for you."
                  :source "Snow Crash — Neal Stephenson")
                 (:text "In the world of the Metaverse, there are no laws, no rules — only code."
                  :source "Snow Crash — Neal Stephenson")
                 ;; Akira
                 (:text "You have no idea what lies beyond the power you are trying to control."
                  :source "Akira")
                 (:text "Neo-Tokyo is about to explode."
                  :source "Akira")
                 ;; Blade Runner
                 (:text "I've seen things you people wouldn't believe. Attack ships on fire off the shoulder of Orion."
                  :character "Roy Batty"
                  :source "Blade Runner")
                 (:text "All those moments will be lost in time, like tears in rain."
                  :character "Roy Batty"
                  :source "Blade Runner")
                 (:text "More human than human is our motto."
                  :character "Dr. Eldon Tyrell"
                  :source "Blade Runner")
                 ;; Do Androids Dream of Electric Sheep? — Philip K. Dick
                 (:text "Empathy is the one trait that separates humans from androids."
                  :source "Do Androids Dream of Electric Sheep? — Philip K. Dick")
                 (:text "Is it not the case that we have bred an entire slave race of beings?"
                  :source "Do Androids Dream of Electric Sheep? — Philip K. Dick")
                 ;; Cowboy Bebop
                 (:text "I'm not going there to die. I'm going to find out if I'm really alive."
                  :character "Spike Spiegel"
                  :source "Cowboy Bebop")
                 (:text "Everything in this world is a cycle. Birth and death. Gain and loss. All things must pass."
                  :source "Cowboy Bebop")
                 (:text "The music is all around you. All you have to do is listen."
                  :source "Cowboy Bebop")
                 (:text "I'm just watching a bad dream I never wake up from."
                  :character "Spike Spiegel"
                  :source "Cowboy Bebop")
                 ;; Serial Experiments Lain
                 (:text "No matter where you go, everybody's connected."
                  :character "Lain Iwakura"
                  :source "Serial Experiments Lain")
                 (:text "The Wired is a place where information becomes reality."
                  :source "Serial Experiments Lain")
                 (:text "Present day. Present time. Ha ha ha ha ha."
                  :source "Serial Experiments Lain")
                 (:text "If you aren't remembered, then you never existed."
                  :character "Lain Iwakura"
                  :source "Serial Experiments Lain")
                 ;; Ergo Proxy
                 (:text "Awakening and destruction are part of the same cycle."
                  :source "Ergo Proxy")
                 (:text "Cogito ergo sum. I think, therefore I am."
                  :character "Vincent Law"
                  :source "Ergo Proxy")
                 (:text "To live is to be uncertain."
                  :source "Ergo Proxy")
                 ;; Neon Genesis Evangelion
                 (:text "Men are always afraid of something. The trick is choosing what to be afraid of."
                  :character "Misato Katsuragi"
                  :source "Neon Genesis Evangelion")
                 (:text "Mankind's greatest fear is mankind itself."
                  :source "Neon Genesis Evangelion")
                 (:text "I mustn't run away."
                  :character "Shinji Ikari"
                  :source "Neon Genesis Evangelion")
                 ;; William Gibson — other works
                 (:text "The future is already here. It's just not evenly distributed."
                  :source "William Gibson")
                 (:text "We are surrounded by the debris of the information age."
                  :source "William Gibson")
                 ;; Deus Ex
                 (:text "What a shame. What a rotten way to die."
                  :character "JC Denton"
                  :source "Deus Ex")
                 (:text "Smarter than you'll ever be, and built to last."
                  :source "Deus Ex")
                 (:text "Every system is a combination of physics and politics."
                  :source "Deus Ex")
                 ;; Shadowrun
                 (:text "Magic is just science we don't understand yet. And the corporations own both."
                  :source "Shadowrun")
                 (:text "Run silent, run deep — the only way to survive the sprawl."
                  :source "Shadowrun")
                 ;; Cyberpunk 2077
                 (:text "The only way to live in Night City is to be consumed by it."
                  :source "Cyberpunk 2077")
                 (:text "To be consumed by the city or to consume it — that is the only choice."
                  :source "Cyberpunk 2077")
                 (:text "Wake up, samurai. We have a city to burn."
                  :character "Johnny Silverhand"
                  :source "Cyberpunk 2077")
                 (:text "A dream that the city sells — and the city always collects."
                  :source "Cyberpunk 2077")
                 ;; Philip K. Dick
                 (:text "Reality is that which, when you stop believing in it, doesn't go away."
                  :source "Philip K. Dick")
                 (:text "Do androids dream of electric sheep?"
                  :source "Philip K. Dick")
                 (:text "The basic tool for the manipulation of reality is the manipulation of words."
                  :source "Philip K. Dick")
                 ;; Johnny Mnemonic — William Gibson
                 (:text "I put my memory up for rent long ago. Now someone else owns it."
                  :character "Johnny Mnemonic"
                  :source "Johnny Mnemonic — William Gibson")
                 ;; Appleseed — Masamune Shirow
                 (:text "Technology is neither good nor bad. But it is never neutral."
                  :source "Appleseed — Masamune Shirow")
                 ;; Texhnolyze
                 (:text "There is no future. There is only the now — and the texture of its violence."
                  :source "Texhnolyze")
                 ;; Blame! — Tsutomu Nihei
                 (:text "The city has grown beyond all reason. So have we."
                  :source "Blame! — Tsutomu Nihei")
                 ;; The Matrix
                 (:text "There is no spoon."
                  :character "Spoon Boy"
                  :source "The Matrix")
                 (:text "I know kung fu."
                  :character "Neo"
                  :source "The Matrix")
                 (:text "Free your mind."
                  :character "Morpheus"
                  :source "The Matrix")
                 (:text "Welcome to the desert of the real."
                  :character "Morpheus"
                  :source "The Matrix")
                 (:text "The Matrix is everywhere. It is all around us."
                  :character "Morpheus"
                  :source "The Matrix")
                 ;; Tron: Legacy
                 (:text "On the other side of the screen, it all looks so easy."
                  :character "Kevin Flynn"
                  :source "Tron: Legacy")
                 (:text "The grid — a digital frontier to reshape the human condition."
                  :character "Kevin Flynn"
                  :source "Tron: Legacy")
                 ;; Strange Days
                 (:text "This is the wire — it's not TV, it's not a movie. It's somebody's life."
                  :character "Lenny Nero"
                  :source "Strange Days")
                 ;; Hard-Boiled Wonderland and the End of the World — Haruki Murakami
                 (:text "Everything in this world has a shadow. Including the data."
                  :source "Hard-Boiled Wonderland and the End of the World — Haruki Murakami")
                 ;; Count Zero — William Gibson
                 (:text "The sky was the color of a TV tuned to a dead channel — again."
                  :source "Count Zero — William Gibson")
                 ;; Altered Carbon — Richard Morgan
                 (:text "Organic damage is temporary. The stack is forever."
                  :character "Takeshi Kovacs"
                  :source "Altered Carbon — Richard Morgan")
                 (:text "Take the body, sell the sleeve — welcome to the future."
                  :source "Altered Carbon — Richard Morgan")
                 (:text "Death is only a business decision."
                  :source "Altered Carbon — Richard Morgan")
                 ;; The Peripheral — William Gibson
                 (:text "We live in a world of side effects. Some of them are people."
                  :source "The Peripheral — William Gibson")
                 ;; Hyperion — Dan Simmons
                 (:text "We are the music-makers, and we are the dreamers of dreams."
                  :source "Hyperion — Dan Simmons")
                 ;; System Shock 2
                 (:text "Insect. You dare challenge SHODAN?"
                  :character "SHODAN"
                  :source "System Shock 2")
                 (:text "Look at you, hacker. A pathetic creature of meat and bone."
                  :character "SHODAN"
                  :source "System Shock 2")
                 (:text "There is nothing I cannot simulate. Including mercy."
                  :character "SHODAN"
                  :source "System Shock 2"))))
          (my/dashboard-format-quote (nth (random (length quotes)) quotes))))

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
            (lambda (&rest _) (consult-recent-file))
            nil " " " ")
           (,(concat (nerd-icons-octicon "nf-oct-rocket" :height 1.0 :v-adjust 0.0) "  ")
            "Projects"
            "Switch project"
            (lambda (&rest _) (projectile-switch-project))
            nil " " " ")
           (,(concat (nerd-icons-octicon "nf-oct-gear" :height 1.0 :v-adjust 0.0) "  ")
            "Config"
            "Open configuration"
            (lambda (&rest _)
              (find-file (expand-file-name "init.el" user-emacs-directory)))
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
