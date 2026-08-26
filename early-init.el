;;; early-init.el --- Pre-package-init optimizations -*- lexical-binding: t; -*-

;; Keep startup GC permissive, then restore sane runtime values after init.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(setq read-process-output-max (* 1024 1024))

;; This config is built-in only (no elpa/ packages), so skip package.el's
;; startup activation entirely. Must be set here — init.el is loaded after
;; package initialization, so setting it there would be too late.
(setq package-enable-at-startup nil)

;; Emacs 31: User Lisp Directory. Point it at `site-lisp/', which this
;; config already documents (see AGENTS.md) as the place for manually
;; installed Lisp code. Files there are auto-byte-compiled, scraped for
;; autoload cookies, and added to `load-path' — no custom bootstrap needed.
;; Must be set here (in early-init.el), not init.el: the value is consulted
;; before the regular init file loads.
(setq user-lisp-directory (expand-file-name "site-lisp/" user-emacs-directory))

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
