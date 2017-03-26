;;; popup-edit-menu.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Put a description of the package here

;;; Code:

;; code goes here

(defun popup-edit-menu-map ()
  "Return a keymap equivalent to the menu bar.
The contents are the items that would be in the menu bar whether or
not it is actually displayed."
  (run-hooks 'activate-menubar-hook 'menu-bar-update-hook)
  (let* ((local-menu (and (current-local-map)
			  (lookup-key (current-local-map) [menu-bar])))
	 (global-menu (lookup-key global-map [menu-bar edit]))
	 ;; If a keymap doesn't have a prompt string (a lazy
	 ;; programmer didn't bother to provide one), create it and
	 ;; insert it into the keymap; each keymap gets its own
	 ;; prompt.  This is required for non-toolkit versions to
	 ;; display non-empty menu pane names.
	 (minor-mode-menus
	  (mapcar
           (lambda (menu)
             (let* ((minor-mode (car menu))
                    (menu (cdr menu))
                    (title-or-map (cadr menu)))
               (or (stringp title-or-map)
                   (setq menu
                         (cons 'keymap
                               (cons (concat
                                      (capitalize (subst-char-in-string
                                                   ?- ?\s (symbol-name
                                                           minor-mode)))
                                      " Menu")
                                     (cdr menu)))))
               menu))
	   (minor-mode-key-binding [menu-bar])))
	 (local-title-or-map (and local-menu (cadr local-menu)))
	 (global-title-or-map (cadr global-menu)))
    (or (null local-menu)
	(stringp local-title-or-map)
	(setq local-menu (cons 'keymap
			       (cons (concat (format-mode-line mode-name)
                                             " Mode Menu")
				     (cdr local-menu)))))
    (or (stringp global-title-or-map)
	(setq global-menu (cons 'keymap
			        (cons "Edit Menu"
				      (cdr global-menu)))))
    ;; Supplying the list is faster than making a new map.
    ;; FIXME: We have a problem here: we have to use the global/local/minor
    ;; so they're displayed in the expected order, but later on in the command
    ;; loop, they're actually looked up in the opposite order.
    (apply 'append
           global-menu
           (list 'keymap (list 'separator-mode "--"))
           local-menu
           minor-mode-menus)))
           
(defun popup-edit-menu (event prefix)
  "Popup a menu like either `mouse-major-mode-menu' or `mouse-popup-menubar'.
Use the former if the menu bar is showing, otherwise the latter."
  (declare (obsolete nil "23.1"))
  (interactive "@e\nP")
  (run-hooks 'activate-menubar-hook 'menu-bar-update-hook)
  (popup-menu
   (if (zerop (or (frame-parameter nil 'menu-bar-lines) 0))
       (mouse-menu-bar-map)
     (popup-edit-menu-map))
   event prefix))

(provide 'popup-edit-menu)
;;; popup-edit-menu.el ends here