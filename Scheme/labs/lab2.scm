;;    Author(s):  Harlan Iverson
;;                
;;  Lab Section:  02



;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab2.scm")  ; Change file name if copied to a new file.
)


;;;; Example Procedure

;; Increments a number by a value of 1.
;; Inputs:  x -- a numerical value
;; Output:  Number that has been incremented.
;; Usage Example: (increment 3) returns 4

(define (increment x)
  (+ x 1))


;; Test Cases (Examples)
(display "1.1 Test Cases")
(newline)

(display (increment 5))    ;; Returns 6
(newline)
(display (increment -1))   ;; Returns 0
(newline)
(display (increment 0.5))  ;; Returns 1.5
(newline)



;;;; Step 1 - Primitive Data
;;;; ---------------------------------------------------

;; Answers:
;;  1: yes 
;;  2: no
;;  3: yes 
;;  4: yes 
;;  5: yes 
;;  6: yes 
;;  7: yes 
;;  8: no 
;;  9: no 
;; 10: no 
;; 11: no 
;; 12: no 
;; 13: no 
;; 14: no 
;; 15: no 
;; 16: no 
;; 17: no 
;; 18: yes 
;; 19: no 
;; 20: no 
;; 21: yes  


;;;; Step 2 - Expressions
;;;; ---------------------------------------------------

;; Part A - Exercise 1.2

(define a (+ 5 4 (- 2 (- 3 (+ 6 (/ 4 5))))))
(define b (* 3 (- 6 2) (- 2 7)))

(display "1.2 Part A")
(newline)

(/ a b)
(newline)

;; Part B - Average of 13, 92, 3, 16
(display "1.2 Part B")
(newline)

(/ (+ 13 92 3 16) 4)
(newline)


;;;; Step 3 - Abstracting Using Define
;;;; ---------------------------------------------------

;; Your Full Name  [myfullname]
(define myfullname "Harlan Jacob Iverson")

;; Your Lab Section  [mylabsection]
(define mylabsection "002")

;; Your Shorter Name  [myshortname]
(define myshortname "Harlan")

;; Expression From Step 2, Part B  [avg]
(define avg (/ (+ 13 92 3 16) 4))

;; Rules for Naming Identifiers:
;;  Any character except ( ) space ;
;;  Can not start with #
;;  Variable names can only contain 7-bit latin characters
;;  Any length variable name
;;  
;;  



;;;; Step 4 - Abstractions
;;;; ---------------------------------------------------

;; Do parts a through c at the Scheme interpreter prompt.
(define mult *)
(define * +)
(define + mult)

(define + *)
(define * mult)

(define add +)
(define sub -)
(define mul *)
(define div /)
(define squareroot sqrt)

;; Answer to part d:
;; The named aritmetic procedures can coexist with the 
;; symbolic arithmetic procedures.
;; 


;;;; Step 5 - Procedure Abstractions
;;;; ---------------------------------------------------

;; Cube Procedure:
;; return the cube of a given number
;; arguments: n - the number to cube
(define (cube n)
  (* n n n))



;; Invert Procedure:
;; return the reciprocal of a given number
;; arguments: n - the number to invert
(define (invert n)
  (if (= n 0)
      0
      (/ 1 n)))


;; Test Cases:

(define (testcube)
  (display "testcube")
  (newline)

  (display (= -8 (cube -2)))
  (newline)
  (display (= 0 (cube 0)))
  (newline)
  (display (= 8 (cube 2)))
  (newline)
)


(define (testinvert)
  (display "testinvert")
  (newline)

  (display (= 1/4 (invert 4)))
  (newline)
  ; do not use .2 because of floating point error
  (display (= 1/5 (invert 5)))
  (newline)
  ; ensure no divide by zero errors
  (display (= 0 (invert 0)))
  (newline)
  ; ensure that fractions invert
  (display (= 4 (invert 1/4)))
  (newline)
  ; ensure that negative numbers invert
  (display (= -4 (invert -1/4)))
  (newline)
)

(testinvert)
(testcube)


;;;; Step 6 - Larger Abstractions
;;;; ---------------------------------------------------

;; Positive Root Procedure  [quadpositive]
;; return the positive root of a quadratic equation
;; parameters: a b c - three degrees of the quadratic formula,
;;             most significant to least (x^2, x^1, x^0)
(define (quadpositive a b c)
  (define numer (+ (* -1 b) (sqrt (- (square b) (* 4 a c)))))
  (define denom (* 2 a))

  (/ numer denom))

;; Negative Root Procedure  [quadnegative]
;; return the negative root of a quadratic equation
;; parameters: a b c - three degrees of the quadratic formula,
;;             most significant to least (x^2, x^1, x^0)
(define (quadnegative a b c)
  (define numer (- (* -1 b) (sqrt (- (square b) (* 4 a c)))))
  (define denom (* 2 a))

  (/ numer denom))


;; What happens when taking the square roots of negative numbers?
;; Answer: An imaginary number is returned when the square root
;;         of a negative number is taken.
;; 

;; Test Cases:

(define (testquadpositive)
  (display "testquadpositive")
  (newline)

  ; positive discriminant (2 roots)
  (display (= 1 (quadpositive 1 0 -1)))
  (newline)
  ; zero discriminant (1 root)
  (display (= -1/2 (quadpositive 4 4 1)))
  (newline)
  ; negative discriminant (no roots = error)
  ;(display (quadpositive 2 1 2))
  ;(newline)
)

(define (testquadnegative)
  (display "testquadnegative")
  (newline)

  ; positive discriminant (2 roots)
  (display (= -1 (quadnegative 1 0 -1)))
  (newline)
  ; zero discriminant (1 root)
  (display (= -1/2 (quadnegative 4 4 1)))
  (newline)
  ; negative discriminant (no roots = error)
  ;(display (quadpositive 2 1 2))
  ;(newline)
)

(testquadpositive)
(testquadnegative)



;; What values can be successfully handled by the two procedures?
;; Answer: Quadratic equations with a non-positive constant (* x^0) can be
;;         handled because they have real roots
;; 

;; What values CANNOT be successfully handled by the two procedures?
;; Answer:  Quadratic equations with a positive constant can not be 
;;          handled because it has no real roots and the procedure 
;;          does not check for invalid values.
;; 



;;;; Step 7 - Procedures
;;;; ---------------------------------------------------

;; y=3x^2 - 8x - 3  [f]
;; evaluate the equation 3x^2 - 8x - 3 at a given value of x
;; parameters: x - the value of x (number) to evaluate at
(define (f x)
  (- (* 3 (square x)) (* 8 x) 3))

;; Test Cases:
(define (testf)
  (display "testf")
  (newline)

  (display (= -3 (f 0)))
  (newline)
  (display (= -8 (f 1)))
  (newline)
  (display (= 8 (f -1)))
  (newline)
)

(testf)

;; y=ax^2 - bx - c  [g]
;; return the value of an arbitrary quadratic at an arbitrary value of x
;; will fail when the value of any variable is not a number
;; parameters: a b c - three degrees of the quadratic formula,
;;             most significant to least (x^2, x^1, x^0). each is a number
;;             x - the value of x (number) to get the value at
(define (g a b c x)
  (- (* a (square x)) (* b x) c))


;; Test Cases:
(define (testg)
  (display "testg")
  (newline)

  ; 1x^2 - 0x - 1 at x=0 is 1
  (display (= 1 (g 1 0 -1 0)))
  (newline)
  ; 1x^2 - 0x - 1 at x=-1 is 2
  (display (= 2 (g 1 0 -1 -1)))
  (newline)
  ; 1x^2 - 0x - 1 at x=0 is 1
  (display (= 0 (g 1 0 0 0)))
  (newline)
  ; 1x^2 - 0x - 1 at x=0 is 1
  (display (= 1 (g 1 0 0 -1)))
  (newline))

(testg)

;;;; Step 8 - Symbolism
;;;; ---------------------------------------------------

;; Define new bindings:
(define cube1 cube)
(define cube2 cube)
(define (cube3 x) (* x x x))

;; Modify original cube procedure:

(define (cube x)
  (+ (* x x x) 1))

;; How does this new definition affect the other three cube procedures?
;; Answer:  The new definition does not affect the other cube procedures
;;          because they are bound to the original procedure and a newly 
;;          defined one, while the original variable (and not its data) are
;;          redefined.
;; 



