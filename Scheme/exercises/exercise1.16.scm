(define (expt b n)
  (if (= 0 n)
      1
      (* b (expt b (- n 1)))))



(define (expt-iter b n)
  (define (helper terms partial)
    (if (< terms n)
	(helper (+ terms 1) (* partial b))
	partial))

  (helper 0 1))


(define (even? n)
  (= 0 (remainder n 2)))

(define (square n)
  (* n n))

(define (fast-expt b n)
  (cond 
   ((= 0 n) 1)
   ((even? n) (square (fast-expt b (/ n 2))))
   (else (* b (fast-expt b (- n 1))))))



(define (fast-expt-iter b n)
  (define (helper terms partial)
    (cond
     ; terminal condition
     ((= 0 terms) partial)
     ; special case
     ; fixme: how to get rid of this not?
     ((and (not (= n terms)) (even? terms)) (helper (/ terms 2) (square partial)))
     ; normal case
     (else (helper (- terms 1) (* partial b)))))

;;  (trace helper)

  (helper n 1))



(define (testexpt exptproc)
  ; happy
  (display (= 27 (exptproc 3 3)))(newline)
  ;coef of zero
  (display (= 0 (exptproc 0 3)))(newline)
  ; pow of 0
  (display (= 1 (exptproc 3 0)))(newline)
  ; neg coef odd pow
  (display (= -27 (exptproc -3 3)))(newline)
  ; neg coef even pow
  (display (= 4 (exptproc -2 2)))(newline)
)

(display "expt")(newline)
(testexpt expt)

(display "expt-iter")(newline)
(testexpt expt-iter)

(display "fast-expt")(newline)
(testexpt fast-expt)

(display "fast-expt-iter")(newline)
(testexpt fast-expt-iter)