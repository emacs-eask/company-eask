;;; company-eask.el --- Company backend for Eask-file  -*- lexical-binding: t; -*-

;; Copyright (C) 2022-2026  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/emacs-eask/company-eask
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (company "0.8.0") (eask "0.1.0"))
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Company backend for Eask-file
;;

;;; Code:

(require 'cl-lib)
(require 'finder)

(require 'company)
(require 'eask-core)

(defgroup company-eask nil
  "Company completion for Eask-file."
  :prefix "company-eask-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/emacs-eask/company-eask"))

(defcustom company-eask-complete-package-name t
  "Set to non-nil to enable package name completion."
  :type 'boolean
  :group 'company-eask)

(defvar company-eask--sources (mapcar (lambda (source)
                                        (eask-2str (car source)))
                                      eask-source-mapping)
  "A list of sources.")

(defvar company-eask--packages (mapcar (lambda (source)
                                         (eask-2str (car source)))
                                       package-alist)
  "A list of packages.")

(defvar company-eask--keywords (mapcar (lambda (source)
                                         (eask-2str (car source)))
                                       finder-known-keywords)
  "A list of keywords.")

;;
;; (@* "Core" )
;;

(defun company-eask--improve-doc (symbol)
  "Display only the directive name (SYMBOL), and replace alias description."
  (let* ((buf-str (with-current-buffer (help-buffer) (buffer-string)))
         (str (eask-s-replace "eask-f-" "" buf-str))
         (str (eask-s-replace
               " is a Lisp closure "
               (format " is an alias for ‘%s’ "
                       (propertize (eask-2str symbol)
                                   'face `( :foreground "cyan"
                                            :underline t)))
               str)))
    str))

(defun company-eask--scope-symbol ()
  "Return the current scope symbol in the buffer."
  (save-excursion
    (let ((start) (end)
          (pt (point)))
      (when (search-backward "(" nil t)
        (setq start (point))
        (forward-sexp 1)
        (setq end (point)))
      (when (and start end
                 (< start pt) (< pt end))
        (goto-char (1+ start))
        (thing-at-point 'symbol)))))

(defun company-eask--scope-p (&rest scopes)
  "Return non-nil if the current scope is in SCOPES."
  (let ((scope (company-eask--scope-symbol)))
    (member scope scopes)))

(defun company-eask--scope-first-p ()
  "Return non-nil if current point at the first scope."
  (or (equal (char-before) ?\()
      (save-excursion (forward-symbol -1)
                      (equal (char-before) ?\())))

(defun company-eask--candidates ()
  "Return a list of candidates."
  (if (company-in-string-or-comment)
      (append (when (company-eask--scope-p "source")
                company-eask--sources)
              (when (company-eask--scope-p "keywords")
                company-eask--keywords)
              (when (and company-eask-complete-package-name
                         (company-eask--scope-p "depends-on"))
                company-eask--packages))
    (append (when (company-eask--scope-p "source")
              company-eask--sources)
            (when (company-eask--scope-first-p)
              eask-file-keywords))))

(defun company-eask--annotation (candidate)
  "Return annotation for CANDIDATE."
  (cond ((member candidate eask-file-keywords)
         "(Directive)")
        ((member candidate company-eask--sources)
         "(Source)")
        ((member candidate company-eask--keywords)
         "(Keyword)")
        ((member candidate company-eask--packages)
         "(Package)")))

(defun company-eask--doc-buffer (candidate)
  "Return document for CANDIDATE."
  (let ((cand (intern candidate)))
    (cond
     ;; (Directive)
     ((member candidate eask-file-keywords)
      (let ((symbol (intern (format "eask-f-%s" candidate))))
        (save-window-excursion
          (ignore-errors
            (cond
             ((fboundp symbol) (describe-function symbol))
             (t (signal 'user-error nil)))
            (company-doc-buffer (company-eask--improve-doc symbol))))))
     ;; (Source)
     ((member candidate company-eask--sources)
      (company-doc-buffer (alist-get cand eask-source-mapping)))
     ;; (Keyword)
     ((member candidate company-eask--keywords)
      (company-doc-buffer (alist-get cand finder-known-keywords)))
     ;; (Package)
     ((member candidate company-eask--packages)
      (when-let* ((desc (car (alist-get cand package-alist))))
        (company-doc-buffer (package-desc-summary desc)))))))

;;
;; (@* "Entry" )
;;

;;;###autoload
(defun company-eask (command &optional arg &rest _)
  "Company backend for Eask-file.

Arguments COMMAND and ARG are standard arguments from `company-mode`."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-eask))
    (prefix (and (derived-mode-p 'eask-mode)
                 (company-grab-symbol)
                 'stop))
    (candidates (company-eask--candidates))
    (annotation (company-eask--annotation arg))
    (doc-buffer (company-eask--doc-buffer arg))))

(provide 'company-eask)
;;; company-eask.el ends here
