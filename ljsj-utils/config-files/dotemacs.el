(require 'cl)

(setq debug-on-error t)

;; Disallow annoying startup message
(setq inhibit-startup-message t)

;;; the global site lisp
(if (equal system-type "gnu/linux")
    (add-to-list 'load-path "/usr/share/emacs/site-lisp")
    (add-to-list 'load-path "/opt/local/share/emacs/site-lisp"))

;;; my location for external packages.
(add-to-list 'load-path (expand-file-name "~/.emacs.d/site-lisp"))

(global-font-lock-mode t)

;;; useful stuff
(setq column-number-mode t)
(setq line-number-mode t)

(setq default-major-mode 'text-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'tex-mode-hook 'turn-on-auto-fill)

;; Use spaces for tabs
(setq-default indent-tabs-mode nil)

;;; --------------------------------------------------------------------------
;;; php mode
;;; --------------------------------------------------------------------------

(setq auto-mode-alist
  (cons '("\\.php\\w?" . php-mode) auto-mode-alist))
(autoload 'php-mode "php-mode" "PHP mode." t)


;;;---------------------------------------------------------------------------
;;; commenting
;;;---------------------------------------------------------------------------

(global-set-key [(control c) (control c)] 'comment-region)

(global-set-key [(control c) (control x)] 'uncomment-region)


;;;---------------------------------------------------------------------------
;;; Comment line insertion.
;;;---------------------------------------------------------------------------

(defun leading-comment-for-mode ()
  (let ((current-mode major-mode))
    (princ major-mode)
    (cond ((eq current-mode 'emacs-lisp-mode)
           ";;;")
          ((eq current-mode 'sh-mode)
           "###")
          (t "///"))))

    
;;; --------------------------------------------------------------------------

(defun insert-comment-line ()
  (interactive)
  (princ (format "%s --------------------------------------------------------------------------\n"
                 (leading-comment-for-mode)) (current-buffer)))

;;; --------------------------------------------------------------------------

(defun insert-comment-block ()
  (interactive)
  (insert-comment-line)
  (princ (format "%s " (leading-comment-for-mode)) (current-buffer))
  (save-excursion 
    (princ "\n" (current-buffer))
    (insert-comment-line)))

;;; --------------------------------------------------------------------------

(defun insert-end-of-file-comment ()
  (interactive)
  (princ (format "%s ***************************************************************************\n"
                 (leading-comment-for-mode)) (current-buffer))
  (princ (format "%s *                              End of File                                *\n"
                 (leading-comment-for-mode)) (current-buffer))

  (princ (format "%s ***************************************************************************\n"
                 (leading-comment-for-mode)) (current-buffer)))
                                   
;;; -------------------------------------------------------------------------- 
;;; c-; does not work on some terminals, so we provide an alternative 
;;; -------------------------------------------------------------------------- 

(global-set-key [(control \;)] 'insert-comment-line)

(global-set-key [(control c) (control l)] 'insert-comment-line)

;;; -------------------------------------------------------------------------- 
;;; for symmetry we provide c-c m-l 
;;; -------------------------------------------------------------------------- 

(global-set-key [(meta \;)] 'insert-comment-block)

(global-set-key [(control c) (meta l)] 'insert-comment-line)

;;; -------------------------------------------------------------------------- 
;;; again, c-; does not work on some terminals 
;;; -------------------------------------------------------------------------- 

(global-set-key [(meta control \;)] 'insert-end-of-file-comment)

(global-set-key [(control c) (meta \;)] 'insert-end-of-file-comment)

;;; --------------------------------------------------------------------------

(global-set-key [(control p)] 'previous-input)

(global-set-key [(control ,)] 'slime-interrupt)


;;; ***************************************************************************
;;; *                              End of File                                *
;;; ***************************************************************************