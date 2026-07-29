;;; early-init.el --- Pre-package-init optimizations -*- lexical-binding: t; -*-

(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))

;; Must be set here — init.el is loaded after package initialization.
(setq package-enable-at-startup nil)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

(add-hook 'after-init-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))
