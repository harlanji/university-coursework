(define (cube x) (* x x x))

(define (p x) (- (* 3 x) (* 4 (cube x))))

(define (sine angle)
   (if (not (> (abs angle) 0.1))
       angle
       (p (sine (/ angle 3.0)))))

(+ 5 77)


; a
; sine is called 6 times, p is applied 4 times
; wrong: p is applie 5 times. why??

; b
; 