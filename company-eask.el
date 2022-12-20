;;; company-eask.el --- Company backend for Eask-file  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/emacs-eask/company-eask
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1") (company "0.8.0") (eask-api "0.1.0"))
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

(require 'company)
(require 'eask-api)

(defgroup company-eask nil
  "Company completion for Eask-file."
  :prefix "company-eask-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/emacs-eask/company-eask"))

;; (defun company-eask--add-keywords (&rest _)
;;   "Add keywords to variable `company-keywords-alist'."
;;   (unless (assoc 'eask-mode company-keywords-alist)
;;     (push `(eask-mode . ,eask-file-keywords) company-keywords-alist)))

;;(add-hook 'eask-mode-hook #'company-eask--add-keywords)

(defun company-eask--candidates ()
  ""
  eask-file-keywords)

(defun company-eask--annotation (candidate)
  ""
  )

(defun company-eask--doc-buffer (candidate)
  ""
  (company-doc-buffer
   (if (ignore-errors (describe-function (intern (format "eask-f-%s" candidate))))
       (with-current-buffer "*Help*" (buffer-string))
     "")))

;;;###autoload
(defun company-eask (command &optional arg &rest ignored)
  "Company backend for Eask-file.

Arguments COMMAND, ARG and IGNORED are standard arguments from `company-mode`."
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-eask))
    (prefix (company-grab-symbol))
    (candidates (company-eask--candidates))
    (annotation (company-eask--annotation arg))
    (doc-buffer (company-eask--doc-buffer arg))))

(provide 'company-eask)
;;; company-eask.el ends here
