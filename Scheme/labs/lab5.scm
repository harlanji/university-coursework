
;; ====== LAB 5 ====== 
;;    Author(s): Harlan Iverson
;;                
;;  Lab Section: 02



;;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab5.scm")  ; Change file name if copied to a new file.
)



;; REMINDER:
;;   You must include test cases for all procedures you write.
;;   Thoroughly test each procedure and be prepared to demonstrate that the code works as expected.


;;;;
;;;; Step 1 - Using the Sum Abstraction
;;;;

;; Sum Abstraction Procedure from Text
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))


;
; Add the square root of each number between a and b inclusive.
; inputs: a, b - integers, b < a
; output: integer
;
(define (sumofsqrts a b)
  (sum 
   (lambda (x) (sqrt x)) 
   a 
   (lambda (x) (+ 1 x)) 
   b)) 


;
; Generate the factorial for a given number
; inputs: x - the number to create a factorial for (x >= 0)
; output: number, factorial for x
;
(define (fact x)
  (if (= x 0)
      1
      (* x (fact (- x 1)))))

;
; Returns the reciprocal of a factorial for x
; inputs: x - the number to create a reciprocal factorial for (x >= 0)
; output: number, reciprocal factorial for x
;
(define (invfact x) (/ 1.0 (fact x)))

;
; Add the reciprocal factorial of each number between a and b inclusive 
; (approximates e).
; inputs: a, b - integers, b < a
; output: integer
;
(define (sumofinvfacts a b)
  (sum
   invfact
   a
   (lambda (x) (+ x 1))
   b))


;
; The sum of a given function for all integers on [a,b], done iteratively
;
; inputs: a,b - numbers, inclusive interval to create sum for
;         term - a proc that takes the current interval as an argument 
;                and returns the value to include in the sum
;         next - a proc that takes the current interval as an argument
;                and returns the next one to operate on
; output: number, the sum
;
(define (sum-iter term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (+ result (term a)))))

  (iter a 0))


;
; Add the square root of each number between a and b inclusive, done iteratively
; inputs: a, b - integers, b < a
; output: integer
;
(define (sumofsqrts-iter a b)
  (sum-iter 
   (lambda (x) (sqrt x)) 
   a 
   (lambda (x) (+ 1 x)) 
   b)) 



;
; Add the reciprocal factorial of each number between a and b inclusive 
; (approximates e).
; inputs: a, b - integers, b < a
; output: integer
;
(define (sumofinvfacts-iter a b)
  (sum-iter
   invfact
   a
   (lambda (x) (+ x 1))
   b))





;; Test Code
(define sumofsqrt-0-3 (+ (sqrt 0) (sqrt 1) (sqrt 2) (sqrt 3)))
(define sumofinvfact-0-3 (+ (invfact 0) (invfact 1) (invfact 2) (invfact 3)))


(display "--- STEP 1 [PART A] TEST CASES ---") (newline)


(display (= sumofsqrt-0-3 (sumofsqrts 0 3)))(newline)


(display "--- STEP 1 [PART B] TEST CASES ---") (newline)


(display (= sumofinvfact-0-3 (sumofinvfacts 0 3)))(newline)

(display "--- STEP 1 [PART C] TEST CASES ---") (newline)


; same test cases as part a/b, but on iterative versions.
(display (= sumofsqrt-0-3 (sumofsqrts-iter 0 3)))(newline)
(display (= sumofinvfact-0-3 (sumofinvfacts-iter 0 3)))(newline)


;; Part A Answers: The results do not converge to any value. When the value
;;                 is very large a maximum recursion depth error is displayed.
;; 

;; Part B Answers: The results converge toward e (~2.718). When the value is 
;;                 very large a maximum recursion depth error is displayed.
;; 

;; Part C Answers: On very large values there is no maximum recursion error,
;;                 because they are tail-recursive and the interpreter doesn't
;;                 keep adding stack frames.




;;;;
;;;; Step 2 - Writing the Product Abstraction
;;;;

;; Step 2 Helper Procedures


;; 1.31 Recursive Solution for Product



;
; The product of a given function for all integers on [a,b] (big pi), 
; done recursively
;
; inputs: a,b - numbers, inclusive interval to create a product for
;         term - a proc that takes the current interval as an argument 
;                and returns the value to include in the product
;         next - a proc that takes the current interval as an argument
;                and returns the next one to operate on
; output: number, the product
;
(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
	 (product term (next a) next b))))



;
; Generate the factorial for a given number
; inputs: n - the number to create a factorial for (n >= 0)
; output: number, factorial for n
;
(define (factorial n)
  (product
   (lambda (x) x)
   1
   (lambda (x) (+ x 1))
   n))


;
; Approximate pie by adding all inverse factorials together on the
; interval [1,n]
;
; inputs: n - positive integer, the upper bound of the interval
; output: rational number, the approximation of e
;
(define (approxpi n)
  (define (xplus1 x) (+ x 1))

  (* 2 ; instead of 4 because the numer includes 2 2s
     (/ 
      ; 2 of each value between 1 and n
      (product
       ; x is even => x
       ; x is odd => x + 1 the next highest even
       (lambda (x) (if (odd? x) (+ x 1) x))
       1
       xplus1
       n)
      ;
      (product
       ; x > 2 => 1 to make 2/3, 4/3, 4/5, 6/5 pattern
       ; x is odd => x
       ; x is even => x + 1    the next highest odd
       (lambda (x) (cond ((< x 2) 1) ((odd? x) x) (else (+ x 1))))
       1
       xplus1
       n))))

;; 1.31 Iterative Solution for Product

;
; The product of a given function for all integers on [a,b] (big pi), 
; done iteratively
;
; inputs: a,b - numbers, inclusive interval to create a product for
;         term - a proc that takes the current interval as an argument 
;                and returns the value to include in the product
;         next - a proc that takes the current interval as an argument
;                and returns the next one to operate on
; output: number, the product
;
(define (product-iter term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (* result (term a)))))

  (iter a 1))


;
; Generate the factorial for a given number
; inputs: n - the number to create a factorial for (n >= 0)
; output: number, factorial for n
;
(define (factorial-iter n)
  (product-iter
   (lambda (x) x)
   1
   (lambda (x) (+ x 1))
   n))


;
; Approximate pie by adding all inverse factorials together on the
; interval [1,n]
;
; inputs: n - positive integer, the upper bound of the interval
; output: rational number, the approximation of e
;
(define (approxpi-iter n)
  (define (xplus1 x) (+ x 1))

  (* 2 ; instead of 4 because the numer includes 2 2s
     (/ 
      ; 2 of each value between 1 and n
      (product-iter
       ; x is even => x
       ; x is odd => x + 1 the next highest even
       (lambda (x) (if (odd? x) (+ x 1) x))
       1
       xplus1
       n)
      ;
      (product-iter
       ; x > 2 => 1 to make 2/3, 4/3, 4/5, 6/5 pattern
       ; x is odd => x
       ; x is even => x + 1    the next highest odd
       (lambda (x) (cond ((< x 2) 1) ((odd? x) x) (else (+ x 1))))
       1
       xplus1
       n))))



;; Test Code


; reusable method to test factorial procedures
(define (facttest proc)
  (display (= 1 (proc 0)))(newline)
  (display (= 1 (proc 1)))(newline)
  (display (= 6 (proc 3)))(newline))

; reusable method to test pi procedures (output some 
; values to show approximation)
(define (pitest proc)
  (display (exact->inexact (proc 1)))(newline)
  (display (exact->inexact (proc 5)))(newline)
  (display (exact->inexact (proc 50)))(newline)
  (display (exact->inexact (proc 500)))(newline)
  (display (exact->inexact (proc 5000)))(newline)
  (display (exact->inexact (proc 10000)))(newline)
)


(display "--- STEP 2 [PART A - FACTORIAL] TEST CASES ---") (newline)
(facttest factorial)


(display "--- STEP 2 [PART A - PI] TEST CASES ---") (newline)
(pitest approxpi)


(display "--- STEP 2 [PART B - FACTORIAL] TEST CASES ---") (newline)
(facttest factorial-iter)


(display "--- STEP 2 [PART B - PI] TEST CASES ---") (newline)
(pitest approxpi-iter)



;;;;
;;;; Step 3 - Taking the Abstraction Further
;;;;

;; 1.32 Recursive Solution

;
; The accumulation of a given function for all integers on [a,b] (big pi), 
; done recursively
;
; inputs: a,b - numbers, inclusive interval to create a product for
;         term - a proc that takes the current interval as an argument 
;                and returns the value to include in the product
;         next - a proc that takes the current interval as an argument
;                and returns the next one to operate on
;         combiner - procedure, the operation to use to combine 
;                    values (eg. + or *)
;         null-value - the identity for the combiner (eg. 0 for +, 1 for *)
; output: number, the accumulated value
;
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
	 (product term (next a) next b))))



;; 1.32 Iterative Solution

;
; The accumulation of a given function for all integers on [a,b] (big pi), 
; done iteratively
;
; inputs: a,b - numbers, inclusive interval to create a product for
;         term - a proc that takes the current interval as an argument 
;                and returns the value to include in the product
;         next - a proc that takes the current interval as an argument
;                and returns the next one to operate on
;         combiner - procedure, the operation to use to combine 
;                    values (eg. + or *)
;         null-value - the identity for the combiner (eg. 0 for +, 1 for *)
; output: number, the accumulated value
;
(define (accumulate-iter combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (combiner result (term a)))))

  (iter a null-value))



;; Test Code
(display "--- STEP 3 [PART A] TEST CASES ---") (newline)

; test multiply code as a factorial because it is simple
(facttest (lambda (n)
	    (accumulate
	     *
	     1
	     (lambda (x) x)
	     1
	     (lambda (x) (+ x 1))
	     n)))


(display "--- STEP 3 [PART B] TEST CASES ---") (newline)
; test multiply code as a factorial because it is simple
(facttest (lambda (n)
	    (accumulate-iter
	     *
	     1
	     (lambda (x) x)
	     1
	     (lambda (x) (+ x 1))
	     n)))




;;;;
;;;; Step 4 - Double Double
;;;;

;; 1.41 Solution

;
; Make a given procedure be called twice around the value given to the
; lambda that is returned
; inputs: proc - a procedure that takes a single argument of the same type
;                as its return value.
; output: a lambda that takes in an argument of the same type as proc, 
;         and returns a value of the same type.
;
(define (double proc)
  (lambda (x)
    (proc (proc x))))

;; Test Code
(display "--- STEP 4 TEST CASES ---") (newline)

(define (inc x)
  (+ x 1))

(display (= 7 ((double inc) 5)))(newline)
(display (= 21 (((double (double double)) inc) 5)))(newline)

;; Explaination:
;; (((double (double double)) inc) 5) will return 21 because inc is applied 16 times.
;; 
;; (double double) = (double (double proc))
;;                      4x      2x
;;
;; (double (double double)) = (double (double (double (double proc))))
;;                               16x     8x      4x      2x