(add-to-list 'load-path "~/.emacs.d/site-lisp/emacs-application-framework/")
(require 'eaf)
(require 'eaf-browser)
(require 'eaf-pdf-viewer)
(require 'eaf-music-player)
(require 'eaf-video-player)
(require 'eaf-js-video-player)
(require 'eaf-image-viewer)
(require 'eaf-rss-reader)
(require 'eaf-terminal)
(require 'eaf-markdown-previewer)
(require 'eaf-org-previewer)
(require 'eaf-camera)
(require 'eaf-git)
(require 'eaf-file-manager)
(require 'eaf-mindmap)
(require 'eaf-mind-elixir)
(require 'eaf-system-monitor)
(require 'eaf-file-browser)
(require 'eaf-file-sender)
(require 'eaf-airshare)
(require 'eaf-jupyter)
(require 'eaf-2048)
(require 'eaf-markmap)
(require 'eaf-map)
(require 'eaf-demo)
(require 'eaf-vue-demo)
(require 'eaf-vue-tailwindcss)
(require 'eaf-pyqterminal)
(require 'eaf-video-editor)
;; Set up package.el to work with MELPA
;; Download Evil
(unless (package-installed-p 'evil)
  (package-install 'evil)) 

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; goto normal mode to use melpa then use I and x to make the installation, this is needed for smex

(unless (package-installed-p 'undo-fu)
  (package-install 'undo-fu))

;; Enable Evil
(require 'evil)
(evil-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-vivendi))
 '(package-selected-packages '(smex alert org-alert org-notify evil undo-fu)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(evil-set-register ?u (vconcat ":!uniq" (kbd "RET"))) ;;use @u to get uniques
(evil-set-register ?p (vconcat "\"+p")) ;; use @p to paste


(evil-set-undo-system 'undo-redo)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)

select-enable-clipboard nil
(xclip-mode)

(display-time-mode 1)          ;; Display time in mode line / tab bar

;; Customize time display
(setq display-time-load-average nil
      display-time-format "%l:%M %p %b %d W%U"
      display-time-world-time-format "%a, %d %b %I:%M %p %Z"
      display-time-world-list
      '(("Etc/UTC" "UTC")
        ("Europe/Athens" "Athens")
        ("America/Los_Angeles" "Seattle")
        ("America/Denver" "Denver")
        ("America/New_York" "New York")
        ("Pacific/Auckland" "Auckland")
        ("Asia/Shanghai" "Shanghai")
        ("Asia/Kolkata" "Hyderabad")))
(setq org-ellipsis " ▾"
      org-startup-folded 'content
      org-cycle-separator-lines 2
      org-fontify-quote-and-verse-blocks t)

;; Indent org-mode buffers for readability
(add-hook 'org-mode-hook #'org-indent-mode)

;; Set up Org Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)))
(use-package elfeed
    :custom
    (elfeed-db-directory
     (expand-file-name "elfeed" user-emacs-directory))
     (elfeed-show-entry-switch 'display-buffer)
    :bind
    ("C-c w e" . elfeed))

(add-to-list 'load-path "~/.emacs.d/alert-master/")
(require 'alert)
(require 'org-alert)
(package-initialize)
;;(use-package org-alert
;;    :load-path "~/.emacs.d/alert-master/"
;;    :ensure t
;;    :custom (alert-default-style 'notifications) ;;notifications as were on linux, osx-notifier for apple
;;    :config
;;    (setq org-alert-interval 300
;;	org-alert-notification-title "Org Alert Reminder!")
;;    (org-alert-enable))
(use-package org-alert
               :load-path "~/.emacs.d/alert-master/"
                 :ensure nil
                   :custom
                     (alert-default-style 'notifications)
                       :config
                         (setq org-alert-interval 300
                                       org-alert-notification-title "Org Alert Reminder!")
                           (org-alert-enable))

;; anti garbage collector bloat code
(defun my-minibuffer-setup-hook ()
  (setq gc-cons-threshold most-positive-fixnum))

(defun my-minibuffer-exit-hook ()
  (setq gc-cons-threshold 800000))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

(setq inhibit-startup-screen t) ;;remove tutorial page and menu mode/tool bar
(menu-bar-mode 0)
(tool-bar-mode 0)

;;change org mode bindings
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)

;;hide markup in org mode
(setq org-hide-emphasis-markers t)

;;beautify org mode
  (let* ((variable-tuple
          (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
                ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                ((x-list-fonts "Verdana")         '(:font "Verdana"))
                ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

    (custom-theme-set-faces
     'user
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))
;; automatically put the file in variable pitch mode upon entering an org mode buffer
(add-hook 'org-mode-hook 'variable-pitch-mode)
;;allow the text to fill the window with org mode
(add-hook 'org-mode-hook 'visual-line-mode)

;;% can be used to jump back and forth between matching braces/brackets in emacs/vim

(setq org-directory "~/EmacsStuff/org/")

;;somewhere to put the autosaves
(setq backup-directory-alist '(("." . "~/.emacs_saves")))
;;broken search instead of using findfile, has some autocomplete 
(ido-mode 1)


;; do ido mode for mx instead 
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands)
  ;; This is your old M-x.
  (global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
;;;; Duplicates - handling duplicate files in dired

;;;; Find marked files in a dired buffer and display which ones have identical contents
;;;; (C)2011 Justin Heyes-Jones
;;;; How to use... mark files you're interest in the dired window, perhaps with `dired-mark-files-regexp'
;;;; then `dired-show-marked-duplicate-files' will open a buffer with a list of duplicated files
;;;; Also `dired-mark-duplicate-files' will mark only superfluous duplicates of the files allowing you to move
;;;; them to another folder or delete them 

(defvar *duplicate-buffer* nil)

(defun md5-file(filename)
  "Open FILENAME, load it into a buffer and generate the md5 of its contents"
  (interactive "f")
  (with-temp-buffer 
    (insert-file-contents filename)
    (md5 (current-buffer))))

(defun dired-get-duplicate-marked-file-map()
  "return a hashmap of files in the current dired buffer keyed by the md5 of the contents of each file. Where
multiple files share the same md5 they will all be present in the value for that key"
  (let ((md5-map (make-hash-table :test 'equal :size 40)))
    (if (eq major-mode 'dired-mode)
   (let ((filenames (dired-get-marked-files)))
     (let ((num-files (length filenames))
      (count 0))
       (let ((progress-reporter 
         (make-progress-reporter "Determining which files are duplicated..." 0 num-files)))
         (dolist (fn filenames)
      (incf count)
;		(sit-for 0.3)
      (progress-reporter-update progress-reporter count)
      (if (file-regular-p fn)
          (let ((md5 (md5-file fn)))
            (let ((map-entry (gethash md5 md5-map nil)))
         (puthash md5 (cons fn map-entry) md5-map)))))
         (progress-reporter-done progress-reporter)))))
    md5-map))

(defun show-duplicate(key value)
  "Given the KEY and VALUE of a map entry for a given md5, if there is more than one filename in the list 
of files then display them as duplicates"
  (if (> (length value) 1)
      (let ((str (format "%d duplicates of %s\n" (length value) (first value))))
   (dolist (filename (rest value))
     (setf str (concat str (format "%s\n" filename))))
   (insert str))))

(defun dired-show-marked-duplicate-files() 
  "For each marked file in a dired buffer determine which have the same contents"
  (interactive)
  (if (eq major-mode 'dired-mode)
      (let ((md5-map (dired-get-duplicate-marked-file-map)))
   (setf *duplicate-buffer* (get-buffer-create "Duplicated files"))
   (goto-line 1 *duplicate-buffer*)
   (erase-buffer)
   (maphash #'show-duplicate md5-map))
    (error (format "Not a Dired buffer \(%s\)" major-mode))))

(defun dired-mark-duplicates(key value)
  "KEY is the MD5 of some set of 1 or more files in the dired buffer, while VALUE is a list of filenames. In order to mark 
only duplicates we'll ignore the first file arbitrarily and mark the remaining ones one. More complicated or interactive 
strategies could be considered such as keeping the one with the shorter filename, most recent modified date and so on."
  (let ((rest (rest value)))
    (when rest 
      (dolist (file rest)
   (dired-goto-file file)
   (dired-mark 1)))))

(defun dired-mark-duplicate-files() 
  "For each marked file in a dired buffer determine which have the same contents and then leave only the duplicates marked"
  (interactive)
  (if (eq major-mode 'dired-mode)
      (let ((md5-map (dired-get-duplicate-marked-file-map)))
   (dired-unmark-all-marks)
   (maphash #'dired-mark-duplicates md5-map))
    (error (format "Not a Dired buffer \(%s\)" major-mode))))
