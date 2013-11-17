;;;;    Author(s):  
;;;;                
;;;;  Lab Section:



;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab3.scm")  ; Change file name if copied to a new file.
)


;;;; Example Procedure

;; Determines if a object is a positive negative integer or real.
;; Inputs:  object -- a numerical value
;; Output:  String with number type information.
;; Usage Example: (num_type 5.2)

(define (num_type object)
  (cond ((eq? 0 object) "Zero")
        ((integer? object)      ; True if integer, big int, 
                                ;   or floating point integer
          (if (positive? object)
            "Positive Integer"
            "Negative Integer"))
        ((real? object)          ; True for all other floating point values.
          (if (positive? object) 
            "Positive Floating Point Number"
            "Negative Floating Point Number"))
        (else "Not A Number")))  ; Object is not a numerical type.


;; Test Cases (Examples)
(newline)(newline)
(display "== Example Test Cases ==") (newline)
(display (num_type 5))     ; "Positive Integer"
(newline)
(display (num_type 5.0))   ; "Positive Integer"
(newline)
(display (num_type -2.3))  ; "Negative Floating Point Number"
(newline)




;;;; Step 1 - Write a New Divide
;; Divides a by b after verifying b is not 0.
;; Inputs: a b the two values to divide, may be any type that can be divided with /
;; Output: the value of a divided by b, or "error" on failure. 
;; Usage Example: (/ 2 4)
(define (divide a b)
  (cond 
   ((not (number? a)) "error") ;: a is not a number")
   ((not (number? b)) "error") ;: b is not a number")
   ((eq? 0 b) "error") ; : denominator is zero")
   (else (/ a b))  ;; Add error checking!
  )
)

;; Test Cases for divide
(display "== Step 1 Test Cases ==") (newline)
(display (divide 5 2)) (newline)  ; Expected Result: 5/2
(display (divide "5" 2)) (newline)
(display (divide 5 "2")) (newline)
(display (divide 5 0)) (newline)
;; Add more test cases.



;;;; Step 2 - Normal vs. Applicative Order Evaluation
;; Part A Answer:  In normal order evaluation myProcedure should return
;;                 20 and get no division error because (/ a b) will never
;;                 be evaluated.
;; 




;; Part B Answer:  In applicative order evaluation myProcedure should get a 
;;                 divide by zero error when myProcedure is called because
;;                 each operand is evaluated before the procedure is applied.
;; 



;;;; Step 3 - Write a Procedure
;; isTriangle?
(define (isTriangle? a b c)

  ; purposely override a b and c since different combinations
  ; will be used to validate sides
  (define (validSides? a b c)
    (> (+ a b) c))

  (and (validSides? a b c) (validSides? c b a) (validSides? c a b))
)



;; Test Cases for isTriangle?
(display "== Step 3 Test Cases ==") (newline)
; test valid side length combinations
(display (isTriangle? 1.0 1.0 1.0)) (newline)
(display (isTriangle? 1.51 3.0 1.51)) (newline)
(display (isTriangle? 1.0 3.5 4.0)) (newline)
; test invalid side length combinations
(display (isTriangle? 1.0 3.0 4.0)) (newline)
(display (isTriangle? 4.0 1.0 3.0)) (newline)
(display (isTriangle? 3.0 4.0 1.0)) (newline)

;;;; Step 4 - Logical Thinking
;; minimum1 -- return the smallest of 4 numbers
;; declare a helper method isSmallest to simpliify several comparisons
(define (minimum1 a b c d)
  (define (isSmallest? n) (and (<= n a) (<= n b) (<= n c) (<= n d)))

  (cond
   ((isSmallest? a) a)
   ((isSmallest? b) b)
   ((isSmallest? c) c)
   ((isSmallest? d) d)
   (else "error"))
)

;; Test Cases for minimum1
(display "== Step 4a Test Cases ==") (newline)
(display (minimum1 9 8 7 6)) (newline)
(display (minimum1 8 7 6 9)) (newline)
(display (minimum1 7 6 9 8)) (newline)
(display (minimum1 6 9 8 7)) (newline)

;; minimum2 -- return the smallest of 4 numbers (different algorithm)
;; recursively find the smallest of two pairs of numbers
(define (minimum2 a b c d)

  ; locally override and b, doesn't matter
  (define (smallest2 a b)
    (if (>= a b) b a))

  (smallest2
   (smallest2 a b)
   (smallest2 c d))
)

;; Test Cases for minimum2
(display "== Step 4b Test Cases ==") (newline)
(display (minimum2 9 8 7 6)) (newline)
(display (minimum2 8 7 6 9)) (newline)
(display (minimum2 7 6 9 8)) (newline)
(display (minimum2 6 9 8 7)) (newline)



;;;; Step 5 - Encapsulation

(define a 1000)

(define pi 3.1415926)            ; first pi

(define radius 2)                ; first radius

(define (area radius)            ; second radius
    (* pi radius radius))        ; second pi, third radius

(define (circumference radius)   ; fourth radius
    (define pi 3.1)              ; third pi
    (define (diameter radius)    ; fifth radius
        (* 2 radius))            ; sixth radius
    (* pi (diameter radius))     ; fourth pi, seventh radius
)

(define (volume radius)          ; eighth radius
    (define pi 3)                ; fifth pi
    (* pi radius radius radius)  ; sixth pi, ninth radius
)

;; Evaluate The Following By Hand First, Then Check In Interpreter.
;; a. (area 100)         =>  31415.926
;; b. (circumference 10) =>  62
;; c. (volume 1)         =>  27
;; d. (area radius)      =>  12.5663704 
;; e. (circumference a)  =>  6200
;; f. (volume radius)    =>  24
;; g. In general, how will the above code be affected if the third pi line
;;    is deleted? The volume procedure will return a slightly higher answer
;;                because pi will be 3.1415926 instead of 3.
;;    
;; h. In general, how will the above code be affected if "radius" is removed
;;    as a parameter of the diameter on the "fifth radius" line?
;;    The code won't be affected because diameter will get "radius" from the
;;    symbol table of "circumference"


;;;; Step 6 - Special Cases

(define (iffy predicate consequent alternative)
  (cond (predicate consequent)
        (else alternative)
  )
)

;; Answer The Following:
;; Using iffy in the same way you would use if:
;; a. When will it work, if ever? 
;; 
;; Iffy will work when there are no side effects of "alternative" being evaluated
;; even if the "predicate" is falss.
;; 
;; b. When will it fail, if ever? 
;;
;; It will fail if "alternative" has side effects (ie. modifies a variable)
;; 
;; c. Is it really nessecary for if to be a special form?  Why? 
;;
;; It is necessary for "if" to be a special form in applicative-order interpretors
;; in order to behave consistently and not evaluate "alternative" when "predicate" is false.
;; In a normal-order interpretor, "if" could be implemented without a special form since 
;; (and) and (or) are a special form (by the Scheme spec) and allow short-circuit evaluation:
;;
;; (define (if predicate condition alternative) (or (and predicate condition) alternative))).
;; 




