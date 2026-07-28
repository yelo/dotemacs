;; NonGNU Elpa
(with-eval-after-load 'package
  (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; Font
(set-frame-font "Iosevka NFM 14")

;; Command key is Super (Cmd+C/V/X/A/Z work as macOS copy/paste)
(setq ns-command-modifier 'super)
;; Option (alt) key is Meta (M-x, etc.)
(setq ns-alternate-modifier 'meta)

;; Initial frame size
(setq initial-frame-alist
      (append initial-frame-alist
              '((left . 350)
                (top . 100)
                (width . 190)
                (height . 50))))
