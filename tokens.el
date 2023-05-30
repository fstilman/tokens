;;; tokens.el --- a token killer -*- lexical-binding: t -*-

;; Copyright (C) 2023 Federico G. Stilman

;; Author: Federico G. Stilman <fstilman@gmail.com>
;; Maintainer: Federico G. Stilman <fstilman@gmail.com>
;; Keywords: matching, convenience
;; Version: 1.0

;;; Commentary:

;; tokens.el provides functions for matching well-known elements on
;; the current line and saving them to the kill ring, for easy
;; yanking.  Tokens or elements are easily customizable through
;; regular expressions.  Included are regular expressions for matching
;; numbers, emails and IP addresses.

;;; Code:

(defgroup entities nil
  "Settings for entities matching on buffers."
  :group 'entities)

(defcustom entities-regex
  '((number . "[0-9]+")
    (email . "\\b[A-Za-z0-9]+@[A-Za-z0-9]+\\.[A-Za-z]\\{2,\\}\\b")
    (ip . "\\b\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\.\\(25[0-5]\\|2[0-4][0-9]\\|[01]?[0-9][0-9]?\\)\\b"))
  "List of supported tokens.
Each token is defined by a dotted pair where the car is a symbol and
the cdr is a regular expression for matching this kind of token."
  :type '(alist :key-type symbol :value-type regexp)
  :group 'entities)

(defun entities-regex-for-entity (entity-type)
  "Return a regex for matching entities of type ENTITY-TYPE."
  (cdr (assoc entity-type entities-regex)))

(defun entities-kill-ring-save (entity-type &optional match-number)
  "Search the current line for the Nth MATCH-NUMBER entity.
The search is done for ENTITY-TYPE tokens.  When a match is found
it is saved to the kill ring.  If MATCH-NUMBER is ommited it defaults
to 1."
  (interactive
   (list (intern (completing-read
                  "Enter entity type: "
                  '(number email)
                  nil
                  t))
         (prefix-numeric-value current-prefix-arg)))
  (save-excursion
    (beginning-of-line)
    (let ((match-number (or match-number 1)))
      (when (search-forward-regexp
             (entities-regex-for-entity entity-type)
             (line-end-position)
             t
             match-number)
        (message "Saved: %s"  (match-string 0))
        (kill-ring-save (match-beginning 0) (match-end 0))))))

(provide 'tokens)
;;; tokens.el ends here
