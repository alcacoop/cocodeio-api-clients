;;;; Copyright 2011-2012 Alca Società Cooperativa a r.l.

;;; Create new shared session on cocode.io from your emacs

;;; INSTALL:
;;; - copy cocodeio.el into your emacs load path
;;; - load cocodeio.el and add some shortcut from yout dotemacs 
;;;
;;; (require 'cocodeio)
;;; ;;; add a "cocodeio session from buffer" shortcut `C-c c b'
;;; (global-set-key [(control ?c) (?c) (?b)]
;;;                 'cocodeio-create-session-from-buffer)
;;;
;;; ;;; add a "cocodeio session from region" shortcut `C-c c r'
;;; global-set-key [(control ?c) (?c) (?r)]
;;;                'cocodeio-create-session-from-region)
;;;
;;;
;;; CONFIGURE:
;;; - configure and save your credentials using customize-group
;;;  
;;; (customize-group cocodeio)

(require 'json)

(defcustom cocodeio-base-url "https://cocode.io"
  "Address of the cocode.io server"
  :type 'string
  :group 'cocodeio)

(defcustom cocodeio-username "username"
  "cocode.io Beta Invited Username"
  :type 'string
  :group 'cocodeio)

(defcustom cocodeio-password "password"
  "cocode.io Beta Invited Username"
  :type 'string
  :group 'cocodeio)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; (require 'cocodeio)
;;;
;;; (global-set-key [(control ?c) (?c) (?b)]  'cocodeio-create-session-from-buffer)  
;;;;;;;;;;;;;;;;;;;; `C-c c b'
;;; (global-set-key [(control ?c) (?c) (?r)]  'cocodeio-create-session-from-region)  
;;;;;;;;;;;;;;;;;;;; `C-c c r'

(defun cocodeio-create-session-from-buffer(description)
  (interactive "sCoCode Session Description: ")
  (let ((files (cocodeio--files-from-buffer)))
    (cocodeio--create-session description files)))

(defun cocodeio-create-session-from-region(description)
  (interactive "sCoCode Session Description: ")
  (let ((files (cocodeio--files-from-region)))
    (cocodeio--create-session description files)))

(defun cocodeio--files-from-buffer()
  (let ((file (list (buffer-name) (buffer-substring-no-properties 1 (point-max)))))
    (list file)))

(defun cocodeio--files-from-region()
  (let ((file (list (buffer-name) (buffer-substring-no-properties (region-beginning)
                                                                  (region-end)))))
    (list file)))

(defun cocodeio--get-response-body (&optional buffer)
  "Return the body of the response in BUFFER.
   BUFFER defaults to `current-buffer'."
  (with-current-buffer (or buffer (current-buffer))
    (save-excursion
      (goto-char (point-min)) ; go to the start
      (search-forward "\n\n" nil t) ; search header end
      (buffer-substring-no-properties (point) (point-max))))) ; return substring

(defun cocodeio--is-status-ok (&optional buffer)
  "Return the body of the response in BUFFER.
   BUFFER defaults to `current-buffer'."
  (with-current-buffer (or buffer (current-buffer))
    (save-excursion
      (goto-char (point-min)) ; go to the start
      (not (eq nil (search-forward "HTTP/1.1 200 " nil t))))))
      

(defun cocodeio--auth-data()
  (format "Basic %s"
          (base64-encode-string 
           (format "%s:%s" 
                   cocodeio-username 
                   cocodeio-password))))

(defun cocodeio--create-session(description files)
  (let ((url-request-method "POST")
        (url-request-extra-headers (list '("Content-Type" . "application/json")
                                         (cons "Authorization" (cocodeio--auth-data))))
        (url-request-data (concat "{"
                                  "\"Description\": \"" description "\","
                                  "\"Files\":["
                                  (mapconcat (lambda (file)
                                               (concat "{" 
                                                       "\"Filename\": \"" (car file) "\","
                                                       "\"Content\": " (json-encode-string (car (cdr file))) 
                                                       "}"
                                                       ))
                                             files
                                             ","
                                             )
                                  "]"
                                  "}"))
    )                               ; end of let varlist
  (url-retrieve (concat cocodeio-base-url "/api/session")
                ;; CALLBACK
                (lambda (status)
                  ;(switch-to-buffer (current-buffer))
                  

                  (if (cocodeio--is-status-ok)
                      (browse-url (cocodeio--get-response-body(current-buffer)))
                    (minibuffer-message 
                     "cocodeio: error creating a cocodeio shared session.")
                  )
                ))))

(provide 'cocodeio)