(use-package ivy
  :ensure t
  :init
  (ivy-mode 1)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-count-format "(%d/%d) ")
  (enable-recursive-minibuffers t))

(use-package counsel
  :ensure t
  :after ivy
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b" . counsel-switch-buffer)
         ("C-c k" . counsel-rg))
  :config
  (counsel-mode 1))

(use-package swiper
  :ensure t
  :after ivy
  :bind (("C-s" . swiper-isearch)))

(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :init
  (global-corfu-mode 1)
  :bind (:map corfu-map
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous)))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file t)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev t)
  (add-to-list 'completion-at-point-functions #'cape-keyword t))

(use-package tempel
  :ensure t
  :bind (("M-+" . tempel-complete)
         ("C-c t i" . tempel-insert))
  :init
  (add-to-list 'completion-at-point-functions #'tempel-expand t))

(use-package tempel-collection
  :ensure t
  :after tempel)

(setq tab-always-indent 'complete)
