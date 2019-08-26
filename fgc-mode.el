
(define-minor-mode fgc-mode
  "(F)rame (G)arbage (C)ollector. Kills old frames."
  :init-value nil
  :global 1
  :lighter " fgc"
  :keymap nil
  (fgc-go))



(defun record-visit-time ()
  (puthash (selected-frame) (float-time) fgc-frameToTimeTable))

(defun kill-old-frame (frameName)
  (message "killing %s..." frameName)
  (remhash frameName fgc-frameToTimeTable)
  (delete-frame frameName))

(defun too-many-frames (maxAllowed)
  (> (hash-table-count fgc-frameToTimeTable) maxAllowed))

(defun visit-time (frameName visitedTime)
  (message "%s" frameName)
  (message "%s" visitedTime)
  (if (too-many-frames 2) 
      (kill-old-frame frameName)
    ()))

(defun doall (&rest xs)
  ())

(defun kill-them (xs)
  (if (too-many-frames 2)
      (doall
       (kill-old-frame (car xs))
       (kill-them (cdr xs)))
    ()))


(defun by-visit-time (f1 f2)
  (<
   (gethash f1 fgc-frameToTimeTable (float-time))
   (gethash f2 fgc-frameToTimeTable (float-time))))

(defun f ()
  (kill-them (sort (frame-list) 'by-visit-time)))


(defun fgc-mode-begin ()
  (doall
   (setq fgc-frameToTimeTable (make-hash-table :test 'eq))
   (add-hook 'focus-in-hook 'record-visit-time)
   (setq fgc-killTimer (run-at-time 0 8 'f))
   ))

(defun fgc-mode-end ()
  (doall
   (remove-hook 'focus-in-hook 'record-visit-time)
   (cancel-timer fgc-killTimer)
   ))

(defun fgc-go ()
  (if (eq nil fgc-mode)
      (fgc-mode-end)
    (fgc-mode-begin)))

(provide 'fgc-mode)

;; scratchpad
;; ----------
;; to disable this

;;(kill-old-frames)
;;
;;(kill-them (sort (frame-list) 'by-visit-time))
;;(too-many-frames 2)
;;;;
;;(hash-table-count fgc-frameToTimeTable)
;;;;
;;;;
;;;;
;;;;(defun all-except-newest (xs n)
;;;;  ())
;;;;
;;;;(sort (frame-list) 'by-visit-time) 
;;(message "%s" fgc-frameToTimeTable)




