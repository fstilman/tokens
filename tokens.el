;;; tokens.el --- a token killer -*- lexical-binding: t -*-

;; Copyright (C) 2023 Federico G. Stilman

;; Author: Federico G. Stilman <fstilman@gmail.com>
;; Maintainer: Federico G. Stilman <fstilman@gmail.com>
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
  '((number . "\\b[0-9]+\\b")
    (email . "\\b[A-Za-z0-9]+@[A-Za-z0-9]+\\.[A-Za-z]\\{2,\\}\\b")
    (ip . "\\b\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\b"))
  "List of supported tokens.
Each token is defined by a dotted pair where the car is a symbol and
the cdr is a regular expression for matching this kind of token."
  :type '(alist :key-type symbol :value-type regexp)
  :group 'tokens)

(defun tokens-regex-for-token (token-type)
  "Return a regex for matching tokens of type TOKEN-TYPE."
  (cdr (assoc token-type tokens-regex)))

(defun tokens-kill-ring-save (token-type &optional match-number)
  "Search the current line for the Nth MATCH-NUMBER token.
The search is done for TOKEN-TYPE tokens.  When a match is found
it is saved to the kill ring.  If MATCH-NUMBER is ommited it defaults
to 1."
  (interactive
   (list (intern (completing-read
                  "Enter token type: "
                  '(number email)
                  nil
                  t))
         (prefix-numeric-value current-prefix-arg)))
  (save-excursion
    (beginning-of-line)
    (let ((match-number (or match-number 1)))
      (when (search-forward-regexp
             (tokens-regex-for-token token-type)
             (line-end-position)
             t
             match-number)
        (message "Saved: %s"  (match-string 0))
        (kill-ring-save (match-beginning 0) (match-end 0))))))

(provide 'tokens)
;;; tokens.el ends here
