;; =============================================================================
;; Problem 1
;; =============================================================================


;(define first (* 2 -3)) 
;
;(- 30 first)                            => 36
;
;(define (trio x y z) 
;  (- (+ x y) z)) 
;
;(/ first (trio 5 2 8))                  => 6
;
;(trio first 8 1)                        => 1
;
;((if (> (trio 5 2 -6) first) / -) 10 5) => 2
;
;(* (if (and (> first -30) (< first 30)) 2 3) first) => -12
;
;(trio (trio 2 3 4) 5 6)                 => 0
;
;(trio (trio (trio 2 3 5) 5 6) (trio 8 7 14) (trio 1 2 3))  => 0
;(define unix #t)
;
;(define vista #t)
;
;(cond (unix "unix")
;	(vista  "vista"))
;                                        => "unix"
;
;(cond ((NOT unix) "unix")
;	(vista "vista"))
;                                        => "vista"
;
;(cond ((> first 0) 0)
;      ((<= first 2) (/ first 2))
;      (else first))                     => -3



;; =============================================================================
;; Problem 2
;; =============================================================================

(define (square n) 
  (* n n)
)

(define (odd? n)
  (= 1 (modulo n 2)))



(define (mult-odd-squares n) 
  ; nested method to iterate. starts at the given value and runs recursively,
  ; decrementing n and passing in the new running total.
  ;
  ; inputs - n: the number to square if odd
  ;          total: the running value of the multiplication. start with 1.
  ; outputs - the total of the odd square multiplication
  (define (mult-odd-squares-iter n total)
    ; code that will be evaluated if none of the special cases are true
    (define (doit)
      (mult-odd-squares-iter 
       (- n 1) 
       ; multiply the total by the square if odd, or 1 if even
       (* total 
          (if (odd? n) 
              (square n) 1)))
    )

    (cond 
      ((or (not (integer? n)) (> 0 n)) "error: please enter a positive integer")
      ; return the total if the value is zero
      ((= n 0) total)
      ; recursively evaluate the iterator with n decremented
      (else (doit)))
    )
  
  (mult-odd-squares-iter n 1)
)

(display "mult-odd-squares")(newline)

(display (= 225 (mult-odd-squares 6)))(newline)
(display (= 1 (mult-odd-squares 2)))(newline)
(display (string=? "error: please enter a positive integer" (mult-odd-squares -2)))(newline)
(display (string=? "error: please enter a positive integer" (mult-odd-squares .5)))(newline)
(display (string=? "error: please enter a positive integer" (mult-odd-squares -.5)))(newline)


;; =============================================================================
;; Problem 3
;; =============================================================================


; n can not be 0
(define (count-multiple n end)
  (define (ismultiple?)
    (integer? (/ end n)))

  
  (cond
    ; sanity
    ((or (not (integer? n)) (not (integer? end))) "error: operands must be integers")
    ; count zero as a multiple
    ((= 0 end) 1)
    ; recurse and add 1 to the return value if "max" is a multiple
    (else (+ (count-multiple n (- end 1)) (if (ismultiple?) 1 0)))
    )
)


(display "count-multiple")(newline)
(display (= 6 (count-multiple 2 10)))(newline)
(display (= 4 (count-multiple 3 9)))(newline)
(display (= 1 (count-multiple 4 0)))(newline)
(display (= 3 (count-multiple 5 13)))(newline)
(display (string=? "error: operands must be integers" (count-multiple "a" 13)))(newline)
(display (string=? "error: operands must be integers" (count-multiple 13 "b")))(newline)



;; =============================================================================
;; Problem 4
;; =============================================================================

(define (fact n)
  (define (helper terms partial)
    (if (< terms n)
	(helper (+ terms 1) (* partial (+ terms 1)))
	partial))

;;  (trace helper)

  (helper 0 1)
)

(define (este n)
  (define (helper terms partial)
    (if (< terms n)
	(helper (+ terms 1) (+ partial (/ 1 (fact terms))))
	partial))

  (helper 0 0)
)


(display "este")(newline)

(display (= 5/2 (este 3)))(newline)
(display (= 65/24 (este 5)))(newline)
(display (= 98641/36288 (este 10)))(newline)

;; =============================================================================
;; Problem 5
;; =============================================================================


(define (divides? a b)
  (= (remainder b a) 0))


(define (find-lcf n m)
  (find-divisor n m 2))


(define (find-divisor n m test-divisor)
  (cond ((or (> test-divisor n)
                 (>  test-divisor m)) "No common factor")
           ((and (divides? test-divisor n)
                    (divides? test-divisor m))  test-divisor)
           (else (find-divisor n m (next test-divisor)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (next n)
  (if (= n 2)
      3
      (+ 2 n)))

;; How much faster do you expect the new version of find-divisor to be?
;;
;; Answer: The new version should be roughly 2x as fast as the old one, 
;; because it uses the fact that if a number is not divisible by two 
;; it is not divisible by any multiple of two and so does not check them.


;; =============================================================================
;; Problem 6 - Cancelled
;; =============================================================================


;; =============================================================================
;; Problem 7
;; =============================================================================


; finds the logarithmic base of a number that is a power of three
; inputs - n: the number that is a power of 3
; output - the logarithmic base, or #f if the number is not a power of 3
(define (power-of-3 n)
  ; iteratively find higher powers of 3
  ; inputs - partial: the running product of the previous power
  ;          pow: the power of the previous calulation
  (define (power-of-3-iter partial pow)
    (if (< n (* 3 partial))
	; return false if this number is bigger than n
	#f
	(if (= n (* 3 partial))
	    ; if it matches, return the power plus 1 (why?)
	    (+ 1 pow)
	    ; otherwise check the next power
	    (power-of-3-iter (* 3 partial) (+ 1 pow)))))

  (power-of-3-iter 1 0)
)

(display "power-of-3")(newline)

(display (eq? #f (power-of-3 0)))(newline)
(display (= 4 (power-of-3 81)))(newline)

  
