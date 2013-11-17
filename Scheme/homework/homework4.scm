;; ASSIGNMENT: Homework4
;; NAME: Harlan Iverson
;; X500: ivers300
;;   ID: 3476594
;; SECT: 2
;;
;; ITLabs Machine Tested On: apollo


;;;; ==================
;;;;    INSTRUCTIONS
;;;; ==================
;;   Read the homework assignment writeup carefully.
;;   Do not change the procedure names or the number of arguments they take.
;;   You may add helper/utility procedures as needed.
;;   Include all code needed to run your procedures within the template files.
;;   Follow proper formatting and commenting guidelines.


;;;; ===============================================
;;;;  Formatting/Commenting Information and Example
;;;; ===============================================
;;   Include enough comments so that someone unfamiliar with your code
;;   can quickly understand what your code is attempting to do.
;;
;;   For this assignment you:
;;     - Do NOT need to explain what the procedure is suppose to do.
;;     - Do NOT need to explain what the arguments are.
;;     - Do NOT need to explain what the return value is.
;;     - NEED to explain what steps take place in your code.
;;     - NEED to use proper spacing, returns, and indentation to make
;;       the code readable.  See the book for examples of formatting
;;       your code.
;; 

;;;; =======================
;;;;    Utility Functions
;;;; =======================

;; Reloads the current file.
(define (reload) (load "hw5.scm"))

;; Square
(define (square x) (* x x))

;; Identity
(define (identity x) x)
(define ident identity)

;; Filter
(define (filter predicate sequence)
  (cond ((null? sequence) ())
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))


;;;; ==================
;;;;    Testing Code
;;;; ==================
(define test-cases-prefix "test-cases-problem-")

;; ->string  --  Converts any object to a string representation.
(define (->string obj)
    (cond ((string? obj) obj)
	  ((symbol? obj) (symbol->string obj))
	  ((number? obj) (number->string obj))
	  ((alphabet? obj) (alphabet->string obj))
	  ((time-zone? obj) (time-zone->string obj))
	  ((wide-string? obj) (wide-string->string obj))
	  (else (with-output-to-string
		  (lambda () (write obj))))))

(define (get-tests-symbol suffix)
  (string->symbol (string-append test-cases-prefix 
				 (->string suffix))))

(define (do-tests suffix)
  (let* ((in-mit-scheme #t) 
	 (tests-symbol (get-tests-symbol suffix))
	 (display-string 
	  (string-append "\n--- Test Cases for Problem " (->string suffix)" ---\n"))
	 (test-cases (if in-mit-scheme 
			 (eval tests-symbol user-initial-environment)
			 (eval tests-symbol)))
	 (safer-eval (if in-mit-scheme (lambda (expr) (eval expr user-initial-environment)) eval))
	 (pp         (if in-mit-scheme pp         display))
	 (fresh-line (if in-mit-scheme fresh-line newline))
	 (side-effect-procedures '(define display pp for-each newline fresh-line))
	 (returns-value? (lambda (expr) (not (and (pair? expr) 
						  (member (car expr) side-effect-procedures))))))
    (fresh-line)
    (display display-string)

    (for-each 
     (lambda (expr)
       (cond ((not (returns-value? expr)) (safer-eval expr))	;; Handle define, display, etc.
	     (else (display expr) (display " => ") (display (safer-eval expr)) (newline))))
     test-cases)))


;;;; ===============
;;;;    PROBLEM 1
;;;; ===============

;;;  [Part A] -- Make Table
;;; ------------------------

;; Create an empty table consisting of two empty lists
(define (make-table)
  ;; for some reason append doesn't work on this...
  ;; '(() ())

  ;; it seems to work if the lists aren't empty initially
  '((#t) (#t))
)


;;;  [Part B] -- Lookup
;;; --------------------


;; util procs...
(define (get-keys table)
  (list-ref table 0))

(define (get-values table)
  (list-ref table 1))

(define (find-idx key remaining idx)
  (cond ((null? remaining) #f)
	((eq? key (car remaining)) idx)
	(else (find-idx key (cdr remaining) (+ idx 1)))))

(define (get-value values idx)
  (list-ref values idx))

;; Retrieves a record from the table via the key if it exists.  
;; Otherwise returns #f.
(define (lookup key table)
  (define idx (find-idx key (get-keys table) 0))

  (if (eq? #f idx)
      #f
      (get-value (get-values table) idx))
)


;;;  [Part C] -- Insert!
;;; ---------------------
		    
;; Inserts the key/value pair in the table and returns 'ok
(define (insert! key value table)
  (append! (get-keys table) (list key))
  (append! (get-values table) (list value))

  'ok
)

(define (super-insert! key value table)

  (define (replace-value! remaining idx new-value)
    (cond ((null? remaining) (error "invalid list offset..."))
	  ((= 0 idx) (set-car! remaining new-value))
	  (else (replace-value! (cdr remaining) (- idx 1) new-value)))

    'ok)

  (if (eq? #f (lookup key table))
      (insert! key value table)
      (let ((idx (find-idx key (get-keys table) 0)))
	(begin
	  (replace-value! (get-keys table) idx key)
	  (replace-value! (get-values table) idx value))))

)

;;;  Test Code
;;; -----------
(define test-cases-problem-1 
 '(
    (define myTable (make-table)) ; (() ())
    (insert! '+ + myTable) ; 'ok
    (insert! '- - myTable) ; 'ok
    (insert! '~ (lambda (x y) (if (< (abs (- x y)) 2) #t #f)) myTable) ; 'ok

    ((lookup '+ myTable) 2 3 4) ; 9
    ((lookup '- myTable) 3 2) ; 1
    ((lookup '~ myTable) 2 3) ; #t
    (lookup '* myTable) ; #f


    ;; update super insert
    (super-insert! '+ - myTable) ; 'ok
    ((lookup '+ myTable) 3 2) ; 1

    ;; new super insert
    (super-insert! '* * myTable) ; 'ok
    ((lookup '* myTable) 3 2) ; 6

    myTable



  ))

(do-tests 1)

;; See Lab Writeup For Additional Problems - Other Problems To Be Done in Python
