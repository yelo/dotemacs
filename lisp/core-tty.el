;;; core-tty.el --- TTY / terminal-mode quality-of-life enhancements -*- lexical-binding: t; -*-
;;
;; Loaded only when Emacs is running in a terminal (no window system).

;;; Mouse support
(xterm-mouse-mode 1)

;; Scroll with the mouse wheel (3 lines at a time, no acceleration).
(setq mouse-wheel-scroll-amount '(3 ((shift) . 1))
      mouse-wheel-progressive-speed nil)
(global-set-key [mouse-4] (lambda () (interactive) (scroll-down 3)))
(global-set-key [mouse-5] (lambda () (interactive) (scroll-up 3)))

;;; Avoid garbled display: don't blink the cursor (terminal cursors vary)
(blink-cursor-mode -1)

;;; Show a visible bell instead of an audible one (many terminals beep)
(setq visible-bell t
      ring-bell-function #'ignore)

;;; Make C-l also recenter and clear terminal cruft
(global-set-key (kbd "C-l") #'recenter-top-bottom)

;;; Improve color support: advise Emacs to trust the terminal's color count
(when (string-match-p "256color\\|truecolor\\|direct" (or (getenv "TERM") ""))
  (setq xterm-extra-capabilities '(modifyOtherKeys reportBackground setSelection)))

;;; mwheel is needed for the mouse-wheel variables above
(require 'mwheel)

(provide 'core-tty)
;;; core-tty.el ends here
