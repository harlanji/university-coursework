;; ====== LAB 9 ======
;;    Author(s):  Harlan Iverson
;;                
;;  Lab Section:  2

;;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab9.scm")  ; Change file name if copied to a new file.
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




;; display+ displays all of the values with a newline at the end.
(define (display+ . args)
  (for-each
    (lambda (item) (display item))
    args)
  (newline))

;;;;
;;;; Step 1 - A Quick Warm Up
;;;;


(define test-cases-step-1
 '(

   (define step1_list1 '(1 3 (5 7) 9))
   ;; Write Solution On Next Line:
   (car (cdr (car (cdr (cdr step1_list1)))))

   (define step1_list2 '((7)))
   ;; Write Solution On Next Line:
   (car (car step1_list2))

   (define step1_list3 '(1 (2 (3 (4 (5 (6 7)))))))
   ;; Write Solution On Next Line:
   (cadr (cadr (cadr (cadr (cadr (cadr step1_list3))))))

  ))

(do-tests 1)



;;;;
;;;; Step 2 - More on Abstractions
;;;;

;;  expmod Procedure From the Text
;; --------------------------------
(define (expmod base exp m)
  (define square (lambda (x) (* x x)))
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder (square (expmod base (/ exp 2) m))
                    m))
        (else
         (remainder (* base (expmod base (- exp 1) m))
                    m))))         


;;  list-expmod -- Without Using Map
;; ----------------------------------

; FIXME/QUESTION iterative approach that doesn't leave list backwards?
; (define (list-expmod item-list exp m)
;   (define (helper remaining newlst)
;     (if (null? remaining)
; 	newlst
; 	(helper (cdr remaining) (cons (expmod (car remaining) exp m) newlst))))

;   (helper item-list '())
; )

(define (list-expmod item-list exp m)
  (if (null? item-list)
      '()
      (cons (expmod (car item-list) exp m) (list-expmod (cdr item-list) exp m)))
)


;;  map-expmod -- Using Map
;; -------------------------
(define (map-expmod item-list exp m)
  (map (lambda (x) (expmod x exp m)) item-list)
)


;;  deep-list-expmod
;; ------------------
(define (deep-list-expmod item-list exp m)
  (map (lambda (x) 
	 (if (list? x) 
	     (deep-list-expmod x exp m)
	     (expmod x exp m)))
       item-list)
)


;;  Test Cases
;; ------------
(define test-cases-step-2
 '(
    (list-expmod '(1 2 3 4 5) 2 3)  ; (1 1 0 1 1)
    (list-expmod '(1 2) 3 10)  ; (1 8)
    (list-expmod '(3) 3 10)  ; (7)
    (list-expmod '() 2 3)  ; ()

    (map-expmod '(1 2 3 4 5) 2 3)  ; (1 1 0 1 1)
    (map-expmod '(1 2) 3 10)  ; (1 8)
    (map-expmod '(3) 3 10)  ; (7)
    (map-expmod '() 2 3)  ; ()

    (deep-list-expmod '(1 2 3 4 5) 2 3)  ; (1 1 0 1 1)
    (deep-list-expmod '(1 2) 3 10)  ; (1 8)
    (deep-list-expmod '(3) 3 10)  ; (7)
    (deep-list-expmod '() 2 3)  ; ()
    (deep-list-expmod '(((3))) 3 10)  ; (((7)))
    (deep-list-expmod '((1 2) (3 ((4) 5))) 2 3)  ; ((1 1) (0 ((1) 1)))
  ))

(do-tests 2)



;;;;
;;;; Step 3 - Set Representation and 
;;;;          Computational Complexity
;;;;

;;; Part A

(define (make-set-from-list list1)
;   (define (helper remaining newlst)
;     (if (null? remaining)
; 	; end of list
; 	newlst
; 	(let ((x (car remaining)))
; 	      (helper remaining
; 		      ; make newlst either newlst with the item or newlst as it was
; 		      (if (not (member x newlst))
; 			  ; if x isn't in the list then add it
; 			  (cons x newlst)
; 			  ; otherwise skip it
; 			  newlst)))))

;   (helper list1 '())
  (define (helper remaining newlst)
    (if (null? remaining)
	newlst
	(helper
	 (cdr remaining)
	 (if (member (car remaining) newlst)
	     newlst
	     (cons (car remaining) newlst)))))

  (helper list1 '())

)

;;  Test Cases
;; ------------
(define test-cases-step-3
 '(
    (make-set-from-list '(5 2 7 4 5 2 1 1 2 5)) ; (7 4 1 2 5)
    (make-set-from-list '(7 7)) ; (7)
    (make-set-from-list '(7)) ; (7)
    (make-set-from-list '()) ; ()
  ))

(do-tests 3)


;;; Part B

;; Computational Complexity of make-set-from-list:
;; O(n^2) because make-set-from-list itself runs in O(n) but makes a call to member which
;; is presumably O(n) itself for each element of n.
   



;;;;
;;;; Step 4 - Extending the Set Abstraction
;;;;

(define (set-diff setA setB)
  (cond
   ; no more items to check, end of list
   ((null? setA) '())
   ; no more items in comparison list, rest must be different
   ((null? setB) setA)

   ; a > b so check the next b
   ((> (car setA) (car setB)) (set-diff setA (cdr setB)))
   ; a = b, so a is contained within b... move on
   ((= (car setA) (car setB)) (set-diff (cdr setA) (cdr setB)))
   ; a < b which means that is is not contained within b. add to result set and move on
   ((< (car setA) (car setB)) (cons (car setA) (set-diff (cdr setA) setB)))
   (else (error "invalid condition"))))

;;  Test Cases
;; ------------
(define test-cases-step-4
 '(
    (set-diff '(1 5 7 9) '(1 7 8 9 10)) ; (5)
    (set-diff '(1 5 7 9) '(7 8 9 10))   ; (1 5)
    (set-diff '(1 5 7 9) '(1 7 8 9))    ; (5)
    (set-diff '(0 1 5 7 9) '(1 7 8 9))  ; (0 5)
    (set-diff '(1 5 7 9) '())           ; (1 5 7 9)
    (set-diff '(9) '(1 7 8 9 10))       ; ()
    (set-diff '(1 5 7 9) '(1 5 7 9))    ; ()
    (set-diff '() '())                  ; ()
    (set-diff '() '())                  ; ()
  ))


(do-tests 4)
