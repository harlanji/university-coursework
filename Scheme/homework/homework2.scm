;; =============================================================================
;; Problem 1
;; =============================================================================


;;     (define a (/ (* 6 3) (* 2 3)))

;;     (define (f x) (/ (+ (* x 3) 1) (+ x 1)))

;;     a                                       => 3

;;     (f 0)                                   => 1

;;     (f a)                                   => 5/2

;;     (f 1)                                   => 2

;;     (f (f 0))                               => 2

;;     (odd? (if (even? a) a (+ a 3)))         => #f

;;     ((lambda (x y) (+ (f x) (f y))) 3 a)    => 5

;;     ((if (even? a) - *) 4 5)                => 20

;;     (let ((temp (f a)))  
;;        (and (< temp 3) (> temp 0)))         => #t

;;     (define temp 5)

;;     (let ((temp (f 5)))
;;        (if (integer? temp)
;;          temp
;;          (round temp)))                     => 3



;; =============================================================================
;; Problem 2
;; =============================================================================


;;
;; Build and evaluate an n degree polynomial at x, with the coefficient for each
;; degree being the degree itself. eg. 1 + x + 2x^2 + 3x^3 ... nx^n.
;;
;; inputs: x - the value of x (any number)
;;         n - the degree of the polynomial (>= 0)
;; output: number, the value of the polynomial at x
;;
(define (P x n)
  (define (helper a partial)
    (cond
     ; just add 1 to the total
     ((= 0 a) (+ 1 partial))
     ; multiply a + partial by x to make each term
     ; of the polynomial the correct power.
     (else (helper (- a 1) (* x (+ a partial))))))

  (helper n 0))

;; my procedure is iterative so that it can compute fast
;; and without limit to the degree of the polynomial



(display "========== Problem 2 ==========")(newline)

; 0 degree
(display (= 1 (P 1 0)))(newline)
; 1 degree
(display (= 6 (P 5 1)))(newline)
; > 1 degree w / pos x, example case given
(display (= 103 (P 3 3)))(newline)
; > 1 degree w/ 0 x
(display (= 1 (P 0 3)))(newline)
; even degree w/ neg x
(display (= 7 (P -2 2)))(newline)
; odd degree w/ neg x
(display (= -17 (P -2 3)))(newline)


;; =============================================================================
;; Problem 3
;; =============================================================================

; Part A

;;
;; Return the modulus of two numbers.
;;
;; inputs: a,b - the two numbers to divide, b by a. (b > 0, a >= b)
;; output: number, the modulus of a and b.
;;
(define (mymodulo a b)
  (define (helper newa)
    (if (> b newa) 
	newa
	(helper (- newa b))))

  (helper a))


;; TODO test a and b for negative.

(display "========== Problem 3 ==========")(newline)

; 0 modulus
(display (= 0 (mymodulo 1 1)))(newline)
; pos modulus
(display (= 1 (mymodulo 3 2)))(newline)
; lots of iterations
(display (= 1 (mymodulo 300001 2)))(newline)

; Part B
; the algorithm is iterative so that it can handle large values 
; and be fast.


;; =============================================================================
;; Problem 4
;; =============================================================================




;; 
;; Create and return a lambda that applies the procedure f n times
;; to the single argument given to the lambda.
;;
;; Uses an iterative approach
;;
;; inputs: f - a procedure that takes a single argument and returns a value
;;             of the same type, to be repeatedly applied.
;;         n - the number of times to apply the procedure (n >= 1)
;; output: a lambda that takes a single argument of same type as its return
;;         value, that will apply f n times to given value.
;;
(define (repeated f n)
  (define (helper terms partial)
    (if (= 0 terms)
	partial
	(helper (- terms 1) (f partial))))

  (if (> 1 n)
      (error "n must be positive")
      (lambda (x) (helper n x))))


;;
;; Function composition, returns a lambda of form (f o g)(x)
;;
(define (compose f g)
  (lambda (x)
    (f (g x))))


;; 
;; Create and return a lambda that applies the procedure f n times
;; to the single argument given to the lambda.
;;
;; Uses the approach recommended by the book
;;
;; inputs: f - a procedure that takes a single argument and returns a value
;;             of the same type, to be repeatedly applied.
;;         n - the number of times to apply the procedure (n >= 1)
;; output: a lambda that takes a single argument of same type as its return
;;         value, that will apply f n times to given value.
;;
(define (repeated2 f n)
  (cond 
   ((> 1 n) (error "n must be positive"))
   ((= 1 n) f)
   (else (compose f (repeated2 f (- n 1))))))


;; TODO test neg, x, pos, non-square, methods with errors

(define (inc x) (+ x 1))

(display "========== Problem 4 ==========")(newline)

; pos value
(display (= 625 ((repeated square 2) 5)))(newline)
; neg input, should be pos output because x^2*n is always even
(display (= 625 ((repeated square 2) -5)))(newline)
; non-square w/ neg input
(display (= 3 ((repeated inc 5) -2)))(newline)



;; =============================================================================
;; Problem 5
;; =============================================================================

(define (square x) (* x x))

(define (cube-fourth x) (/ (* x x x) 4))

;;
;; Returns true if f is steeper than g for all x between 1 and n
;;
;; inputs: f,g - compare f to g
;;         n - compare for all x between 1 and n. must be >= 1.
;; output: predicate, true if f is steeper than g for all x between 1 and n.
;;
(define (steeper? f g n)
  (if (> 1 n)
      ; terminal condition: if we've made it this far in recursion stop
      #t
      ; if f is steeper between n and n+1, and deeper recurses are true
      (and 
       (> (- (f (+ n 1)) (f n)) 
	  (- (g (+ n 1)) (g n)))
       (steeper? f g (- n 1)))))

(display "========== Problem 5 ==========")(newline)

(display (eq? #t (steeper? square cube-fourth 2)))(newline)
(display (eq? #f (steeper? square cube-fourth 3)))(newline)  