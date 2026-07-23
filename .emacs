;;; --- Core UI & Startup ---
(setq inhibit-startup-screen t)
(menu-bar-mode 0)
(tool-bar-mode 0)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)
(global-visual-line-mode t)
(setq ispell-dictionary "british")

;;; --- Package Management & Repositories ---
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("org"   . "https://orgmode.org/elpa/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(dolist (pkg '(org undo-fu evil xclip corfu smex))
  (unless (package-installed-p pkg)
    (package-install pkg)))

;;; --- EAF (Emacs Application Framework) ---
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
(setq eaf-browser-enable-adblocker t)

;; Open every EAF-supported file (PDFs etc.) with `eaf-open' by default.
;; EAF's own advisors already cover `find-file', `org-open-file' and the
;; dired open commands when the two flags below are t (their default);
;; re-adding is harmless (advice-add is idempotent) and guarantees it, and
;; `find-file-other-window' is one EAF misses.
(setq eaf-find-file-advisor-enable t
      eaf-dired-advisor-enable t)
(advice-add #'find-file :around #'eaf--find-file-advisor)
(advice-add #'org-open-file :around #'eaf--find-file-advisor)
(advice-add #'find-file-other-window :around #'eaf--find-file-advisor)
(advice-add #'dired-find-file :around #'eaf--dired-find-file-advisor)
(advice-add #'dired-find-alternate-file :around #'eaf--dired-find-file-advisor)

;;; --- Evil Mode & Registers ---
(require 'evil)
(evil-mode 1)
(setq evil-normal-state-cursor '(box "light blue")
      evil-insert-state-cursor '(bar "medium sea green")
      evil-visual-state-cursor '(hollow "orange")
      evil-replace-state-cursor '(box "red"))

;; EAF buffers handle their own keys (arrows/j/k scroll etc.) via eaf-mode-map,
;; which evil's normal-state maps would shadow — open them in emacs state.
(evil-set-initial-state 'eaf-mode 'emacs)
;; Terminals (incl. the Claude Code session) should accept typing directly.
(evil-set-initial-state 'vterm-mode 'insert)

(evil-set-undo-system 'undo-redo)
(evil-set-register ?u (vconcat ":!uniq" (kbd "RET")))
(evil-set-register ?p (vconcat "\"+p"))
(setq select-enable-clipboard nil)
(xclip-mode 1)

;;; --- Completion & Fuzzy Search ---
(ido-mode 1)
(fido-mode t)
(global-set-key (kbd "M-x") 'smex)

(setq completion-styles '(basic partial-completion flex)
      completion-cycle-threshold 3
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      tab-always-indent 'complete)

(setq completions-format 'one-column
      completions-max-height 20
      completions-detailed t
      completion-auto-help 'visible
      completion-auto-select 'second-tab)

(setq enable-recursive-minibuffers t
      minibuffer-depth-indicate-mode t)

(use-package completion-preview
  :ensure t
  :config
  (global-completion-preview-mode 1)
  (setq completion-preview-exact-match-only t
        completion-preview-minimum-symbol-length 3
        completion-preview-idle-delay 0.3))

(add-hook 'corfu-mode-hook (lambda () (setq-local completion-preview-mode nil)))

;;; --- Org Mode & Roam ---
(setq org-ellipsis " ▾"
      org-startup-folded 'content
      org-cycle-separator-lines 2
      org-fontify-quote-and-verse-blocks t
      org-hide-emphasis-markers t
      ;; A fixed tag column can never line up in a proportional font, which
      ;; leaves tags scattered mid-line — keep them snug against the headline.
      org-tags-column 0
      org-auto-align-tags nil)

;; Modus theme: scaled bold headings, monospace kept for tables/blocks/code.
;; Must be set before the theme is enabled in `custom-set-variables' further
;; down.  The daily-driver Emacs is the 30.2 snap (modus 4.x option names);
;; the first two lines are what that version reads — mixed-fonts is opt-in
;; there, and without it tables render proportional and fall out of shape.
(setq modus-themes-mixed-fonts t
      modus-themes-headings '((0 . (variable-pitch bold 1.4))
                              (1 . (variable-pitch bold 1.25))
                              (2 . (variable-pitch semibold 1.15))
                              (3 . (variable-pitch semibold 1.05))
                              (t . (variable-pitch semibold))))
;; Same effect on the modus 1.x that ships with /usr/bin/emacs (28.2), where
;; mixed fonts are already the default; ignored by modus 4.x.
(setq modus-themes-scale-headings t
      modus-themes-variable-pitch-headings t)

(add-hook 'org-mode-hook (lambda () (setq-local line-spacing 0.1)))

(setq org-emphasis-alist
      '(("*" bold) ("/" italic) ("_" underline) ("=" code) ("~" verbatim) ("+" strike-through)))

(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook #'org-indent-mode)

(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "/home/sierra/RoamDir")
  (org-roam-completion-everywhere t)
  (org-roam-db-location (expand-file-name "/home/sierra/RoamDir/org-roam.db"))
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n r" . org-roam-node-random)
         :map org-mode-map ("C-c o" . org-open-at-point))
  :config
  (org-roam-db-autosync-mode)
  (push 'org-self-insert-commands completion-preview-commands))

;;; --- Media & EMMS Setup ---
(require 'emms-setup)
(emms-all)
(setq emms-player-list '(emms-player-mpv))
(setq emms-source-file-default-directory "/games/phonebckup/NewPipeTunes/")

;;; --- Content Pipeline (Ollama, GPU TTS, Monetized Montage Processing) ---
(require 'json)
(require 'url)

(defvar ollama-default-model "llama3.2:3b")
(defvar content-dev-path "/games/contentdevelopment/")

(defun my/ensure-ollama-running ()
  "Ensure Ollama is running and responsive before continuing."
  (unless (= (call-process "pgrep" nil nil nil "-f" "ollama serve") 0)
    (message "Starting Ollama server...")
    (start-process "ollama-server" "*ollama-server-log*" "ollama" "serve")
    (sleep-for 1))
  
  (let ((tries 0)
        (ready nil))
    (while (and (< tries 20) (not ready))
      (setq ready (= (call-process "curl" nil nil nil "-s" "http://localhost:11434/api/tags") 0))
      (unless ready
        (sleep-for 1)
        (setq tries (1+ tries))))
    (unless ready
      (error "Ollama did not become ready — aborting"))))

(defun ollama--decode-json-stream (raw)
  (let ((pos 0) (result ""))
    (while (string-match "{[^}]*}" raw pos)
      (let* ((json-str (match-string 0 raw))
             (json (ignore-errors (json-parse-string json-str :object-type 'alist)))
             (resp (alist-get 'response json)))
        (when resp (setq result (concat result resp))))
      (setq pos (match-end 0)))
    result))

(defun ollama--insert-response (clean-text)
  (if (or buffer-read-only (not (buffer-name)))
      (let ((out-buf (get-buffer-create "*Ollama-Output*")))
        (with-current-buffer out-buf
          (goto-char (point-max))
          (insert "\n\n--- Ollama Response ---\n\n" clean-text)
          (display-buffer out-buf)))
    (save-excursion
      (goto-char (point-max))
      (insert "\n\n--- Ollama Response ---\n\n" clean-text))))

(defun my/ollama-send-region-sync (&optional use-separate-buffer)
  "Sends region to Ollama. Automatically handles read-only buffers."
  (interactive "P")
  (my/ensure-ollama-running)
  (let* ((buf-text (if (use-region-p)
                       (buffer-substring-no-properties (region-beginning) (region-end))
                     (buffer-substring-no-properties (point-min) (point-max))))
         (prompt (read-string "Instructions for Ollama: "))
         (payload (json-encode `(("model" . ,ollama-default-model)
                                 ("prompt" . ,(concat prompt "\n\n---\n\n" buf-text)))))
         (raw-output ""))
    (message "Waiting for Ollama...")
    (with-temp-buffer
      (call-process "curl" nil t nil "-s" "-X" "POST" "http://localhost:11434/api/generate" "-d" payload)
      (setq raw-output (buffer-string)))
    (let ((clean (ollama--decode-json-stream raw-output)))
      (if use-separate-buffer
          (let ((res-buf (get-buffer-create "*Ollama Response*")))
            (with-current-buffer res-buf (erase-buffer) (insert clean) (display-buffer res-buf)))
        (ollama--insert-response clean)))))

(defun my/story-to-video (filename)
  "Full async pipeline: refine story, exact-sync local GPU TTS + SRT, and multi-input zero-buffer montage."
  (interactive "sOutput filename (without extension): ")
  (unless (use-region-p)
    (user-error "No region active"))

  (message "Step 1/4: Checking Ollama & Refining Text...")
  (my/ensure-ollama-running)

  (let* ((base-dir content-dev-path)
         (raw-text (buffer-substring-no-properties (region-beginning) (region-end)))
         (tmpbuf (get-buffer-create "*story-refine*"))
         (tts-file (expand-file-name (concat filename ".mp3") base-dir))
         (srt-file (expand-file-name (concat filename ".srt") base-dir))
         (video-file (expand-file-name (concat filename ".mp4") base-dir))
         (mc-video (expand-file-name "minecraft.mp4" base-dir))
         (txt-tmp (make-temp-file "story-text-" nil ".txt"))
         (py-tmp (make-temp-file "story-script-" nil ".py")))

    ;; STEP 1: Refine story
    (with-current-buffer tmpbuf
      (erase-buffer)
      (insert raw-text)
      (my/ollama-send-region-sync nil)
      (goto-char (point-min))
      (unless (search-forward "--- Ollama Response ---" nil t)
        (error "Ollama refinement failed"))
      (setq raw-text (string-trim (buffer-substring-no-properties (point) (point-max)))))

    ;; Write the refined text and the GPU-accelerated Python logic
    (with-temp-file txt-tmp (insert raw-text))
    (with-temp-file py-tmp
      (insert "
import sys, re, torch, subprocess, random, math
from pathlib import Path
from TTS.api import TTS
from pydub import AudioSegment

text_file, mp3_out, srt_out, video_in, video_out = sys.argv[1:6]
text = Path(text_file).read_text(encoding='utf-8')

raw_sentences = re.split(r'(?<=[.!?])\\s+', text)
sentences = [s.strip() for s in raw_sentences if s.strip() and re.search(r'[a-zA-Z0-9]', s)]

device = 'cuda' if torch.cuda.is_available() else 'cpu'
tts = TTS(model_name='tts_models/en/ljspeech/vits', progress_bar=False).to(device)

combined_audio = AudioSegment.empty()
srt_content = ''
current_ms = 0

def format_time(ms):
    s, ms = divmod(ms, 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f'{int(h):02}:{int(m):02}:{int(s):02},{int(ms):03}'

for i, sentence in enumerate(sentences, 1):
    tmp_chunk = f'/tmp/chunk_{i}.wav'
    tts.tts_to_file(text=sentence, file_path=tmp_chunk)
    segment = AudioSegment.from_wav(tmp_chunk)
    start_time = current_ms
    end_time = current_ms + len(segment)
    
    srt_content += f'{i}\\n{format_time(start_time)} --> {format_time(end_time)}\\n{sentence}\\n\\n'
    combined_audio += segment
    current_ms = end_time
    Path(tmp_chunk).unlink(missing_ok=True)

combined_audio.export(mp3_out, format='mp3')
Path(srt_out).write_text(srt_content, encoding='utf-8')

# --- BUFFER-FREE MULTI-INPUT MONTAGE PROCESSING ---
def get_video_duration(p):
    cmd = ['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', p]
    return float(subprocess.check_output(cmd).decode().strip())

try:
    v_dur = get_video_duration(video_in)
    safe_v_dur = max(0.5, v_dur - 2.0)
    a_dur = current_ms / 1000.0
    
    safe_clip_len = min(6.0, safe_v_dur * 0.9) if safe_v_dur > 1.0 else safe_v_dur
    num_clips = int(math.ceil(a_dur / safe_clip_len)) + 2
    
    ffmpeg_cmd = ['ffmpeg', '-y']
    concat_inputs = ''
    
    # Bypassing filter fan-out by injecting the source file N separate times
    for idx in range(num_clips):
        start = random.uniform(0, max(0, safe_v_dur - safe_clip_len))
        ffmpeg_cmd.extend(['-ss', f'{start:.3f}', '-t', f'{safe_clip_len:.3f}', '-i', video_in])
        concat_inputs += f'[{idx}:v:0]'
        
    # Finally, add audio as the absolute last input
    ffmpeg_cmd.extend(['-i', mp3_out])
    audio_idx = num_clips
    
    filter_complex = f\"{concat_inputs}concat=n={num_clips}:v=1:a=0[vconcat];[vconcat]fps=30,format=yuv420p,subtitles='{srt_out}'[outv]\"
    
    ffmpeg_cmd.extend([
        '-filter_complex', filter_complex,
        '-map', '[outv]', '-map', f'{audio_idx}:a:0',
        '-c:v', 'libx264', '-preset', 'fast',
        '-c:a', 'aac', '-b:a', '192k',
        '-shortest', video_out
    ])
    subprocess.run(ffmpeg_cmd, check=True)
except Exception as e:
    print(f'FFmpeg Montage composition failed: {e}', file=sys.stderr)
    sys.exit(1)
"))

    ;; STEP 2-4: Run everything cleanly under Python process control
    (message "Step 2-4: Running Vocals and Multi-Input Montage Render on GPU...")
    (make-process
     :name "story-to-video-pipeline"
     :buffer "*story-to-video-out*"
     :command (list "python3" py-tmp txt-tmp tts-file srt-file mc-video video-file)
     :sentinel `(lambda (proc event)
                  (when (string-match-p "finished" event)
                    (ignore-errors 
                      (delete-file ,py-tmp)
                      (delete-file ,txt-tmp)
                      (delete-file ,srt-file))
                    (message "DONE — Monetizable video created: %s" ,video-file))))))

(defun my/ollama-generate-lyrics (topic)
  "Async request to Ollama to write nasheed lyrics."
  (interactive "sNasheed Topic: ")
  (message "Drafting lyrics with Ollama...")
  (let* ((url-request-method "POST")
         (url-request-extra-headers '(("Content-Type" . "application/json")))
         (prompt (format "Write lyrics for an acapella nasheed about %s. 
Provide ONLY the lyrics. Structure it with [Verse] and [Chorus] tags. 
Do not include any musical accompaniment instructions." topic))
         (json-payload (json-encode `((model . ,ollama-default-model) 
                                      (prompt . ,prompt) 
                                      (stream . :json-false))))
         (url-request-data json-payload))
    
    (url-retrieve "http://localhost:11434/api/generate" 
                  'my/ollama-lyrics-callback 
                  (list topic))))

(defun my/ollama-lyrics-callback (status topic)
  "Callback to parse Ollama's JSON response and prepare the edit buffer."
  (if (plist-get status :error)
      (error "Ollama API failed: %s" (plist-get status :error))
    (goto-char (point-min))
    (re-search-forward "^$" nil 'move)
    (let* ((json-string (buffer-substring-no-properties (point) (point-max)))
           (json-data (json-read-from-string json-string))
           (lyrics (cdr (assoc 'response json-data)))
           (buf (get-buffer-create (format "*Nasheed: %s*" topic))))
      
      (with-current-buffer buf
        (erase-buffer)
        (insert lyrics)
        (text-mode)
        (use-local-map (copy-keymap text-mode-map))
        (local-set-key (kbd "C-c C-c") 'my/nasheed-send-to-audio)
        (goto-char (point-min))
        (insert (format ";; Topic: %s\n;; Edit your lyrics, then press C-c C-c to generate audio.\n\n" topic)))
      
      (switch-to-buffer buf)
      (message "Lyrics drafted. Press C-c C-c when ready to synthesize."))))

(defun my/nasheed-send-to-audio (bg-video)
  "Send the current buffer's lyrics to the local GPU synthesizer asynchronously.
Applies an automatic chorus/echo effect, creates an SRT file, and renders a multi-input montage."
  (interactive
   (list (read-file-name "Background video: " content-dev-path nil t "minecraft.mp4")))
  
  (let* ((base-dir content-dev-path)
         (filename (replace-regexp-in-string "[^a-zA-Z0-9-]" "_" (buffer-name)))
         (output-audio (expand-file-name (concat filename ".mp3") base-dir))
         (output-srt (expand-file-name (concat filename ".srt") base-dir))
         (output-video (expand-file-name (concat filename ".mp4") base-dir))
         (lyrics-text (buffer-substring-no-properties (point-min) (point-max)))
         (txt-tmp (make-temp-file "nasheed-lyrics-" nil ".txt"))
         (py-tmp (make-temp-file "nasheed-script-" nil ".py")))
    
    (with-temp-file txt-tmp (insert lyrics-text))
    
    ;; Write the embedded Python script
    (with-temp-file py-tmp
      (insert "
import sys, re, torch, subprocess, random, math
from pathlib import Path
from TTS.api import TTS
from pydub import AudioSegment

text_file, out_mp3, out_srt, video_in, video_out = sys.argv[1:6]

lines = [line.strip() for line in Path(text_file).read_text(encoding='utf-8').splitlines() 
         if line.strip() and not line.startswith('[') and not line.startswith(';;') and re.search(r'[a-zA-Z0-9]', line)]

device = 'cuda' if torch.cuda.is_available() else 'cpu'
tts = TTS(model_name='tts_models/en/ljspeech/vits', progress_bar=False).to(device)

final_audio = AudioSegment.empty()
srt_content = ''
current_ms = 0

def format_time(ms):
    s, ms = divmod(ms, 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f'{int(h):02}:{int(m):02}:{int(s):02},{int(ms):03}'

for i, line in enumerate(lines, 1):
    tmp_chunk = f'/tmp/nasheed_chunk_{i}.wav'
    tts.tts_to_file(text=line, file_path=tmp_chunk)
    
    segment = AudioSegment.from_wav(tmp_chunk)
    echo = segment - 6  
    chorus_segment = segment.overlay(echo, position=80) 
    
    start_time = current_ms
    end_time = current_ms + len(chorus_segment)
    
    srt_content += f'{i}\\n{format_time(start_time)} --> {format_time(end_time)}\\n{line}\\n\\n'
    
    final_audio += chorus_segment + AudioSegment.silent(duration=300)
    current_ms = end_time + 300
    Path(tmp_chunk).unlink(missing_ok=True)

final_audio.export(out_mp3, format='mp3')
Path(out_srt).write_text(srt_content, encoding='utf-8')

# --- BUFFER-FREE MULTI-INPUT MONTAGE PROCESSING ---
def get_video_duration(p):
    cmd = ['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', p]
    return float(subprocess.check_output(cmd).decode().strip())

try:
    v_dur = get_video_duration(video_in)
    safe_v_dur = max(0.5, v_dur - 2.0)
    a_dur = current_ms / 1000.0
    
    safe_clip_len = min(6.0, safe_v_dur * 0.9) if safe_v_dur > 1.0 else safe_v_dur
    num_clips = int(math.ceil(a_dur / safe_clip_len)) + 2
    
    ffmpeg_cmd = ['ffmpeg', '-y']
    concat_inputs = ''
    
    # Bypassing filter fan-out by injecting the source file N separate times
    for idx in range(num_clips):
        start = random.uniform(0, max(0, safe_v_dur - safe_clip_len))
        ffmpeg_cmd.extend(['-ss', f'{start:.3f}', '-t', f'{safe_clip_len:.3f}', '-i', video_in])
        concat_inputs += f'[{idx}:v:0]'
        
    # Finally, add audio as the absolute last input
    ffmpeg_cmd.extend(['-i', out_mp3])
    audio_idx = num_clips
    
    filter_complex = f\"{concat_inputs}concat=n={num_clips}:v=1:a=0[vconcat];[vconcat]fps=30,format=yuv420p,subtitles='{out_srt}'[outv]\"
    
    ffmpeg_cmd.extend([
        '-filter_complex', filter_complex,
        '-map', '[outv]', '-map', f'{audio_idx}:a:0',
        '-c:v', 'libx264', '-preset', 'fast',
        '-c:a', 'aac', '-b:a', '192k',
        '-shortest', video_out
    ])
    subprocess.run(ffmpeg_cmd, check=True)
except Exception as e:
    print(f'FFmpeg Montage composition failed: {e}', file=sys.stderr)
    sys.exit(1)
"))

    (message "Synthesizing vocals & multi-input montage video on GPU...")
    (make-process
     :name "nasheed-synthesizer-video"
     :buffer "*nasheed-audio-out*"
     :command (list "python3" py-tmp txt-tmp output-audio output-srt (expand-file-name bg-video) output-video)
     :sentinel `(lambda (proc event)
                  (when (string-match-p "finished" event)
                    (ignore-errors 
                      (delete-file ,txt-tmp)
                      (delete-file ,py-tmp)
                      (delete-file ,output-srt))
                    (message "SubhanAllah, unique montage video ready: %s" ,output-video))))))

;;; --- Modeline & Islamic Calendar ---
(require 'calendar)

(defun get-islamic-date-for-modeline ()
  (condition-case nil
      (format " [%s] " (calendar-islamic-date-string (calendar-current-date)))
    (error " [Date Error] ")))

(setq-default mode-line-format
      '("%e" mode-line-front-space
        (:propertize ("" mode-line-mule-info mode-line-client mode-line-modified
                      mode-line-remote mode-line-window-dedicated) display (min-width (6.0)))
        mode-line-frame-identification
        mode-line-buffer-identification "   "
        mode-line-position " " evil-mode-line-tag
        (project-mode-line project-mode-line-format)
        (vc-mode vc-mode) "  "
        mode-line-modes mode-line-misc-info 
        (:propertize (:eval (get-islamic-date-for-modeline)) face font-lock-keyword-face)
        mode-line-end-spaces))

;;; --- Utilities & System ---
(setq backup-directory-alist '(("." . "~/.emacs_saves")))
(setq shell-file-name "bash")
(setq shell-command-switch "-ic")

(defun my-minibuffer-setup-hook () (setq gc-cons-threshold most-positive-fixnum))
(defun my-minibuffer-exit-hook () (setq gc-cons-threshold 80000000))
(add-hook 'minibuffer-setup-hook #'my-minibuffer-setup-hook)
(add-hook 'minibuffer-exit-hook #'my-minibuffer-exit-hook)

;; Ediff Settings
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-window-plain)

;; Search Highlighting Persistence
(defun highlight-remove-all () (interactive) (hi-lock-mode -1) (hi-lock-mode 1))
(defun search-highlight-persist ()
    (highlight-regexp (car-safe (if search-regexp regexp-search-ring search-ring)) (facep 'hi-yellow)))
(defadvice evil-search-incrementally (after evil-search-hl-persist activate)
  (highlight-remove-all) (search-highlight-persist))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-vivendi))
 '(package-selected-packages
   '(auctex audio-notes-mode auto-async-byte-compile cal-islamic
	    claude-code claude-shell corfu doc-toc elfeed evil
	    latex-preview-pane mu4easy org-roam smex undo-fu
	    use-package xclip ytdl)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defun my/convert-video-to-short (input-video output-filename)
  "Convert an existing landscape video to a 9:16 vertical short format using FFmpeg.
No AI or TTS is used."
  (interactive "fInput landscape video: \nsOutput filename (without extension): ")
  (let* ((base-dir content-dev-path)
         (in-file (expand-file-name input-video))
         (out-file (expand-file-name (concat output-filename "_short.mp4") base-dir))
         ;; Calculates the dead-center 9:16 slice of any input before upscaling to 1080p
         (filter-cmd "crop='min(iw,ih*9/16)':'min(ih,iw*16/9)',scale=1080:1920"))

    (message "Converting %s to 9:16 short format..." (file-name-nondirectory in-file))
    
    (make-process
     :name "video-to-short-pipeline"
     :buffer "*video-to-short-out*"
     :command (list "ffmpeg" "-y" 
                    "-i" in-file 
                    "-vf" filter-cmd 
                    "-c:v" "libx264" "-preset" "fast" 
                    ;; Copies the original audio track to avoid re-encoding latency
                    "-c:a" "copy" 
                    out-file)
     :sentinel `(lambda (proc event)
                  (when (string-match-p "finished" event)
                    (message "DONE — Converted to vertical format: %s" ,out-file))))))

(defun my/text-to-short (filename)
  "Full async pipeline: refine region for YouTube Shorts, GPU TTS + SRT, and 9:16 background montage using minecraft.mp4."
  (interactive "sOutput filename (without extension): ")
  (unless (use-region-p)
    (user-error "No region active"))

  (message "Step 1/4: Checking Ollama & Drafting Short...")
  (my/ensure-ollama-running)

  (let* ((base-dir content-dev-path)
         (raw-text (buffer-substring-no-properties (region-beginning) (region-end)))
         (tmpbuf (get-buffer-create "*short-refine*"))
         (tts-file (expand-file-name (concat filename ".mp3") base-dir))
         (srt-file (expand-file-name (concat filename ".srt") base-dir))
         (video-out (expand-file-name (concat filename "_short.mp4") base-dir))
         (mc-video (expand-file-name "minecraft.mp4" base-dir))
         (txt-tmp (make-temp-file "short-text-" nil ".txt"))
         (py-tmp (make-temp-file "short-script-" nil ".py")))

    ;; STEP 1: Refine story using viral constraints
    (with-current-buffer tmpbuf
      (erase-buffer)
      (insert "SYSTEM: You are an elite short-form video growth engineer. Rewrite the following text into a highly viral commentary script for YouTube Shorts. EXECUTION RULES:\n1. Open immediately with a shocking, high-velocity hook.\n2. Keep it fast and punchy.\n3. NO markdown, NO emojis, NO parentheses, NO scene directions.\n4. Output ONLY the literal words spoken aloud.\n\nTEXT:\n" raw-text)
      (my/ollama-send-region-sync nil)
      (goto-char (point-min))
      (unless (search-forward "--- Ollama Response ---" nil t)
        (error "Ollama refinement failed"))
      (setq raw-text (string-trim (buffer-substring-no-properties (point) (point-max)))))

    ;; Write the refined text and the GPU-accelerated Python logic
    (with-temp-file txt-tmp (insert raw-text))
    (with-temp-file py-tmp
      (insert "
import sys, re, torch, subprocess, random, math
from pathlib import Path
from TTS.api import TTS
from pydub import AudioSegment

text_file, mp3_out, srt_out, video_in, video_out = sys.argv[1:6]
raw_content = Path(text_file).read_text(encoding='utf-8')

# Strict text sanitization (strips markdown/symbols so TTS won't glitch)
clean_content = re.sub(r'[*#_\\-\\[\\]()•”“\"~:;]', '', raw_content)
clean_content = re.sub(r'[^a-zA-Z0-9\\s.,!?\\']', '', clean_content)
clean_content = re.sub(r'\\s+', ' ', clean_content).strip()

raw_sentences = re.split(r'(?<=[.!?])\\s+', clean_content)
sentences = [s.strip() for s in raw_sentences if s.strip() and re.search(r'[a-zA-Z0-9]', s)]

device = 'cuda' if torch.cuda.is_available() else 'cpu'
tts = TTS(model_name='tts_models/en/ljspeech/vits', progress_bar=False).to(device)

combined_audio = AudioSegment.empty()
srt_content = ''
current_ms = 0

def format_time(ms):
    s, ms = divmod(ms, 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    return f'{int(h):02}:{int(m):02}:{int(s):02},{int(ms):03}'

for i, sentence in enumerate(sentences, 1):
    tmp_chunk = f'/tmp/short_chunk_{i}.wav'
    tts.tts_to_file(text=sentence, file_path=tmp_chunk)
    segment = AudioSegment.from_wav(tmp_chunk)
    start_time = current_ms
    end_time = current_ms + len(segment)
    
    srt_content += f'{i}\\n{format_time(start_time)} --> {format_time(end_time)}\\n{sentence}\\n\\n'
    combined_audio += segment
    current_ms = end_time
    Path(tmp_chunk).unlink(missing_ok=True)

combined_audio.export(mp3_out, format='mp3')
Path(srt_out).write_text(srt_content, encoding='utf-8')

# --- BUFFER-FREE 9:16 MULTI-INPUT MONTAGE PROCESSING ---
def get_video_duration(p):
    cmd = ['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', p]
    return float(subprocess.check_output(cmd).decode().strip())

try:
    v_dur = get_video_duration(video_in)
    safe_v_dur = max(0.5, v_dur - 2.0)
    a_dur = current_ms / 1000.0
    
    safe_clip_len = min(6.0, safe_v_dur * 0.9) if safe_v_dur > 1.0 else safe_v_dur
    num_clips = int(math.ceil(a_dur / safe_clip_len)) + 2
    
    ffmpeg_cmd = ['ffmpeg', '-y']
    concat_inputs = ''
    
    for idx in range(num_clips):
        start = random.uniform(0, max(0, safe_v_dur - safe_clip_len))
        ffmpeg_cmd.extend(['-ss', f'{start:.3f}', '-t', f'{safe_clip_len:.3f}', '-i', video_in])
        concat_inputs += f'[{idx}:v:0]'
        
    ffmpeg_cmd.extend(['-i', mp3_out])
    audio_idx = num_clips
    
    # Mathematical center-crop applied to the concatenated stream before burning subtitles
    crop_scale = \"crop='min(iw,ih*9/16)':'min(ih,iw*16/9)',scale=1080:1920\"
    filter_complex = f\"{concat_inputs}concat=n={num_clips}:v=1:a=0[vconcat];[vconcat]{crop_scale},fps=30,format=yuv420p,subtitles='{srt_out}'[outv]\"
    
    ffmpeg_cmd.extend([
        '-filter_complex', filter_complex,
        '-map', '[outv]', '-map', f'{audio_idx}:a:0',
        '-c:v', 'libx264', '-preset', 'fast',
        '-c:a', 'aac', '-b:a', '192k',
        '-shortest', video_out
    ])
    subprocess.run(ffmpeg_cmd, check=True)
except Exception as e:
    print(f'FFmpeg Shorts composition failed: {e}', file=sys.stderr)
    sys.exit(1)
"))

    ;; STEP 2-4: Run everything cleanly under Python process control
    (message "Step 2-4: Running Vocals and 9:16 Montage Render on GPU...")
    (make-process
     :name "short-to-video-pipeline"
     :buffer "*short-to-video-out*"
     ;; Feed mc-video into the pipeline instead of prompting
     :command (list "python3" py-tmp txt-tmp tts-file srt-file mc-video video-out)
     :sentinel `(lambda (proc event)
                  (when (string-match-p "finished" event)
                    (ignore-errors 
                      (delete-file ,py-tmp)
                      (delete-file ,txt-tmp)
                      (delete-file ,srt-file))
                    (message "DONE — Monetizable YouTube Short created: %s" ,video-out))))))
(add-to-list 'load-path "/games/commonvoicemozilla/arabic-pronunciation-pipeline")
(require 'arabic-tutor)
(arabic-tutor-enable-daily-prompt)   ;; ask once a day on startup

;;; ---------------------------------------------------------------------------
;;; mu4e  (Gmail, synced by mbsync, sent by msmtp)
;;; Added 2026-07-02. `require ... t' = no error if mu isn't installed yet.
;;; ---------------------------------------------------------------------------
;; Debian installs mu4e's elisp under elpa-src (plain .el sources — the
;; sibling elpa/ dir holds .elc byte-compiled by the removed Emacs 28, wrong
;; for the 30.2 snap).  Wildcarded so package upgrades keep working.
(let ((d (car (last (file-expand-wildcards
                     "/usr/share/emacs/site-lisp/elpa-src/mu4e-*")))))
  (when d (add-to-list 'load-path d)))
(when (require 'mu4e nil t)
  (setq mu4e-mu-binary            (executable-find "mu")
        mu4e-maildir              "~/Maildir/gmail"
        mu4e-get-mail-command     "mbsync -a"
        mu4e-update-interval      300
        mu4e-change-filenames-when-moving t   ; REQUIRED for mbsync
        mu4e-attachment-dir       "~/Downloads"
        mu4e-context-policy       'pick-first
        ;; Gmail special folders (relative to mu4e-maildir):
        mu4e-sent-folder    "/[Gmail]/Sent Mail"
        mu4e-drafts-folder  "/[Gmail]/Drafts"
        mu4e-trash-folder   "/[Gmail]/Bin"
        mu4e-refile-folder  "/[Gmail]/All Mail")
  ;; Gmail already keeps a copy of sent mail, so don't save a second one:
  (setq mu4e-sent-messages-behavior 'delete)
  ;; Identity — EDIT the name if you like:
  (setq user-mail-address "sjuma495@gmail.com"
        user-full-name     "Sierra")
  ;; Send via msmtp:
  (setq sendmail-program            (executable-find "msmtp")
        message-send-mail-function  'message-send-mail-with-sendmail
        message-sendmail-f-is-evil  t
        message-sendmail-extra-arguments '("--read-envelope-from")))

;;; ---------------------------------------------------------------------------
;;; Autonomous Shorts factory  (trending scrape -> Ollama -> TTS -> YouTube)
;;; Added 2026-07-10.  Worker: /games/contentdevelopment/auto_shorts/auto_shorts.py
;;; One-time setup: put OAuth client_secrets.json in that dir, then
;;;   M-x my/auto-shorts-authorize
;;; Then M-x my/auto-shorts-start to begin the hourly background cycle.
;;; NOTE: YouTube's default API quota allows ~6 uploads/day (1600 units each of
;;; 10,000). Hourly ticks still render; extras queue in outbox/ and upload as
;;; quota allows. Raise daily_upload_cap in config.json if Google grants more.
;;; ---------------------------------------------------------------------------

;; /usr/bin/python3 (3.11) is the interpreter with TTS/torch/pydub installed —
;; the linuxbrew python3 (3.14) on PATH does NOT have them.
(defvar my/auto-shorts-python "/usr/bin/python3")
(defvar my/auto-shorts-script "/games/contentdevelopment/auto_shorts/auto_shorts.py")
(defvar my/auto-shorts-interval 300
  "Seconds between autonomous shorts ticks.
Renders are skipped whenever outbox/ already holds `outbox_max' videos
(config.json), so short intervals don't waste electricity on unpostable
renders — they just make posting slots drain promptly.")
(defvar my/auto-shorts-timer nil)

(defun my/auto-shorts--tick (&rest extra-args)
  "Fire one pipeline run in the background (never blocks Emacs).
The worker holds a flock, so overlapping ticks are self-skipping."
  (let ((proc (get-process "auto-shorts")))
    (if (and proc (process-live-p proc))
        (message "auto-shorts: previous run still going — skipped tick")
      (make-process
       :name "auto-shorts"
       :buffer "*auto-shorts-log*"
       :command (append (list my/auto-shorts-python my/auto-shorts-script "--once")
                        extra-args)
       :sentinel (lambda (_proc event)
                   (cond ((string-match-p "finished" event)
                          (message "auto-shorts: tick complete"))
                         ((string-match-p "\\(exited\\|failed\\|signal\\)" event)
                          (message "auto-shorts: tick FAILED — see *auto-shorts-log*"))))))))

(defun my/auto-shorts-start ()
  "Start the autonomous hourly shorts factory."
  (interactive)
  (when my/auto-shorts-timer (cancel-timer my/auto-shorts-timer))
  (setq my/auto-shorts-timer
        (run-with-timer 5 my/auto-shorts-interval #'my/auto-shorts--tick))
  (message "auto-shorts: running every %d min (M-x my/auto-shorts-stop to halt)"
           (/ my/auto-shorts-interval 60)))

(defun my/auto-shorts-stop (&optional kill-in-flight)
  "Stop the autonomous shorts factory (cancels the hourly timer).
If a render/upload is currently running, ask whether to kill it too.
With prefix arg KILL-IN-FLIGHT (\\[universal-argument]), kill it without asking."
  (interactive "P")
  (when my/auto-shorts-timer
    (cancel-timer my/auto-shorts-timer)
    (setq my/auto-shorts-timer nil))
  (let ((proc (get-process "auto-shorts")))
    (if (and proc (process-live-p proc))
        (if (or kill-in-flight
                (y-or-n-p "auto-shorts: a run is in progress — kill it too? "))
            (progn (delete-process proc)
                   (message "auto-shorts: stopped; in-flight run killed"))
          (message "auto-shorts: timer stopped; in-flight run will finish"))
      (message "auto-shorts: stopped"))))

(defun my/auto-shorts-run-once (&optional no-upload)
  "Manually trigger one pipeline run now.  With prefix arg, render only."
  (interactive "P")
  (if no-upload
      (my/auto-shorts--tick "--no-upload")
    (my/auto-shorts--tick))
  (display-buffer (get-buffer-create "*auto-shorts-log*")))

(defun my/auto-shorts-status ()
  "Show factory state: uploads today, outbox queue, auth status."
  (interactive)
  (let ((buf (get-buffer-create "*auto-shorts-status*")))
    (with-current-buffer buf
      (erase-buffer)
      (insert (format "Timer active: %s\n\n" (if my/auto-shorts-timer "YES" "no")))
      (call-process my/auto-shorts-python nil t nil my/auto-shorts-script "--status"))
    (display-buffer buf)))

(defun my/auto-shorts-authorize ()
  "Run the one-time interactive YouTube OAuth flow (opens a browser)."
  (interactive)
  (let ((buf (get-buffer-create "*auto-shorts-auth*")))
    (make-process :name "auto-shorts-auth" :buffer buf
                  :command (list my/auto-shorts-python my/auto-shorts-script "--authorize"))
    (display-buffer buf)))

;; Uncomment to auto-start the factory on every Emacs launch:
;; (my/auto-shorts-start)

(setq dired-recursive-copies 'always)
(dired-async-mode 1)

;;; ---------------------------------------------------------------------------
;;; Org agenda reminders  (desktop notification of the next hour, every 15 min)
;;; Added 2026-07-19.  Starts automatically at the end of this file.
;;; M-x my/org-reminders-check to test one check now, my/org-reminders-stop
;;; to halt.  Notification backend picked per OS (Linux/macOS/Windows).
;;; ---------------------------------------------------------------------------

;; The agenda never had source files configured; default to the Roam notes.
;; Add dedicated agenda/todo files to this list as you create them.
(unless org-agenda-files
  (setq org-agenda-files (list "/home/sierra/RoamDir")))

(defun my/os-notify (title body)
  "Show a desktop notification with TITLE and BODY, per operating system."
  (cond
   ((eq system-type 'gnu/linux)
    (if (executable-find "notify-send")
        (call-process "notify-send" nil 0 nil "-u" "normal" "-a" "Emacs" title body)
      (message "%s — %s" title body)))
   ((eq system-type 'darwin)
    (call-process "osascript" nil 0 nil "-e"
                  (format "display notification %S with title %S" body title)))
   ((and (memq system-type '(windows-nt cygwin))
         (fboundp 'w32-notification-notify))
    (w32-notification-notify :title title :body body))
   (t (message "%s — %s" title body))))

(defun my/org--events-next-hour ()
  "List of \"HH:MM  Heading\" strings for agenda items in the next hour.
Scans active org timestamps (plain, SCHEDULED and DEADLINE) that carry a
clock time, skipping entries already marked done."
  (let ((now (current-time))
        (limit (time-add (current-time) 3600))
        (events '()))
    (dolist (file (org-agenda-files))
      (when (file-readable-p file)
        (with-current-buffer (find-file-noselect file)
          (org-with-wide-buffer
           (goto-char (point-min))
           (while (re-search-forward org-ts-regexp nil t)
             (let ((ts (match-string 0)))
               (when (string-match-p "[0-9]\\{1,2\\}:[0-9]\\{2\\}" ts)
                 (let ((time (org-time-string-to-time ts)))
                   (when (and (time-less-p now time)
                              (time-less-p time limit))
                     (save-excursion
                       (if (org-before-first-heading-p)
                           (push (format "%s  %s"
                                         (format-time-string "%H:%M" time)
                                         (file-name-base file))
                                 events)
                         (org-back-to-heading t)
                         (unless (org-entry-is-done-p)
                           (push (format "%s  %s"
                                         (format-time-string "%H:%M" time)
                                         (org-get-heading t t t t))
                                 events)))))))))))))
    (sort (delete-dups (nreverse events)) #'string<)))

(defun my/org-reminders-check ()
  "Notify about org agenda items due within the next hour."
  (interactive)
  (let ((events (my/org--events-next-hour)))
    (when events
      (my/os-notify "Org: coming up in the next hour"
                    (mapconcat #'identity events "\n")))
    (when (called-interactively-p 'interactive)
      (message "org reminders: %s"
               (if events (format "notified about %d item(s)" (length events))
                 "nothing in the next hour")))))

(defvar my/org-reminders-timer nil)

(defun my/org-reminders-start ()
  "Check the agenda every 15 minutes and notify about the coming hour."
  (interactive)
  (when my/org-reminders-timer (cancel-timer my/org-reminders-timer))
  (setq my/org-reminders-timer
        (run-with-timer 30 (* 15 60) #'my/org-reminders-check))
  (message "org reminders: checking every 15 min (M-x my/org-reminders-stop to halt)"))

(defun my/org-reminders-stop ()
  "Stop the periodic org agenda reminders."
  (interactive)
  (when my/org-reminders-timer
    (cancel-timer my/org-reminders-timer)
    (setq my/org-reminders-timer nil))
  (message "org reminders: stopped"))

(my/org-reminders-start)

;;; ---------------------------------------------------------------------------
;;; Claude Code  (send region / buffer into a Claude session)
;;; Added 2026-07-19.  C-c c r sends the region, C-c c b the whole buffer;
;;; both prompt for optional instructions and start a Claude session first
;;; if none is running.  Uses the `claude-code' package (vterm-based; the
;;; vterm C module is compiled in its elpa dir).
;;; ---------------------------------------------------------------------------
(require 'cl-lib)
(add-to-list 'exec-path (expand-file-name "~/.local/bin"))
(setq claude-code-executable (expand-file-name "~/.local/bin/claude"))

(defun my/claude--session-buffer ()
  "Any live Claude Code vterm buffer, or nil."
  (seq-find (lambda (b) (string-prefix-p "*claude:" (buffer-name b)))
            (buffer-list)))

(defun my/claude--ensure-session ()
  "Return a Claude Code buffer, starting a session here if needed.
Non-project files get a session rooted at their `default-directory'."
  (or (my/claude--session-buffer)
      (progn
        (require 'claude-code)
        ;; The package refuses to run outside a projectile project; fall
        ;; back to the current directory as the session root.
        (cl-letf* ((orig (symbol-function 'projectile-project-root))
                   ((symbol-function 'projectile-project-root)
                    (lambda (&optional dir) (or (funcall orig dir) default-directory))))
          (save-window-excursion (claude-code-run)))
        ;; Give the Claude TUI a moment to finish launching before input.
        (sit-for 3)
        (my/claude--session-buffer))))

(defun my/claude--send-text (text)
  "Prompt for optional instructions and send them plus TEXT to Claude."
  (let ((instr (read-string "Instructions for Claude (optional): "))
        (buf (my/claude--ensure-session)))
    (unless buf (user-error "Could not start a Claude Code session"))
    (with-current-buffer buf
      ;; paste-p = t: bracketed paste, so newlines don't submit early.
      (vterm-send-string
       (if (string-empty-p instr) text (concat instr "\n\n" text)) t)
      (sit-for (* vterm-timer-delay 3))
      (vterm-send-return))
    (display-buffer buf)
    (message "Sent %d chars to Claude" (length text))))

(defun my/claude-send-region (beg end)
  "Send the active region to Claude Code."
  (interactive "r")
  (unless (use-region-p) (user-error "No region active"))
  (my/claude--send-text (buffer-substring-no-properties beg end)))

(defun my/claude-send-buffer ()
  "Send the entire current buffer to Claude Code."
  (interactive)
  (my/claude--send-text (buffer-substring-no-properties (point-min) (point-max))))

(global-set-key (kbd "C-c c r") #'my/claude-send-region)
(global-set-key (kbd "C-c c b") #'my/claude-send-buffer)

;; -- Quick one-shot answers (no session): `claude -p`, async ----------------
;; C-c c q asks about the region (or whole buffer if no region) and inserts
;; the reply at the end of the buffer, like the Ollama helpers above.
;; Read-only buffer, or a prefix arg, routes the reply to *Claude-Output*.

(defun my/claude--insert-response (target-buf text)
  "Insert TEXT at the end of TARGET-BUF, or into *Claude-Output* when
TARGET-BUF is nil, gone, or read-only."
  (if (or (not (buffer-live-p target-buf))
          (buffer-local-value 'buffer-read-only target-buf))
      (let ((out (get-buffer-create "*Claude-Output*")))
        (with-current-buffer out
          (goto-char (point-max))
          (insert "\n\n--- Claude Response ---\n\n" text))
        (display-buffer out))
    (with-current-buffer target-buf
      (save-excursion
        (goto-char (point-max))
        (insert "\n\n--- Claude Response ---\n\n" text)))
    (message "Claude replied in %s" (buffer-name target-buf))))

(defun my/claude--quick-run (instr text target-buf)
  "Ask Claude (print mode) about TEXT with instructions INSTR, async.
Reply goes to TARGET-BUF via `my/claude--insert-response'."
  (let* ((out-buf (generate-new-buffer " *claude-quick*"))
         (err-buf (generate-new-buffer " *claude-quick-stderr*"))
         (proc (make-process
                :name "claude-quick"
                :buffer out-buf
                :stderr err-buf
                :connection-type 'pipe
                :command (list (expand-file-name "~/.local/bin/claude") "-p")
                :sentinel
                `(lambda (proc event)
                   (when (string-match-p "finished\\|exited" event)
                     (let ((reply (with-current-buffer ,out-buf
                                    (string-trim (buffer-string))))
                           (errs (with-current-buffer ,err-buf
                                   (string-trim (buffer-string)))))
                       (kill-buffer ,out-buf)
                       (kill-buffer ,err-buf)
                       (if (and (zerop (process-exit-status proc))
                                (not (string-empty-p reply)))
                           (my/claude--insert-response ,target-buf reply)
                         (message "claude -p failed: %s"
                                  (if (string-empty-p errs) event errs)))))))))
    (process-send-string proc (concat instr "\n\n---\n\n" text))
    (process-send-eof proc)
    (message "Asking Claude... (reply will be inserted when ready)")))

(defun my/claude-quick (&optional use-separate-buffer)
  "Ask Claude about the region (whole buffer if no region); insert reply.
One-shot `claude -p` call — no interactive session is started.  With
prefix arg USE-SEPARATE-BUFFER, reply in *Claude-Output* instead."
  (interactive "P")
  (let ((text (if (use-region-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (buffer-substring-no-properties (point-min) (point-max))))
        (instr (read-string "Instructions for Claude: ")))
    (my/claude--quick-run instr text
                          (unless use-separate-buffer (current-buffer)))))

(global-set-key (kbd "C-c c q") #'my/claude-quick)

;;; --- Org face fix-ups (after the theme, which the custom block above loads) ---
;; Modus 1.6 keeps tables/blocks/code monospace under `variable-pitch-mode',
;; but misses these; anything alignment-sensitive must be fixed-pitch.
(with-eval-after-load 'org
  (dolist (face '(org-checkbox org-tag org-formula org-date
                  org-special-keyword org-drawer))
    (when (facep face)
      (set-face-attribute face nil :inherit 'fixed-pitch))))

;;; ---------------------------------------------------------------------------
;;; PDF page text / OCR  (EAF pdf-viewer)
;;; Added 2026-07-19.  M-x my/pdf-ocr-current-page while viewing a PDF.
;;; Tries the PDF's embedded text layer first (instant, exact). If the page
;;; has none (scanned document), renders it at 300 dpi with pdftoppm and OCRs
;;; it with tesseract.  Needs: sudo apt-get install -y tesseract-ocr
;;; (add tesseract-ocr-ara for Arabic, then set my/pdf-ocr-lang to "ara"
;;; or "eng+ara").
;;; ---------------------------------------------------------------------------

(defvar my/pdf-ocr-lang "eng"
  "Tesseract language(s) for PDF OCR, e.g. \"eng\", \"ara\", \"eng+ara\".")

(defun my/pdf--ocr-page (pdf-file page)
  "Render PAGE of PDF-FILE at 300 dpi and return its tesseract OCR text."
  (unless (executable-find "tesseract")
    (user-error "tesseract not installed — run: sudo apt-get install -y tesseract-ocr"))
  (let* ((png-base (make-temp-file "pdf-ocr-page"))
         (png (concat png-base ".png")))
    (unwind-protect
        (progn
          (unless (= 0 (call-process "pdftoppm" nil nil nil
                                     "-f" (number-to-string page)
                                     "-l" (number-to-string page)
                                     "-r" "300" "-png" "-singlefile"
                                     pdf-file png-base))
            (error "pdftoppm failed on page %d of %s" page pdf-file))
          (with-temp-buffer
            (unless (= 0 (call-process "tesseract" nil '(t nil) nil
                                       png "-" "-l" my/pdf-ocr-lang "--dpi" "300"))
              (error "tesseract failed on %s" png))
            (buffer-string)))
      (ignore-errors (delete-file png))
      (ignore-errors (delete-file png-base)))))

(defun my/pdf-ocr-current-page (&optional force-ocr)
  "Show the text of the PDF page currently open in the EAF viewer.
Uses the embedded text layer when the page has one; otherwise (or with
prefix arg FORCE-OCR) runs tesseract OCR on a 300 dpi render of the page.
The result goes to the *PDF Page Text* buffer."
  (interactive "P")
  (unless (and (derived-mode-p 'eaf-mode)
               (equal eaf--buffer-app-name "pdf-viewer"))
    (user-error "Not in an EAF PDF buffer"))
  (let* ((pdf-file (if (string-prefix-p "file://" eaf--buffer-url)
                       (substring eaf--buffer-url 7)
                     eaf--buffer-url))
         (page (string-to-number
                (eaf-call-sync "execute_function" eaf--buffer-id "current_page")))
         (layer-text (unless force-ocr
                       (ignore-errors
                         (eaf-call-sync "execute_function" eaf--buffer-id
                                        "get_page_text"))))
         (used-ocr (or force-ocr
                       (not (and (stringp layer-text)
                                 (string-match-p "[^ \t\n\f]" layer-text)))))
         (text (if used-ocr
                   (progn (message "No text layer — OCR-ing page %d..." page)
                          (my/pdf--ocr-page pdf-file page))
                 layer-text))
         (buf (get-buffer-create "*PDF Page Text*")))
    (with-current-buffer buf
      (erase-buffer)
      (insert (format ";; %s — page %d (%s)\n\n"
                      (file-name-nondirectory pdf-file) page
                      (if used-ocr "tesseract OCR" "embedded text layer"))
              text)
      (text-mode)
      (goto-char (point-min)))
    (display-buffer buf)
    (message "Page %d text ready in *PDF Page Text*" page)))
