;;; bip-analyze-directory.el --- Analyze directory for binary files, long files, and large files

(defun is-binary-file-p (filepath)
  "Check if FILEPATH is a binary file by looking for null bytes in first 8000 bytes."
  (with-temp-buffer
    (condition-case nil
        (let ((coding-system-for-read 'binary))
          (insert-file-contents filepath nil 0 8000)
          (goto-char (point-min))
          (search-forward "\0" nil t))
      (error nil))))

(defun count-lines-in-file (filepath)
  "Count lines in FILEPATH efficiently with proper encoding handling."
  (with-temp-buffer
    (condition-case nil
        (let ((coding-system-for-read 'utf-8-auto))
          (insert-file-contents filepath)
          (count-lines (point-min) (point-max)))
      (error 0))))

(defun get-file-size (filepath)
  "Get file size in bytes for FILEPATH."
  (condition-case nil
      (nth 7 (file-attributes filepath))
    (error 0)))

(defun format-file-size (size)
  "Format SIZE in bytes to human readable format."
  (cond
   ((>= size (* 1024 1024 1024)) (format "%.1f GB" (/ size (* 1024.0 1024.0 1024.0))))
   ((>= size (* 1024 1024)) (format "%.1f MB" (/ size (* 1024.0 1024.0))))
   ((>= size 1024) (format "%.1f KB" (/ size 1024.0)))
   (t (format "%d B" size))))

(defun scan-directory-for-issues (directory)
  "Scan DIRECTORY recursively for binary files, files >2000 lines, and files >20MB."
  (let ((results '())
        (total-files 0)
        (warning-inhibit-log-level :warning)) ; Suppress encoding warnings
    (dolist (file (directory-files-recursively directory ".*" nil t))
      (when (file-regular-p file)
        (setq total-files (1+ total-files))
        (when (zerop (% total-files 100))
          (message "Scanned %d files..." total-files))

        (let ((size (get-file-size file))
              (is-binary (is-binary-file-p file))
              (line-count nil))

          ;; Only count lines if not binary (for efficiency)
          (unless is-binary
            (setq line-count (count-lines-in-file file)))

          ;; Check conditions and add to results
          (let ((issues '()))
            (when is-binary
              (push "BINARY" issues))
            (when (and line-count (> line-count 2000))
              (push (format "LONG (%d lines)" line-count) issues))
            (when (> size (* 20 1024 1024))
              (push (format "LARGE (%s)" (format-file-size size)) issues))

            (when issues
              (push (list file issues size line-count) results))))))

    (message "Scan complete. Found %d problematic files out of %d total files."
             (length results) total-files)
    results))

(defun display-scan-results (results directory)
  "Display RESULTS from scanning DIRECTORY in a formatted buffer, grouped by type."
  (let ((buffer (get-buffer-create "*BIP Directory Analysis*"))
        (binary-files '())
        (long-files '())
        (large-files '()))

    ;; Categorize files by type
    (dolist (result results)
      (let ((filepath (car result))
            (issues (cadr result))
            (size (caddr result))
            (lines (cadddr result)))
        (dolist (issue issues)
          (cond
           ((string-match "^BINARY" issue)
            (push result binary-files))
           ((string-match "^LONG" issue)
            (push result long-files))
           ((string-match "^LARGE" issue)
            (push result large-files))))))

    (with-current-buffer buffer
      (erase-buffer)
      (insert (format "BIP Directory Analysis Results for: %s\n" directory))
      (insert (format "Scan completed at: %s\n" (current-time-string)))
      (insert (format "Found %d problematic files\n\n" (length results)))

      ;; Summary section
      (insert "=== SUMMARY ===\n")
      (insert (format "Binary files: %d\n" (length binary-files)))
      (insert (format "Long files (>2000 lines): %d\n" (length long-files)))
      (insert (format "Large files (>20MB): %d\n\n" (length large-files)))

      ;; Binary files section
      (when binary-files
        (insert "=== BINARY FILES ===\n")
        (insert (format "%-80s %-10s\n" "File Path" "Size"))
        (insert (make-string 90 ?-) "\n")
        (setq binary-files (sort binary-files (lambda (a b) (string< (car a) (car b)))))
        (dolist (result binary-files)
          (let ((filepath (car result))
                (size (caddr result)))
            (insert (format "%-80s %-10s\n"
                           (if (> (length filepath) 80)
                               (concat "..." (substring filepath -77))
                             filepath)
                           (format-file-size size)))))
        (insert "\n"))

      ;; Long files section
      (when long-files
        (insert "=== LONG FILES (>2000 lines) ===\n")
        (insert (format "%-80s %-10s %-10s\n" "File Path" "Lines" "Size"))
        (insert (make-string 100 ?-) "\n")
        (setq long-files (sort long-files (lambda (a b) (> (cadddr a) (cadddr b)))))
        (dolist (result long-files)
          (let ((filepath (car result))
                (size (caddr result))
                (lines (cadddr result)))
            (insert (format "%-80s %-10s %-10s\n"
                           (if (> (length filepath) 80)
                               (concat "..." (substring filepath -77))
                             filepath)
                           (number-to-string lines)
                           (format-file-size size)))))
        (insert "\n"))

      ;; Large files section
      (when large-files
        (insert "=== LARGE FILES (>20MB) ===\n")
        (insert (format "%-80s %-10s %-10s\n" "File Path" "Size" "Lines"))
        (insert (make-string 100 ?-) "\n")
        (setq large-files (sort large-files (lambda (a b) (> (caddr a) (caddr b)))))
        (dolist (result large-files)
          (let ((filepath (car result))
                (size (caddr result))
                (lines (cadddr result)))
            (insert (format "%-80s %-10s %-10s\n"
                           (if (> (length filepath) 80)
                               (concat "..." (substring filepath -77))
                             filepath)
                           (format-file-size size)
                           (if lines (number-to-string lines) "N/A")))))
        (insert "\n"))

      (goto-char (point-min))
      (read-only-mode 1))

    (display-buffer buffer)
    (switch-to-buffer buffer)))

;;;###autoload
(defun bip-analyze-directory ()
  "Interactively scan a directory for binary files, long files (>2000 lines), and large files (>20MB)."
  (interactive)
  (let ((directory (read-directory-name "Directory to analyze: " default-directory)))
    (when (file-directory-p directory)
      (message "Analyzing directory: %s" directory)
      (let ((results (scan-directory-for-issues directory)))
        (display-scan-results results directory)))))

;; Provide the feature
(provide 'bip-analyze-directory)

;;; bip-analyze-directory.el ends here
