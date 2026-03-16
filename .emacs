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


(setq evil-normal-state-cursor '(box "light blue")
      evil-insert-state-cursor '(bar "medium sea green")
      evil-visual-state-cursor '(hollow "orange")
      evil-replace-state-cursor '(box "red"))   

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("org"   . "https://orgmode.org/elpa/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))

(unless (package-installed-p 'org)
  (package-install 'org))

(unless (package-installed-p 'undo-fu)
  (package-install 'undo-fu))


;;auto completes and fuzzy searches
(ido-mode 1)

(setq completion-styles '(basic partial-completion flex)
      completion-category-defaults nil
      completion-category-overrides '((file (styles basic partial-completion)))
      completion-cycle-threshold 3
      completion-flex-nospace nil
      completion-pcm-complete-word-inserts-delimiters t
      completion-pcm-word-delimiters "-_./:| "
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t)

(setq tab-always-indent 'complete)

(setq completions-format 'one-column
      completions-max-height 20
      completions-detailed t
      completion-auto-help 'visible
      completion-auto-select 'second-tab)


(setq enable-recursive-minibuffers t
      minibuffer-depth-indicate-mode t)

;; Enable Evil
(require 'evil)
(evil-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-vivendi))
 '(package-selected-packages
   '(auto-async-byte-compile compile-angel completion-preview evil
			     org-babel-eval-in-repl org-roam undo-fu
			     use-package xclip)))
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

;;(display-time-mode 1)          ;; Display time in mode line / tab bar
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

;;completion preview and hook to avoid confliction with corfu mode
(use-package completion-preview                                   
  :ensure t                                                       
  :config                                                         
  (global-completion-preview-mode 1)                              
  (setq completion-preview-exact-match-only t                     
        completion-preview-minimum-symbol-length 3                
        completion-preview-idle-delay 0.3)                        
  (add-hook 'corfu-mode-hook                                      
            (lambda ()                                            
              (setq-local completion-preview-mode nil))))   

(setq org-agenda-files
      '("~/RoamDir"
	))

(use-package org-roam
	     :ensure t
	     :init
	     (setq org-roam-v2-ack t)
	     :custom
	     (org-roam-directory "/home/sierra/RoamDir")
	     (org-roam-completion-everywhere t)
	     (org-roam-db-autosync-mode)
	     (org-roam-db-location (expand-file-name "/home/sierra/RoamDir/org-roam.db"))

	     :bind
	     (("C-c n l" . org-roam-bugger-toggle)
	      ("C-c n f" . org-roam-node-find)
	      ("C-c n i" . org-roam-node-insert)
	      ("C-c n r" . org-roam-node-random)
	      
	      :map org-mode-map
	      ("C-c o" . org-open-at-point)
	      )
	     :config
	     (org-roam-db-autosync-mode)

  (push 'org-self-insert-commands completion-preview-commands))


;;(use-package corfu
;;  :ensure t
;;  :custom
;;  (corfu-auto t)
;;  (corfu-auto-delay 0.2)
;;  (corfu-auto-prefix 2)
;;  (corfu-cycle t)
;;  (corfu-preselect 'prompt)
;;  (corfu-on-exact-match nil)
;;  (corfu-preview-current 'insert)
;;  (corfu-quit-no-match 'seperator)
;;
;;  :bind
;;  (:map corfu-map
;;	("TAB" . corfu-insert)
;;	([tab] . corfu-insert)
;;	("C-n" . corfu-next)
;;	("C-p" . corfu-previous)
;;	("M-d" . corfu-popupinfo-toggle))
;;  :init
;;  (global-corfu-mode))





(require 'evil)
(evil-mode 1)

(setq ispell-dictionary "british")   

(global-visual-line-mode t)

(setq inhibit-startup-screen t)

(menu-bar-mode 0)
(tool-bar-mode 0)

;;garbage collection code
(defun my-minibuffer-setup-hook ()
    (setq gc-cons-threshold most-positive-fixnum))

(defun mt-minibuffer-exit-hook ()
    (setq gc-cons-threshold 80000000))

(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

;; put file automatically in variable pitch mode
(add-hook 'org-mode-hook 'variable-pitch-mode)

;; allow text to fill the window in org mode
(add-hook 'org-mode-hook 'visual-line-mode)

;;indent org mode for readibility
(add-hook 'org-mode-hook #'org-indent-mode)

;;improve font rendering for mixed content
(setq org-emphasis-alist
      '(("*" bold)
	("/" italic)
	("_" underline)
	("=" code)
	("~" verbatim)
	("+" strike-through)))

;; hide markup in org mode
(setq org-hide-emphasis-markers t)

;; use Cca for agenda and Ccl to store links in org mode
(define-key global-map "\C-cl" 'org-store-link)

(define-key global-map "\C-cl" 'org-agenda)

;; setup smex to run instead of fidp vertical mode as its ewww, check its working lololol next restart
(global-set-key (kbd "M-x") 'smex)
;;(global-set-key (kbd "M-x") 'smex-major-mode-commands)

;;move backups to the saves directory
(setq backup-directory-alist '(("." . "~/.emacs_saves")))

;; highlighting persistence
(defun highlight-remove-all ()
  (interactive)
  (hi-lock-mode -1)
  (hi-lock-mode 1))

(defun search-highlight-persist ()
    (highlight-regexp (car-safe (if search-regexp
				    regexp-search-ring
				    search-ring)) (facep 'hi-yellow)))

(defadvice evil-search-incrementally (after evil-search-hl-persist activate)
  (highlight-remove-all)
  (search-highlight-persist))

(defadvice isearch-exit (after isearch-hl-persist activate)
    (highlight-remove-all)
    (search-highlight-persist))

(require 'calendar)

 (defun my/modeline-islamic-date ()
   "Return Islamic (Hijri) date as a string."
   (let* ((date (calendar-current-date))
	  (islamic (calendar-islamic-date-string date)))
     (format "🕌 %s" islamic)))

 (defun my/modeline-local-date ()
   "Return local Gregorian date."
   (format-time-string "📅 %Y-%m-%d"))

 (defun my/modeline-parent-and-file ()
   "Return parent directory and filename/buffer name."
   (let* ((file (or (buffer-file-name) (buffer-name)))
	  (dir  (if (buffer-file-name)
		    (file-name-nondirectory
		     (directory-file-name (file-name-directory file)))
		  "")))
     (format "📁 %s/%s" dir (file-name-nondirectory file))))

(setq-default mode-line-format
	      (append mode-line-format
	       '(" "
		 evil-mode-line-tag
		 " "
		 (:eval (my/modeline-islamic-date))
		 " | "
		 (:eval (my/modeline-local-date))
		 " | "
		 (:eval (my/modeline-parent-and-file))
		 " | %l:%c  %m  %p")))
(require 'json)

(defvar my/ollama-default-model "mistral-small3.2:24b"
  "Default Ollama model to use for synchronous requests.")

(defun my/ollama--decode-json-stream (raw)
  "Extract and decode all JSON objects from RAW Ollama output."
  (let ((pos 0)
        (result ""))
    (while (string-match "{[^}]*}" raw pos)
      (let* ((json-str (match-string 0 raw))
             (json (ignore-errors (json-parse-string json-str :object-type 'alist)))
             (resp (alist-get 'response json)))
        (when resp
          (setq result (concat result resp))))
      (setq pos (match-end 0)))
    result))

(defun my/ollama-send-buffer-sync (use-separate-buffer)
  "Send buffer contents + user prompt to Ollama synchronously.
With prefix argument USE-SEPARATE-BUFFER, show response in a new buffer."
  (interactive "P")
  (let* ((model my/ollama-default-model)
         (prompt (read-string "Additional prompt: "))
         (buf-text (buffer-substring-no-properties (point-min) (point-max)))
         (payload (json-encode
                   `(("model" . ,model)
                     ("prompt" . ,(format "%s\n\n---\n\n%s" prompt buf-text)))))
         (response-buffer (get-buffer-create "*Ollama Response*"))
         (raw-output ""))

    ;; Capture raw JSON stream
    (with-temp-buffer
      (call-process "curl" nil t nil
                    "-s"
                    "-X" "POST"
                    "http://localhost:11434/api/generate"
                    "-H" "Content-Type: application/json"
                    "-d" payload)
      (setq raw-output (buffer-string)))

    ;; Decode JSON fragments into clean text
    (let ((clean (my/ollama--decode-json-stream raw-output)))
      (if use-separate-buffer
          (with-current-buffer response-buffer
            (erase-buffer)
            (insert clean)
            (goto-char (point-min))
            (display-buffer response-buffer))
        (save-excursion
          (goto-char (point-max))
          (insert "\n\n--- Ollama Response ---\n\n" clean))))))



;;ediff comaprisons
(setq ediff-keep-variants nil)
(setq ediff-make-buffers-readonly-at-startup nil)
(setq ediff-merge-revisions-with-ancestor t)
(setq ediff-show-clashes-only t)
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-window-plain)

