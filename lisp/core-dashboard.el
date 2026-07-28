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
        '(logo-ansi-256color logo-braille))
  (setq dashboard-banner-logo-title
        (let ((quotes
               '(;; Ghost in the Shell
                 "What exactly is a ghost? Is it the mind? The soul? The self?"
                 "If your brain is entirely replaced, are you still you?"
                 "Your effort to remain what you are is what limits you."
                 "I am a living, thinking entity who was created in the sea of information."
                 "We cling to memories as if they define us, but they don't. What we do is what defines us."
                 ;; Neuromancer — William Gibson
                 "The sky above the port was the color of television, tuned to a dead channel."
                 "Cyberspace: a consensual hallucination experienced daily by billions of legitimate operators."
                 "The street finds its own uses for things."
                 "Burning chrome, jacking in, and stealing data — that's the only poetry left."
                 "He'd operated on an almost permanent adrenaline high, a byproduct of youth and proficiency."
                 ;; Snow Crash — Neal Stephenson
                 "Until a man is twenty-five, he still thinks every so often that given a good break he could be the baddest motherfucker in the world."
                 "The Metaverse is a computer-generated universe that your computer is drawing for you."
                 "In the world of the Metaverse, there are no laws, no rules — only code."
                 ;; Akira
                 "You have no idea what lies beyond the power you are trying to control."
                 "Neo-Tokyo is about to explode."
                 ;; Blade Runner / Do Androids Dream of Electric Sheep?
                 "I've seen things you people wouldn't believe. Attack ships on fire off the shoulder of Orion."
                 "All those moments will be lost in time, like tears in rain."
                 "More human than human is our motto."
                 "Empathy is the one trait that separates humans from androids."
                 "Is it not the case that we have bred an entire slave race of beings?"
                 ;; Cowboy Bebop
                 "I'm not going there to die. I'm going to find out if I'm really alive."
                 "Everything in this world is a cycle. Birth and death. Gain and loss. All things must pass."
                 "The music is all around you. All you have to do is listen."
                 "I'm just watching a bad dream I never wake up from."
                 ;; Serial Experiments Lain
                 "No matter where you go, everybody's connected."
                 "The Wired is a place where information becomes reality."
                 "Present day. Present time. Ha ha ha ha ha."
                 "If you aren't remembered, then you never existed."
                 ;; Ergo Proxy
                 "Awakening and destruction are part of the same cycle."
                 "Cogito ergo sum. I think, therefore I am."
                 "To live is to be uncertain."
                 ;; Neon Genesis Evangelion
                 "Men are always afraid of something. The trick is choosing what to be afraid of."
                 "Mankind's greatest fear is mankind itself."
                 "I mustn't run away."
                 ;; William Gibson — other works
                 "Information wants to be free."
                 "The future is already here. It's just not evenly distributed."
                 "We are surrounded by the debris of the information age."
                 ;; Deus Ex
                 "What a shame. What a rotten way to die."
                 "Smarter than you'll ever be, and built to last."
                 "Every system is a combination of physics and politics."
                 ;; Shadowrun lore
                 "Magic is just science we don't understand yet. And the corporations own both."
                 "Run silent, run deep — the only way to survive the sprawl."
                 ;; Cyberpunk 2077 / RED
                 "The only way to live in Night City is to be consumed by it."
                 "To be consumed by the city or to consume it — that is the only choice."
                 "Wake up, samurai. We have a city to burn."
                 "A dream that the city sells — and the city always collects."
                 ;; Philip K. Dick
                 "Reality is that which, when you stop believing in it, doesn't go away."
                 "Do androids dream of electric sheep?"
                 "The basic tool for the manipulation of reality is the manipulation of words."
                 ;; Johnny Mnemonic — William Gibson
                 "I put my memory up for rent long ago. Now someone else owns it."
                 ;; Appleseed / Masamune Shirow
                 "Technology is neither good nor bad. But it is never neutral."
                 ;; Texhnolyze
                 "There is no future. There is only the now — and the texture of its violence."
                 ;; Blame! — Tsutomu Nihei
                 "The city has grown beyond all reason. So have we."
                 ;; The Matrix
                 "There is no spoon."
                 "I know kung fu."
                 "Free your mind."
                 "Welcome to the desert of the real."
                 "The Matrix is everywhere. It is all around us."
                 ;; Tron / Tron: Legacy
                 "On the other side of the screen, it all looks so easy."
                 "The grid — a digital frontier to reshape the human condition."
                 ;; Strange Days (film)
                 "This is the wire — it's not TV, it's not a movie. It's somebody's life."
                 ;; Hardboiled / Hard-Boiled Wonderland — Haruki Murakami
                 "Everything in this world has a shadow. Including the data."
                 ;; Count Zero — William Gibson
                 "The sky was the color of a TV tuned to a dead channel — again."
                 ;; Altered Carbon — Richard Morgan
                 "Organic damage is temporary. The stack is forever."
                 "Take the body, sell the sleeve — welcome to the future."
                 "Death is only a business decision."
                 ;; Peripheral — William Gibson
                 "We live in a world of side effects. Some of them are people."
                 ;; Hyperion — Dan Simmons
                 "We are the music-makers, and we are the dreamers of dreams."
                 ;; System Shock
                 "Insect. You dare challenge SHODAN?"
                 "Look at you, hacker. A pathetic creature of meat and bone."
                 "There is nothing I cannot simulate. Including mercy.")))
          (nth (random (length quotes)) quotes)))

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
