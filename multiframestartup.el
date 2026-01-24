(defun my/startup-layout ()
  "Create three frames, each showing two files."
  (interactive)

  ;; Define your file sets
  (let ((files1 '("~/file1.txt" "~/file2.txt"))
        (files2 '("~/file3.txt" "~/file4.txt"))
        (files3 '("~/file5.txt" "~/file6.txt")))

    ;; Frame 1
    (select-frame (make-frame))
    (delete-other-windows)
    (find-file (nth 0 files1))
    (split-window-right)
    (other-window 1)
    (find-file (nth 1 files1))

    ;; Frame 2
    (select-frame (make-frame))
    (delete-other-windows)
    (find-file (nth 0 files2))
    (split-window-right)
    (other-window 1)
    (find-file (nth 1 files2))

    ;; Frame 3
    (select-frame (make-frame))
    (delete-other-windows)
    (find-file (nth 0 files3))
    (split-window-right)
    (other-window 1)
    (find-file (nth 1 files3))))

;; hook to startup using (add-hook 'emacs-startup-hook #'my/startup-layout)
;; call from command line using alias emacs="emacs --eval '(my/startup-layout)'"
