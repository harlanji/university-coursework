
 ;; ====== LAB 4 ======  
;;    Author(s):  
;;                
;;  Lab Section:  


;;;; Utility Functions

;; Reloads the current file.
(define (reload)
 (load "lab4.scm")  ; Change file name if copied to a new file.
  )

(newline) ;; Ensures first line of test cases is on new line.


;;;;;;;;;;;;;;;;;;
;; REMINDER:
;;   You must include test cases for all procedures you write.
;;   Thoroughly test each procedure and be prepared to demonstrate that the code works as expected.
;;;;;;;;;;;;;;;;;;



;;;;
;;;; Step 1 - A Recursive Process
;;;;

;; helper method used by step 1 and 2
;; divides n by 3, 5, 7 and returns true if it is divisble by any. 
;; Q: include zero?
(define (div357? n) 
  (or (integer? (/ n 3)) (integer? (/ n 5)) (integer? (/ n 7))))


;; count-div357
;; inputs - a, b: integers where a > b
;; output - the number of unique terms in (a, b) 
;;          divisible by 3, 5 or 7 incl. 0.
(define (count-div357 a b)
  ; add 1 to a on each recusion, and stop when a > b.
  (if (> a b)
      0
      (+ (if (div357? a) 1 0) (count-div357 (+ 1 a) b))))

;; Test Code
(display "=== STEP 1 TEST CASES ===") (newline)
(display (= 1 (count-div357 0 0)))(newline)
(display (= 2 (count-div357 0 3)))(newline)
(display (= 4 (count-div357 0 6)))(newline)
(display (= 3 (count-div357 3 6)))(newline)
; tests unique count among all 3 divisors
(display (= 10 (count-div357 0 15)))(newline)



;;;;
;;;; Step 2 - Now Try It Iteratively
;;;;

;; iter-div357
;; inputs - a, b: integers where a > b
;; output - the number of unique terms in (a, b) 
;;          divisible by 3, 5 or 7 incl. 0.
(define (iter-div357 a b)
  (define (helper partial terms)
    (if (< b terms)
     ; return the solution if we're done computing
     partial
     ; otherwise recurse with the next term, and increment partial
     ; if the current term is div by 3 5 or 7
     (helper (if (div357? terms) (+ 1 partial) partial) (+ 1 terms))))


;;  (trace helper)

  (helper 0 a)
)


;; Test Code
(display "=== STEP 2 TEST CASES ===") (newline)
(display (= 1 (iter-div357 0 0)))(newline)
(display (= 2 (iter-div357 0 3)))(newline)
(display (= 4 (iter-div357 0 6)))(newline)
(display (= 3 (iter-div357 3 6)))(newline)
; tests unique count among all 3 divisors
(display (= 10 (iter-div357 0 15)))(newline)

;;;;
;;;; Step 3 - Tracing Your Code
;;;;

;; Differences found when tracing recursive and iterative procedures:
;; In the recursive process each procedure up the stack trace returns
;; the running sum, while in the iterative process the state is 
;; passed in the operands, and each level returns the final value to the 
;; caller. 



;;;;
;;;; Step 4 - Two More - One Iterative and One Recursive
;;;;

;; Recursive Procedure
(define (f n)
  (if (< n 3)
      n
      (+ (f (- n 1)) (* 2 (f (- n 2))) (* 3 (f (- n 3))))))


;; Iterative Procedure
(define (f-iter n)
  ; inputs - a,b,c: previous 3 base cases, f(n-3,2,1) respectively 
  ;          c: doubles as the running total
  ;          count: the number of iterations left (stops at 0)
  (define (helper a b c count)
    (cond
     ; base cases (should this be in the main body?)
     ((< n 3) n)
     ; terminal condition
     ((= n count) c)
     ; otherwise 
     ; a = f(n-3)
     ; b = f(n-2)
     ; c = f(n-1)
     (else (helper b c (+ (* 3 a) (* 2 b) c) (+ count 1)))))

;;  (trace helper)

  (helper 0 1 2 2))


;; Test Code
(display "=== STEP 4 TEST CASES ===") (newline)
(display "--- Recursive Results ---") (newline)

(display (= 0 (f 0)))(newline)
(display (= 1 (f 1)))(newline)
(display (= 2 (f 2)))(newline)
(display (= 4 (f 3)))(newline)
(display (= 59 (f 6)))(newline)


(display "--- Iterative Results ---") (newline)


(display (= 0 (f-iter 0)))(newline)
(display (= 1 (f-iter 1)))(newline)
(display (= 2 (f-iter 2)))(newline)
(display (= 4 (f-iter 3)))(newline)
(display (= 59 (f-iter 6)))(newline)


;;;;
;;;; Step 5 - Revisiting Fibonacci From the Text
;;;;

;; Recursive Fibonacci Procedure From Text
(define (fib n)
  (cond ((= n 0) 0)
        ((= n 1) 1)
        (else (+ (fib (- n 1))
                 (fib (- n 2))))))

;; Draw Graph on Paper

;; How many times does (fib 2) get called when calculating (fib 5)?
;; Answer:  3 times
;; fib(5) => 
;;    fib(4) => 
;;      fib(3) => 
;;        fib(2)
;;      fib(2)
;;    fib(3) => 
;;      fib(2)




