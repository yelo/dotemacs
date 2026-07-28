;; NonGNU Elpa
(with-eval-after-load 'package
  (add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; Initial frame size
(setq initial-frame-alist
      (append initial-frame-alist
              '((left . 350)
                (top . 100)
                (width . 190)
                (height . 50))))
