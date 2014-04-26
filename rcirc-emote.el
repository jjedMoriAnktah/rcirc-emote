;; The MIT License
;;
;; Copyright (c) 2014 Sina Samavati <sina.samv@gmail.com>
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

(require 'rcirc)

(defcustom rcirc-emoticons
  '((":smoking:" . "(-。-)y-゜゜゜")
    (":confused:" . "(゜-゜)")
    (":happy:" . "(✿◠‿◠)")
    (":surprised:" . "°o°")
    (":infatuation:" . "(*°∀°)=3")
    (":shrug:" . "¯\_(ツ)_/¯")
    (":kitaa:" . "キタ━━━(゜∀゜)━━━!!!!!")
    (":tableflip:" . "(╯°□°）╯︵ ┻━┻")
    (":rageflip:" . "(ノಠ益ಠ)ノ彡┻━┻")
    (":doubleflip:" . "┻━┻ ︵ヽ(`Д´)ﾉ︵ ┻━┻")
    (":lookofdisapproval:" . "ಠ_ಠ"))
  "Predefined emoticons"
  :group 'rcirc-emote
  :type 'sexp)

;; replace phrases with their emoticons
(defun rcirc-emoticonize (line)
  (let ((result line))
    (dolist (elem rcirc-emoticons result)
      (setq result (replace-regexp-in-string (car elem) (cdr elem) result)))))

;; override rcirc-send-input to emoticonize text before sending input
(defun rcirc-emote-send-input ()
  (interactive)
  (if (< (point) rcirc-prompt-end-marker)
      ;; copy the line down to the input area
      (progn
	(forward-line 0)
	(let ((start (if (eq (point) (point-min))
			 (point)
		       (if (get-text-property (1- (point)) 'hard)
			   (point)
			 (previous-single-property-change (point) 'hard))))
	      (end (next-single-property-change (1+ (point)) 'hard)))
	  (goto-char (point-max))
	  (insert (replace-regexp-in-string
		   "\n\\s-+" " "
		   (buffer-substring-no-properties start end)))))
    ;; process input
    (goto-char (point-max))
    (when (not (equal 0 (- (point) rcirc-prompt-end-marker)))
      ;; delete a trailing newline
      (when (eq (point) (point-at-bol))
	(delete-char -1))
      (let ((input (buffer-substring-no-properties
		    rcirc-prompt-end-marker (point))))
	(dolist (line (split-string input "\n"))
	  (rcirc-process-input-line (rcirc-emoticonize line)))
	;; add to input-ring
	(save-excursion
	  (ring-insert rcirc-input-ring input)
	  (setq rcirc-input-ring-index 0))))))

;; override RET keybinding
(define-key rcirc-mode-map (kbd "RET") 'rcirc-emote-send-input)

(provide 'rcirc-emote)
