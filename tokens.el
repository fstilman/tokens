;;; tokens.el --- a token killer -*- lexical-binding: t -*-

;; Copyright (C) 2023 Federico G. Stilman

;; Author: Federico G. Stilman <fede@stilman.org>
;; Maintainer: Federico G. Stilman <fede@stilman.org>
;; Keywords: matching, convenience
;; Version: 1.0

;;; Commentary:

;; tokens.el provides functions for matching well-known elements on
;; the current line and saving them to the kill ring for easy
;; yanking.  This elements, that we call "tokens" are easily
;; customizable through standard regular expressions.
;; Included are regular expressions for matching numbers, emails
;; and IP addresses.

;;; Code:

(defgroup tokens nil
  "Search for a customizable token and save it to the kill ring."
  :group 'tokens)

(defcustom tokens-regex
  '((ip . "\\b\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\b")
    (email . "\\b[a-zA-Z0-9_.%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]\\{2,\\}\\b")
    (date . "\\b\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)\\|\\([0-9]\\{2\\}/[0-9]\\{1,2\\}/[0-9]\\{4\\}\\)\\b")
    (number . "\\b[0-9]+\\b"))
  "List of supported tokens.
Each token is defined by a dotted pair where the CAR is a symbol
representing the token type and the CDR is a regular expression
that should match this type of token."
  :type '(alist :key-type symbol :value-type regexp)
  :group 'tokens)

(defcustom tokens-highlight-match t
  "Whether matched token is highlighted. Defaults to true."
  :type 'boolean
  :group 'tokens)

(defcustom tokens-verbose-match t
  "Whether matched token is shown on echo area. Defaults to true."
  :type 'boolean
  :group 'tokens)

(defun tokens--regex-for-token (token-type)
  "Return a regex for matching tokens of type TOKEN-TYPE."
  (cdr (assoc token-type tokens-regex)))

(defun tokens--token-list ()
    "Return the list of tokens."
  (mapcar 'car tokens-regex))

(defun tokens-kill-ring-save (token-type &optional match-number)
  "Search the current line for the Nth MATCH-NUMBER token.
The search is done for TOKEN-TYPE tokens.  When a match is found
it is saved to the kill ring.  If MATCH-NUMBER is ommited it defaults
to 1."
  (interactive
   (list (intern (completing-read
                  "Enter token type: "
                  (tokens--token-list)
                  nil
                  t))
         (prefix-numeric-value current-prefix-arg)))

  (save-excursion
    (beginning-of-line)
    (let ((match-number (or match-number 1)))
      (when (search-forward-regexp
             (tokens--regex-for-token token-type)
             (line-end-position)
             t
             match-number)
        (tokens--save-to-kill-ring (match-beginning 0) (match-end 0))))))

(defun tokens-kill-ring-save-any (&optional match-number)
  "Search the current line for the Nth (MATCH-NUMBER) token.
The search is done for any type of token.  When a match is found
it is saved to the kill ring.  If MATCH-NUMBER is ommited it defaults
to 1."
  (interactive "P")

  (save-excursion
    (let ((match-number (or match-number 1)))
      (catch 'found
        (dolist (token-type (tokens--token-list))
          (message "Searching for %s" (tokens--regex-for-token token-type))
          (beginning-of-line)

          (when (search-forward-regexp
                 (tokens--regex-for-token token-type)
                 (line-end-position)
                 t
                 match-number)
            (tokens--save-to-kill-ring
             (match-beginning 0) (match-end 0))
            (throw 'found (match-string 0))))))))

(defun tokens--save-to-kill-ring (region-start region-end)
  "Save the region between REGION-START and REGION-END to the kill ring."
  (kill-ring-save region-start region-end)

  (when (and (eq tokens-highlight-match t)
             (functionp 'pulse-momentary-highlight-region))
    (pulse-momentary-highlight-region region-start region-end))

  (when (eq tokens-verbose-match t)
    (message "Saved: %s"
             (buffer-substring-no-properties region-start region-end))))

  
(provide 'tokens)
;;; tokens.el ends here
