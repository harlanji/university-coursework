;; ====== LAB 11 ======
;;    Author(s):  
;;                
;;  Lab Section:  

;;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab11.scm")  ; Change file name if copied to a new file.
)

;; Square
(define (square x) (* x x))

;;;; Test Case Code:
;;;;   This will handle execution of the test cases we've included below.
;;;;   To run test cases for a step, uncomment the (do-tests #) line.
;;;;   Note:  This code will run on MIT Scheme, but would have to be modified
;;;;          to work with other versions of Scheme. 
;;;;          Change #t to #f in the line below to use for Dr Scheme / STk.
;;;;          Behavior under Dr Scheme / STk is not tested.
(define (do-tests n)
  (let* ((in-mit-scheme #t)  ;; ** Change this value 
	 (tests-symbol 
	  (string->symbol 
	   (string-append "test-cases-step-" 
			  (number->string n))))

	 (test-cases 
	  (if in-mit-scheme 
	      (eval tests-symbol user-initial-environment)
	      (eval tests-symbol)))

	 (display-string (string-append 
			  "\n--- Test Cases for Step "
			  (number->string n)
			  " ---\n")))

    (display display-string)

    (for-each 
     (lambda (x)
       (if (and (pair? x) (eq? (car x) 'define))
	   (if in-mit-scheme 
	       (eval x user-initial-environment) 
	       (eval x))
	   (begin 
	     (display x)
	     (newline)
	     (display (if in-mit-scheme 
			  (eval x user-initial-environment) 
			  (eval x)))
	     (newline))))
     test-cases)))


;;;;
;;;; Step 1.  A First Object
;;;;

(define count 
  (let ((counter -1))
    (lambda ()
      (set! counter (+ counter 1))
      ; repeat 0-2
      (remainder counter 3))))

; Suppose we have the following additional definitions:
;     (define counter1 count)
;     (define counter2 count)
;     (define counter3 count) ...
; Do these counters behave independently of each other when called as in
; the examples below?
;     (counter1)
;     (counter1)
;     (counter3)
;     (counter2) ...
; Explain:
; Your answer here...
; They do not behave independently because they all share the same environment.
;

(define test-cases-step-1
  '(
    (count)
    (count)
    (count)
    (count)
    (count)))

(do-tests 1) 


;;;;
;;;; Step 2.  An Object Builder
;;;;

;; make-count
(define (make-count)
  (let ((counter -1))
    (lambda ()
      (set! counter (+ counter 1))
      (remainder counter 3))))


(define test-cases-step-2
  '(
    (define a (make-count))
    (define b (make-count))
    (a) (a)
    (b) (b) (b) (b)
    (a)
))

(do-tests 2) 


;;;;
;;;; Step 3.  What's all the flap about?
;;;;

(define (make-flip)
  (let ((bit 0))
    (lambda ()
      (set! bit (+ bit 1))
      (remainder bit 2))))

(define test-cases-step-3
  '(
    (define flip1 (make-flip))
    (define flip2 (make-flip))
    (flip1)
    (flip1)
    (flip2)
    (flip1)))

(do-tests 3) 


;;;;
;;;; Step 4. Don't flip out.
;;;;

(define test-cases-step-4
  '(
    (define flip (make-flip))
    (define flap1 (flip))
    (define (flap2) (flip))
    (define flap3 flip)
    (define (flap4) flip)
    flap1 (flap2) flap3 flap4 (flap4) '(flap1) flap2 (flap3) flap4 flap1 (flap3) (flap4)))

(do-tests 4) 

; Answers for each here:
; flap1 - 1
; (flap2) - 0
; flap3 - flip proc
; flap4 - proc
; (flap4) - flip proc
; (flap1) - error, trying to evaluate 1
; flap2 - proc
; (flap3) - 1
; flap4 - proc
; flap1 - 1
; (flap3) - 0
; (flap4) - flip proc


;;;;
;;;; Step 5. Lots of memory
;;;;

(define (make-prev init)
  (let ((value init))
    (lambda (m)
      (if (eq? 'forget m)
	  (begin 
	    (set! value init)
	    init)
	  (let ((prev value))
	    (set! value m)
	    prev)))))

(define test-cases-step-5
  '(
    (define prev1 (make-prev 'the-first-value-returned))
    (define prev2 (make-prev 'different))
    (prev1 1)
    (prev1 2)
    (prev2 2)
    (prev2 3)
    (prev2 4)
    (prev2 'forget)
    (prev2 5)
    (prev2 6)
    (prev1 3)))

(do-tests 5) 

