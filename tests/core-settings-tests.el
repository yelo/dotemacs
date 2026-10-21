;;; core-settings-tests.el --- Session persistence regressions -*- lexical-binding: t; -*-

(require 'ert)
(require 'desktop)
(require 'eww)

(defvar rk/cache-directory)

(let* ((directory (make-temp-file "rk-settings-state-" t))
       (user-emacs-directory (file-name-as-directory directory))
       (rk/cache-directory (expand-file-name "cache/" directory)))
  (unwind-protect
      (load (expand-file-name "../lisp/core-settings.el"
                              (file-name-directory load-file-name)))
    (desktop-save-mode -1)
    (delete-directory directory t)))

(ert-deftest rk/desktop-saves-eww-with-missing-history-position ()
  (let ((directory (make-temp-file "rk-eww-desktop-" t))
        (desktop-io-file-version desktop-native-file-version)
        (desktop-restore-frames nil))
    (unwind-protect
        (with-temp-buffer
          (eww-mode)
          (setq eww-data '(:url "https://example.invalid/current")
                eww-history '((:url "https://example.invalid/previous"))
                eww-history-position nil)
          (let ((data (nth 8 (desktop-buffer-info (current-buffer)))))
            (should (equal (plist-get data :history)
                           (cons eww-data eww-history)))
            (should (= (plist-get data :history-position) 0)))
          (should-not eww-history-position)
          (desktop-save directory)
          (should (file-exists-p (desktop-full-file-name directory))))
      (delete-directory directory t))))

(ert-deftest rk/eww-desktop-keeps-duplicate-history-and-selection ()
  (with-temp-buffer
    (eww-mode)
    (setq eww-data (list :url "https://example.invalid/repeated")
          eww-history (list (copy-tree eww-data))
          eww-history-position 0)
    (let ((data (eww-desktop-misc-data temporary-file-directory)))
      (should (= (length (plist-get data :history)) 2))
      (should (= (plist-get data :history-position) 0)))))

;;; core-settings-tests.el ends here
