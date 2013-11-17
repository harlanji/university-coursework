;; ====== LAB 12 ======
;;    Author(s):  
;;                
;;  Lab Section:  

;;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab12.scm")  ; Change file name if copied to a new file.
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
;;;; Step 1.  Mutated Reverse
;;;;

(define (reverse! lst)
  
)


(define test-cases-step-1
  '(
    (reverse! '(a b f g))
    (reverse! '())
    (reverse! '(2 7 3))
    (reverse! '((1 2) (4 5))
    ))

;(do-tests 1) 

