#| ====== LAB 10 ======  
 |
 |    Author(s):  
 |  Lab Section:
 |  
 |#


;;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab10.scm")  ; Change file name if copied to a new file.
)

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



;; Square
(define (square x) (* x x))

; Tagged data code from text page 176

(define (attach-tag type-tag contents)
  (cons type-tag contents))

(define (type-tag datum)
  (if (pair? datum)
      (car datum)
      (error "Bad typed datum -- TYPE")))

(define (contents datum)
  (if (pair? datum)
      (cdr datum)        
      (error "Bad typed datum -- CONTENTS")))       

; Two-Dimensional Table code Modified from Text Section 3.3

(define (2d-get key-1 key-2 table)
          (let ((subtable (assoc key-1 (cdr table))))
            (if subtable
                (let ((record (assoc key-2 (cdr subtable))))
                  (if record
                      (cdr record)
                      ()))
                ())))

(define (2d-put! key-1 key-2 value table)
          (let ((subtable (assoc key-1 (cdr table))))
            (if subtable
                (let ((record (assoc key-2 (cdr subtable))))
                  (if record
                      (set-cdr! record value)
                      (set-cdr! subtable
                                (cons (cons key-2 value)
                                      (cdr subtable)))))
                (set-cdr! table
                          (cons (list key-1
                                      (cons key-2 value))
                                (cdr table)))))
          'ok)

(define (make-table)
          (list '*table*))

; Generic operator analagous to more general apply-generic from page 184
; in the text.  Uses a specified table to be compatible with 2dtable.scm 
; for systems that do not include tables by default

(define (operate op obj t)
    (let ((proc (2d-get op (type-tag obj) t)))
        (if (not (null? proc))
            (proc (contents obj))
            (error "undefined operator for this type")
        )
    )
)  


;; Main Table for Data Directed Programming
(define T (make-table))

;; REMINDER:
;;   You must include test cases for all procedures you write.
;;   No credit will be given without test cases showing working code.
;;   
;;   Be prepared to demonstrate that the code works as expected.


;;;;
;;;; Step 1 - Writing a Temperature Package for Fahrenheit Temperatures
;;;;

(define (install-fahrenheit-package)

  (define (make-from-fahrenheit value)
    (attach-tag 'fahrenheit value)
  )

  (define (make-from-celsius value)
    (make-from-fahrenheit (+ 32 (* 1.8 value)))
  )

  (define (make-from-kelvin value)
    (make-from-fahrenheit (+ 32 (* 1.8 (- value 273.15))))
  )

  (define (get-fahrenheit temp)
    temp
  )

  (define (get-celsius temp)
    (/ (- temp 32) 1.8)
  )

  (define (get-kelvin temp)
    (+ 273.15 (/ (- temp 32) 1.8))
  )

  ; Here insert all the above procedures into the 2D table T with
  ; appropriate labels - key 1 should be the procedure name and
  ; key 2 should be the type for example 'fahrenheit 

  (2d-put! 'make-from-fahrenheit 'fahrenheit make-from-fahrenheit T)
  (2d-put! 'make-from-celsius 'fahrenheit make-from-celsius T)
  (2d-put! 'make-from-kelvin 'fahrenheit make-from-kelvin T)
  (2d-put! 'get-fahrenheit 'fahrenheit get-fahrenheit T)
  (2d-put! 'get-celsius 'fahrenheit get-celsius T)
  (2d-put! 'get-kelvin 'fahrenheit get-kelvin T)

  ; Return value
  'done
)


;;;;
;;;; Step 2 - Writing a Temperature Package for Celsius and Kelvin Representations
;;;;

(define (install-celsius-package)

  ;; Define all of the same procedures, but for the Celsius
  ;; representation

  (define (make-from-fahrenheit value)
    (make-from-celsius (/ (- value 32) 1.8))
  )

  (define (make-from-celsius value)
    (attach-tag 'celsius value)
  )

  (define (make-from-kelvin value)
    (make-from-celsius (- value 273.15))
  )

  (define (get-fahrenheit temp)
    (+ 32 (* 1.8 temp))
  )

  (define (get-celsius temp)
    temp
  )

  (define (get-kelvin temp)
    (+ 273.15 temp)
  )



  ;; Here insert all the above procedures into the 2D table T with
  ;; appropriate labels - key 1 should be the procedure name and
  ;; key 2 should be the type for example 'celsius
  

  (2d-put! 'make-from-fahrenheit 'celsius make-from-fahrenheit T)
  (2d-put! 'make-from-celsius 'celsius make-from-celsius T)
  (2d-put! 'make-from-kelvin 'celsius make-from-kelvin T)
  (2d-put! 'get-fahrenheit 'celsius get-fahrenheit T)
  (2d-put! 'get-celsius 'celsius get-celsius T)
  (2d-put! 'get-kelvin 'celsius get-kelvin T)
  
  ;; Return value
  'done
  )


(define (install-kelvin-package)

  ;; Define all of the same procedures, but for the Celsius
  ;; representation

  (define (make-from-fahrenheit value)
    (make-from-kelvin (+ 273.15 (/ (- value 32) 1.8)))
  )

  (define (make-from-celsius value)
    (make-from-kelvin (+ 273.15 value))
  )

  (define (make-from-kelvin value)
    (attach-tag 'kelvin value)
  )

  (define (get-fahrenheit temp)
    (+ 32 (* 1.8 (- temp 273.15)))
  )

  (define (get-celsius temp)
    (- temp 273.15)
  )

  (define (get-kelvin temp)
    temp
  )



  ;; Here insert all the above procedures into the 2D table T with
  ;; appropriate labels - key 1 should be the procedure name and
  ;; key 2 should be the type for example 'celsius
  

  (2d-put! 'make-from-fahrenheit 'kelvin make-from-fahrenheit T)
  (2d-put! 'make-from-celsius 'kelvin make-from-celsius T)
  (2d-put! 'make-from-kelvin 'kelvin make-from-kelvin T)
  (2d-put! 'get-fahrenheit 'kelvin get-fahrenheit T)
  (2d-put! 'get-celsius 'kelvin get-celsius T)
  (2d-put! 'get-kelvin 'kelvin get-kelvin T)

  ;; Return value
  'done
  )


;;;;
;;;; Step 3 - Generic Temperature Operations and Installation
;;;;

(define (make-fahrenheit-from-fahrenheit value)
  (operate 'make-from-fahrenheit (attach-tag 'fahrenheit value) T)
)

(define (make-fahrenheit-from-celsius value)
  (operate 'make-from-celsius (attach-tag 'fahrenheit value) T)
)

(define (make-fahrenheit-from-kelvin value)
  (operate 'make-from-kelvin (attach-tag 'fahrenheit value) T)
)

(define (make-celsius-from-fahrenheit value)
  (operate 'make-from-fahrenheit (attach-tag 'celsius value) T)
)

(define (make-celsius-from-celsius value)
  (operate 'make-from-celsius (attach-tag 'celsius value) T)
)

(define (make-celsius-from-kelvin value)
  (operate 'make-from-kelvin (attach-tag 'celsius value) T)
)

(define (make-kelvin-from-fahrenheit value)
  (operate 'make-from-fahrenheit (attach-tag 'kelvin value) T)
)

(define (make-kelvin-from-celsius value)
  (operate 'make-from-celsius (attach-tag 'kelvin value) T)
)

(define (make-kelvin-from-kelvin value)
  (operate 'make-from-kelvin (attach-tag 'kelvin value) T)
)

(define (get-fahrenheit temp)
  (if (procedure? temp)
      (temp 'get-fahrenheit)
      (operate 'get-fahrenheit temp T))
)

(define (get-celsius temp)
  (if (procedure? temp)
      (temp 'get-celsius)
      (operate 'get-celsius temp T))
)

(define (get-kelvin temp)
  (if (procedure? temp)
      (temp 'get-kelvin)
      (operate 'get-kelvin temp T))
)


;; Test Code for Steps 1-3:
(display "=== TEST CASES [Steps 1-3] ===") (newline)

;; Install Packages as Shown in Lab Write-Up
(display "------ Install Packages ------") (newline)
(install-fahrenheit-package)
(install-celsius-package)
(install-kelvin-package)

(display "------ Created Objects and Test Cases ------")

(define test-cases-step-3
 '(
   (define a (make-fahrenheit-from-fahrenheit 212)) ;212
   (define b (make-fahrenheit-from-celsius 100))    ;212
   (define c (make-fahrenheit-from-kelvin 373.15))  ;212
   (define d (make-celsius-from-fahrenheit 212))    ;100
   (define e (make-celsius-from-celsius 100))       ;100
   (define f (make-celsius-from-kelvin 373.15))     ;100
   (define g (make-kelvin-from-fahrenheit 212))     ;373.15
   (define h (make-kelvin-from-celsius 100))        ;373.15
   (define i (make-kelvin-from-kelvin 373.15))      ;373.15

   (get-fahrenheit a) ;212
   (get-fahrenheit b) ;212
   (get-fahrenheit c) ;212
   (get-celsius a)    ;100
   (get-celsius b)    ;100
   (get-celsius c)    ;100
   (get-kelvin a)     ;373.15
   (get-kelvin b)     ;373.15
   (get-kelvin c)     ;373.15

   (get-fahrenheit d) ;212
   (get-fahrenheit e) ;212
   (get-fahrenheit f) ;212
   (get-celsius d)    ;100
   (get-celsius e)    ;100
   (get-celsius f)    ;100
   (get-kelvin d)     ;373.15
   (get-kelvin e)     ;373.15
   (get-kelvin f)     ;373.15

   (get-fahrenheit g) ;212
   (get-fahrenheit h) ;212
   (get-fahrenheit i) ;212
   (get-celsius g)    ;100
   (get-celsius h)    ;100
   (get-celsius i)    ;100
   (get-kelvin g)     ;373.15
   (get-kelvin h)     ;373.15
   (get-kelvin i)     ;373.15

 ))

(do-tests 3)


;;;;
;;;; Step 4 - Hot, Cool, Cold?
;;;;

;; temp-list must contain at least 1 category
(define (closest-temp-category temp temp-list)
  (define (get-temp lst)
    (get-celsius (caar lst)))

  (define (get-cat lst)
    (cdar lst))

  ; for convenience always compare as celsius
  (set! temp (get-celsius temp))

  (define (helper curtemp curcat remaining)
    ; no more categories = use current one
    (cond ((null? remaining) curcat)
	  ; temp < curtemp = use current category
	  ((<= temp curtemp) curcat)
	  (else 
	   ; set variables for things used a lot
	   (let ((nexttemp (get-temp remaining))
		 (nextcat (get-cat remaining)))
	     ; if temp is greater than the next temp then just recurse (we know that
	     ; there are more remaining already from above)
	     (cond ((> temp nexttemp) (helper nexttemp nextcat (cdr remaining)))
		   ; compare the difference between the current/next temp and temp itself..
		   ; use the higher (next) one if it has a smaller difference, and 
		   ; lower (current) one if they are equal or that difference is smaller
		   ((< (- nexttemp temp) (- temp curtemp)) nextcat)
		   (else curcat))))))
		  

  ; we assume there is at least one temp in the list
  (helper (get-temp temp-list) (get-cat temp-list) (cdr temp-list)))
	  

(display "=== TEST CASES [STEP 4] ===") (newline)

  (define temp-list '(((celsius . 0) . freezing)
                      ((celsius . 10) . cool) 
                      ((celsius . 20) . warm)
                      ((celsius . 30) . hot)))

  (define t1 (make-fahrenheit-from-fahrenheit 100)) 
  (define t2 (make-celsius-from-fahrenheit 30)) 
  (define t3 (make-kelvin-from-celsius 15)) 
  (define t4 (make-fahrenheit-from-kelvin 290)) 
  (define t5 (make-celsius-from-kelvin 320)) 
    
(define test-cases-step-4
 '(
  (closest-temp-category t1 temp-list) ; hot
  (closest-temp-category t2 temp-list) ; freezing
  (closest-temp-category t3 temp-list) ; cool
  (closest-temp-category t4 temp-list) ; warm
  (closest-temp-category t5 temp-list) ; hot
  ))

(do-tests 4)

;;;;
;;;; Step 5 - An Intelligent Upgrade
;;;;

;; Part A
(define (make-mp-from-fahrenheit value)
  (define (dispatch m)
    (cond ((eq? 'get-fahrenheit m) value)
	  ((eq? 'get-celsius m) (/ (- value 32) 1.8))
	  ((eq? 'get-kelvin m) (+ 273.15 (/ (- value 32) 1.8)))
	  (else (error "invalid message"))))

  dispatch
)

(define (make-mp-from-celsius value)
  (define (dispatch m)
    (cond ((eq? 'get-fahrenheit m) (+ 32 (* value 1.8)))
	  ((eq? 'get-celsius m) value)
	  ((eq? 'get-kelvin m) (+ 273.15 value))
	  (else (error "invalid message"))))

  dispatch
)

;; Part B: Now modify your procedures in part 3 to handle the 
;;         message passing representation as well. The two
;;         representation should be able to coexist.

;  ... above

;; Part c:
;; Answer: closest-temp-category is able to work with both representations because 
;;         it uses the procedure get-celsius which handles abstraction of the representation
;;         of the numbers.
;; 
;; 

(display "--- STEP 5 TEST CASE ---") (newline)
(define j (make-mp-from-fahrenheit 212))
(define k (make-mp-from-celsius 100))
(define t6 (make-mp-from-fahrenheit 100)) 
(define t7 (make-mp-from-fahrenheit 30)) 
(define t8 (make-mp-from-celsius 15)) 
(define t9 (make-mp-from-celsius 16)) 

(define test-cases-step-5
 '(
    (get-fahrenheit a) ; 212
    (get-fahrenheit j) ; 212
    (get-fahrenheit k) ; 212
    (get-celsius a)    ; 100
    (get-celsius j)    ; 100
    (get-celsius k)    ; 100
    (get-kelvin a)     ; 373.15
    (get-kelvin j)     ; 373.15
    (get-kelvin k)     ; 373.15

    (closest-temp-category t6 temp-list) ; hot
    (closest-temp-category t7 temp-list) ; freezing
    (closest-temp-category t8 temp-list) ; cool
    (closest-temp-category t9 temp-list) ; warm
))

(do-tests 5)
