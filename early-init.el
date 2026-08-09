;;; early-init.el --- Pre-package-init optimizations -*- lexical-binding: t; -*-

;; Keep startup GC permissive, then restore sane runtime values after init.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(setq read-process-output-max (* 1024 1024))

;; Must be set here — init.el is loaded after package initialization.
(setq package-enable-at-startup nil)

;; Temporarily disable expensive file-name handlers during startup.
(defvar rk/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)
            (setq file-name-handler-alist
                  (delete-dups
                   (append file-name-handler-alist rk/file-name-handler-alist)))))
