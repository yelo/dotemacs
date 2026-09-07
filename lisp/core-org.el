;;; core-org.el --- Org writing, notes, and spell checking -*- lexical-binding: t; -*-

(require 'org)
(require 'ispell)
(require 'flyspell)
(require 'flymake)

;;; Hunspell / spelling

(defconst rk/spell-dictionaries '("fi_FI" "sv_SE" "en_US")
  "Preferred Hunspell dictionaries for Finnish, Swedish, and English.")

(defconst rk/macos-spell-dictionary-map
  '(("fi_FI" . "fi")
    ("sv_SE" . "sv")
    ("en_US" . "en"))
  "Map Emacs dictionary names to macOS spell-checker language IDs.")

(defconst rk/macos-spell-helper
  (expand-file-name "scripts/rk-macos-spell.swift" user-emacs-directory)
  "Swift helper that exposes macOS NSSpellChecker to Emacs.")

(when (executable-find "hunspell")
  (setq ispell-program-name "hunspell"))

(dolist (dict rk/spell-dictionaries)
  (add-to-list 'ispell-local-dictionary-alist
               `(,dict
                 "[[:alpha:]]"
                 "[^[:alpha:]]"
                 "[']"
                 nil
                 ("-d" ,dict)
                 nil
                 utf-8)))

(setq ispell-dictionary "fi_FI")

(defvar rk/spell--missing-dictionaries-reported nil
  "Hunspell dictionaries already reported as missing.")

(defvar-local rk/macos-spell--process nil
  "Current macOS native spell-check process for this buffer.")

(defun rk/spell-hunspell-dictionary-available-p (dictionary)
  "Return non-nil when Hunspell can find DICTIONARY."
  (and (string= ispell-program-name "hunspell")
       (assoc dictionary (ignore-errors
                           (ispell-find-hunspell-dictionaries)))))

(defun rk/spell-report-missing-dictionary-once (dictionary)
  "Report missing Hunspell DICTIONARY once per Emacs session."
  (unless (member dictionary rk/spell--missing-dictionaries-reported)
    (push dictionary rk/spell--missing-dictionaries-reported)
    (message "Spell checking unavailable: Hunspell dictionary %s is not installed"
             dictionary)))

(defun rk/macos-spell-available-p ()
  "Return non-nil when macOS native spell checking can be used."
  (and (eq system-type 'darwin)
       (executable-find "swift")
       (file-readable-p rk/macos-spell-helper)))

(defun rk/spell-native-language (dictionary)
  "Return the macOS native language ID for DICTIONARY."
  (cdr (assoc dictionary rk/macos-spell-dictionary-map)))

(defun rk/spell-current-dictionary ()
  "Return the current buffer's configured spell dictionary."
  (or ispell-local-dictionary ispell-dictionary "fi_FI"))

(defun rk/spell-set-dictionary (dictionary)
  "Set the current buffer's spell DICTIONARY."
  (interactive
   (list (completing-read "Dictionary: " rk/spell-dictionaries nil t
                          nil nil (rk/spell-current-dictionary))))
  (unless (member dictionary rk/spell-dictionaries)
    (user-error "Unsupported dictionary: %s" dictionary))
  (setq-local ispell-local-dictionary dictionary)
  (when (bound-and-true-p flymake-mode)
    (flymake-start))
  (message "Spell dictionary: %s" dictionary))

(defun rk/macos-spell--diagnostic-region (line column length)
  "Return a diagnostic region for LINE, COLUMN, and LENGTH."
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- line))
    (let ((beg (min (line-end-position) (+ (line-beginning-position) column))))
      (cons beg (min (point-max) (+ beg length))))))

(defun rk/macos-spell-flymake (report-fn &rest _args)
  "Report macOS native spell diagnostics to REPORT-FN."
  (when (process-live-p rk/macos-spell--process)
    (kill-process rk/macos-spell--process))
  (unless (executable-find "swift")
    (funcall report-fn :panic :explanation "Swift is required for macOS spell checking"))
  (if-let* ((language (rk/spell-native-language (rk/spell-current-dictionary)))
            (source (current-buffer))
            (text (buffer-substring-no-properties (point-min) (point-max))))
      (progn
        (setq rk/macos-spell--process
              (make-process
               :name "rk-macos-spell"
               :buffer (generate-new-buffer " *rk-macos-spell*")
               :command (list "swift" rk/macos-spell-helper language)
               :connection-type 'pipe
               :noquery t
               :sentinel
               (lambda (proc _event)
                 (when (memq (process-status proc) '(exit signal))
                   (unwind-protect
                       (when (and (buffer-live-p source)
                                  (eq proc (buffer-local-value
                                            'rk/macos-spell--process source)))
                         (with-current-buffer source
                           (if (= (process-exit-status proc) 0)
                               (let (diagnostics)
                                 (with-current-buffer (process-buffer proc)
                                   (goto-char (point-min))
                                   (while (not (eobp))
                                     (let* ((fields (split-string
                                                     (buffer-substring-no-properties
                                                      (line-beginning-position)
                                                      (line-end-position))
                                                     "\t"))
                                            (line (string-to-number (nth 0 fields)))
                                            (column (string-to-number (nth 1 fields)))
                                            (length (string-to-number (nth 2 fields)))
                                            (word (nth 3 fields)))
                                       (when (and (> line 0) (>= column 0) (> length 0))
                                         (pcase-let ((`(,beg . ,end)
                                                      (rk/macos-spell--diagnostic-region
                                                       line column length)))
                                           (push (flymake-make-diagnostic
                                                  source beg end :warning
                                                  (format "Possible misspelling: %s" word))
                                                 diagnostics))))
                                     (forward-line 1)))
                                 (funcall report-fn (nreverse diagnostics)))
                             (funcall report-fn
                                      :panic
                                      :explanation
                                      (with-current-buffer (process-buffer proc)
                                        (buffer-string))))))
                     (when (buffer-live-p (process-buffer proc))
                       (kill-buffer (process-buffer proc))))))))
        (process-send-string rk/macos-spell--process text)
        (process-send-eof rk/macos-spell--process))
    (funcall report-fn nil)))

(defun rk/org-enable-spell-checking ()
  "Enable the preferred spell checker for Org buffers."
  (cond
   ((rk/macos-spell-available-p)
    (setq-local flymake-no-changes-timeout 1.5)
    (add-hook 'flymake-diagnostic-functions #'rk/macos-spell-flymake nil t)
    (flymake-mode 1))
   ((rk/spell-hunspell-dictionary-available-p ispell-local-dictionary)
    (flyspell-mode 1))
   (t
    (rk/spell-report-missing-dictionary-once ispell-local-dictionary))))

;;; Org defaults

(setq org-directory (expand-file-name "~/.org/")
      org-default-notes-file (expand-file-name "notes.org" org-directory)
      org-agenda-files (list org-directory)
      org-startup-indented t
      org-startup-folded 'content
      org-hide-emphasis-markers t
      org-pretty-entities t
      org-return-follows-link t
      org-log-done 'time
      org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@)" "|"
                  "DONE(d)" "CANCELLED(c@)"))
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil
      org-refile-targets '((nil . (:maxlevel . 3))
                           (org-agenda-files . (:maxlevel . 3))))

(make-directory org-directory t)

(defun rk/org-mode-setup ()
  "Apply local writing defaults for Org buffers."
  (setq-local ispell-local-dictionary "fi_FI")
  (visual-line-mode 1)
  (rk/org-enable-spell-checking))

(add-hook 'org-mode-hook #'rk/org-mode-setup)

(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c l" #'org-store-link)

(provide 'core-org)
;;; core-org.el ends here
