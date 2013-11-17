;; ====== LAB 7 ======  
;;    Author(s):  
;;               
;;  Lab Section: 


;;;; Utility Functions

;; Reloads the current file.
(define (reload)
  (load "lab7.scm")  ; Change file name if copied to a new file.
)

;; display+ displays all of the values with a newline at the end.
(define (display+ . args)
  (for-each
    (lambda (item) (display item))
    args)
  (newline))



;; REMINDER:
;;   You must include test cases for all procedures you write.
;;   No credit will be given without test cases showing working code.
;;   
;;   This lab gives specific instructions for testing the code.
;;   These are minimum requirements, but you may do further tests as needed.
;;   Use define to store the results of your tests so they can be used in future
;;   steps.
;;
;;   Read through the lab writeup for full instructions and hints on how to
;;   approach this lab.
;;
;;   Also pay attention to hints and clarifications provided in this template
;;   regarding the test cases.



;;;;
;;;; Step 1 - Getting Warmed Up
;;;;

;; Recursive accumulate procedure from Lab 5:
(define (accumulate combiner null-value term a next b)
  (cond ((> a b) null-value)
        (else (combiner
                (term a)
                (accumulate combiner null-value term (next a) next b)))))


;; Test Code

(display+ "--- STEP 1 - Integers From 1 to 10 ---")
;; Example Of How To Call/Display:
;;  (display+ (accumulate ... ))

(display+ (accumulate cons () (lambda (x) x) 1 (lambda (x) (+ x 1)) 10))


(display+ "--- STEP 1 - Squares of Integers From 23 to 28 ---")
(display+ (accumulate cons () (lambda (x) (square x)) 23 (lambda (x) (+ x 1)) 28))
(display+ "--- STEP 1 - Powers of 2 from 2 to 4096 ---")

(display+ (accumulate cons () (lambda (x) (expt 2 x)) 1 (lambda (x) (+ x 1)) 12))

(display+ "--- STEP 1 - Integers from 1 to 10 (Iterative) ---")


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
  (define (iter n result)
    ; changed from > to < to support decremention
    (if (< n b)
	result
	; reversed order of combiner operands to support cons
	(iter (next n) (combiner (term n) result))))

;  (trace iter)

  (iter a null-value))


(define list1to10 (accumulate-iter 
		   cons 
		   () 
		   (lambda (x) x) 
		   10 
		   (lambda (x) (- x 1)) 
		   1))


(display+ list1to10)


;;;;
;;;; Step 2 - Point Abstraction: Starting a 2-Dimensional Point System
;;;;

;; make-point
;; make a point given an x and y value
;;
;; inputs: x,y - integers, the x and y coordinates respectively
;; output: a point
(define (make-point x y)
  (cons x y))

;; get-x
;; get the x coordinate given a point
;;
;; inputs: pt-list - a list containing points created by
;;                   make-pt-list
;; output: integer, x coordinate
(define (get-x p)
  (car p))


;; get-y
;; get the y coordinate given a point
;;
;; inputs: pt-list - a list containing points created by
;;                   make-pt-list
;; output: integer, y coordinate
(define (get-y p)
  (cdr p))


;; Test Code Instructions:
;;   Define a new point.  Display it.
;;   Display the x and y values separately using your selectors.
;;   You may use this point in future tests as well.

;; Note:
;;   The above is done for you below -- just uncomment those lines.
;;   You may want to define some other points here to use in future steps.

(display+ "--- STEP 2 TEST CASES ---")
;; Example Test Case:
;;   (define pt1 (make-point 2 4))
;;   (display+ "Point: "pt1)            ;; Expecting (2 . 4)
;;   (display+ "X-Coord: " (get-x pt1)) ;; Expecting 2
;;   (display+ "Y-Coord: " (get-y pt1)) ;; Expecting 4

;; Define Additional Points:

(define pt1 (make-point 2 4))
(display+ "Point: "pt1)            ;; Expecting (2 . 4)
(display+ "X-Coord: " (get-x pt1)) ;; Expecting 2
(display+ "Y-Coord: " (get-y pt1)) ;; Expecting 4

(define pt2 (make-point 0 6))
(display+ "Point: "pt1)        
(display+ "X-Coord: " (get-x pt1))
(display+ "Y-Coord: " (get-y pt1))


(define pt3 (make-point 7 10))
(display+ "Point: "pt1)           
(display+ "X-Coord: " (get-x pt1))
(display+ "Y-Coord: " (get-y pt1))


(define pt4 (make-point -2 -5))
(display+ "Point: "pt1)         
(display+ "X-Coord: " (get-x pt1))
(display+ "Y-Coord: " (get-y pt1))




;;;;
;;;; Step 3 - Maintaining a List of Points
;;;;

;; make-pt-list
;; make a list of points given a point and a list of points (could be
;; the-empty-pt-list)
;;
;; inputs: p - the point to add to the beginning of the list
;;         pt-list - the list to add onto
;; output: a list with pt-list and p at the beginning
(define (make-pt-list p pt-list)
  (cons p pt-list))


;; the-empty-pt-list
;; an empty list of points to be used as the intial value to make-pt-list
(define the-empty-pt-list ())

;; get-first-point
;; gets the first point from a point list created with make-pt-list
;; inputs: pt-list - the point list
;; output: a point
(define (get-first-point pt-list)
  (car pt-list))

;; get-rest-points
;; gets a list containing all except the first point from a list of points
;; created with make-pt-list
;;
;; inputs: pt-list - the point list
;; output: list of points except the first
(define (get-rest-points pt-list)
  (cdr pt-list))



;; Test Code:
;;   Using make-pt-list and the-empty-pt-list, define a list with 6+ points.
;;   Show the list after each point is added.
;;   Display the entire list, the first point, and all but the first point.
;;   Display the second point.
;;   Display all except the first two points.

(display+ "--- STEP 3 - Building The List ---")
;; How to start building the list:
;;  (define my-point-list (make-pt-list pt1 the-empty-pt-list))
;;  (display+ my-point-list)
;;
;;  (define my-point-list (make-pt-list pt2 my-point-list))
;;  (display+ my-point-list)
;;
;; Continue adding points...

(define my-point-list (make-pt-list pt1 the-empty-pt-list))
(display+ my-point-list)

(define my-point-list (make-pt-list pt2 my-point-list))
(display+ my-point-list)

(define my-point-list (make-pt-list pt3 my-point-list))
(display+ my-point-list)

(define my-point-list (make-pt-list pt4 my-point-list))
(display+ my-point-list)



(display+ "--- STEP 3 - First Point ---")
(display+ (get-first-point my-point-list))


(display+ "--- STEP 3 - Second Point ---")
(display+ (get-first-point (get-rest-points my-point-list)))


(display+ "--- STEP 3 - All Except First Two Points ---")
(display+ (get-rest-points (get-rest-points my-point-list)))


;;;;
;;;; Step 4 - Operations on pt-lists
;;;;

;; sum-xcoord
;; gets the sum of x coordinates in a list
;; inputs: pt-list - the list of points
;; output: intenger, the sum
(define (sum-xcoord pt-list)
  (if (null? pt-list)
      0
      (+ (get-x (get-first-point pt-list)) (sum-xcoord (get-rest-points pt-list)))))

;; max-xcoord
;; get the maximum x in a list of points
;; inputs: pt-list - list of points
;; output: integer, the maximum x value
;; FIXME
(define (max-xcoord pt-list)
  (define (helper max remaining)
    (if (null? remaining)
	max
	(helper
	 (if (< max (get-x (get-first-point remaining)))
	     (get-x (get-first-point remaining))
	     max)
	 (get-rest-points remaining))))

  ;; QUESTION is this bad form to get first point like this?
  (helper (get-x (get-first-point pt-list)) pt-list))


;; distance
;; gets the distance between two points
;; inputs: pt1, pt2 - points, the points to get the distance of
;; output: number, the distance
(define (distance pt1 pt2)
  (sqrt
   (+
    (square (- (get-x pt2)(get-x pt1)))
    (square (- (get-y pt2)(get-y pt1))))))


;; max-distance
;; gets the max distance between a point and all points in a list
;; inputs: p - the point to compare to
;;         pt-list - the list of points
;; output: number, the max distance
(define (max-distance p pt-list)
  (define (helper max-dist remaining)
    (if (null? remaining)
	max-dist
	(helper
	 (max max-dist (distance p (get-first-point remaining)))
	(get-rest-points remaining))))

  (helper 0 pt-list))



;; Test Code
;;   Use the list you created in step 3 and the point created in step 2.
;;   Show the results you get using these values in the above operations.
;;   Test the procedures with an empty point list as well.

(display+ "--- STEP 4 - sum-xcoord ---")
(display+ "List: " my-point-list)
(display+ "Sum of x values: " (sum-xcoord my-point-list))
(display+ "List: " the-empty-pt-list)
(display+ "Sum of x values: " (sum-xcoord the-empty-pt-list))

(display+ "--- STEP 4 - max-xcoord ---")
(display+ (max-xcoord my-point-list))


(define neg-points (make-pt-list (make-point -2 2) the-empty-pt-list))
(define neg-points (make-pt-list (make-point -5 2) neg-points))


(display+ (max-xcoord neg-points))


(display+ "--- STEP 4 - distance ---")
; straight line on y axis
(display+ (= 4 (distance (make-point 1 1) (make-point 1 5))))
; straight line on x axis
(display+ (= 4 (distance (make-point 1 1) (make-point 5 1))))
; 3/4/5 triangle from origin
(display+ (= 5 (distance (make-point 0 0) (make-point 3 4))))


(display+ "--- STEP 4 - max-distance ---")
(display+ (max-distance (make-point 0 0) my-point-list)) ; expect ~12.206


;;;;
;;;; Step 5 - One More Operation on pt-lists
;;;;

;; max-range
;; gets the maximum distance between two points on the given list
;; inputs - point list
;; output - number
(define (max-range pt-list)

  ;; checks each given point (remaining) against all points in pt-list and
  ;; returns the maximum.
  ;; inputs: max-dist - the running maximum distance between two points
  ;;         remaining - the unchecked points
  ;; output: number
  (define (helper max-dist remaining)
    (if (null? remaining)
        max-dist
	(helper (let (
		      ; local-max is the max distance between the point we're looking at
		      ; and all the other points in the list
		      (local-max (max-distance (get-first-point remaining) pt-list)))
		  ; use the maximum or our new local-max and the previous maximum
		  (max local-max max-dist))



		(get-rest-points remaining))))

  (helper 0 pt-list))


;; Test Code:
;;   Use the list from part 3 to test this operation.
;;   Create a second point list with at least 5 entries for additional tests.
(define diag-coord (/ (sqrt 50) 2))

(define d10-h-list (make-pt-list (make-point -5 0) (make-pt-list (make-point 5 0) the-empty-pt-list)))
(define d10-v-list (make-pt-list (make-point 0 -5) (make-pt-list (make-point 0 5) the-empty-pt-list)))
(define d10-diag-list (make-pt-list (make-point (* -1 diag-coord) (* -1 diag-coord)) (make-pt-list (make-point diag-coord diag-coord) the-empty-pt-list)))


(display+ "--- STEP 5 TEST CASES ---")
; tests for several points
(display+ (max-range my-point-list)) ;; expect ~17.4928

; tests directions
(display+ (= 10 (max-range d10-h-list)))
(display+ (= 10 (max-range d10-v-list)))
(display+ (= 10 (max-range d10-diag-list)))


;;;;
;;;; Step 6 - A Question
;;;;

;; Answer to Question: It is important to use existing abstractions when possible because abstractions embody
;;                     concepts such as organizing points, distance, max distance that may change in implementation 
;;                     but are used the same, and higher level abstractions should not break because of this.
;;




;;;;
;;;; Step 7 - Maintaining a Sorted Point-List
;;;;


(define origin (make-point 0 0))

;; make-sorted-pt-list
;; similar to make-pt-list, except adds them in order by distance from origin (closest first).
;; assumes pt-list is in sorted order before p is added (ie. the whole list was created using 
;; make-sorted-pt-list).
;; inputs: p - a point created by make-point
;;         pt-list - a list of points created with this proc
;; output: the new list with p in the proper position
(define (make-sorted-pt-list p pt-list)
  (define (helper remaining)
    (cond
     ; no more remaining means p is at the end
     ((null? remaining) (make-pt-list p the-empty-pt-list))
     ; if p is closer to the origin, put it in the list and append the remaining (incl. the point we just checked) on the end
     ((> (distance origin (get-first-point remaining))
	 (distance origin p)) (make-pt-list p remaining))
     ; otherwise leave the point where it is and try the next one
     (else (make-pt-list (get-first-point remaining) (helper (get-rest-points remaining))))))

  (helper pt-list))


;; Answer to Question: Sofar maintaining lists in order would not be of any benefit. Storing points in order
;;                     might be beneficial for certain cases of finding maximum distance and things that depend
;;                     on that abstraction.
;;
;;
;;

;; Test Code:
;;   Create a sorted list of at least 6 points.
;;   Be sure to test addition of points to the front, back, and middle.
;;   Show the list after each point is added.


(display+ "--- STEP 7 TEST CASES ---")

(define test-point (make-point 3 3))

(define first-list (make-pt-list (make-point 4 4) (make-pt-list (make-point 5 5) the-empty-pt-list)))
(define middle-list (make-pt-list (make-point 2 2) (make-pt-list (make-point 5 5) the-empty-pt-list)))
(define end-list (make-pt-list (make-point -1 -1) (make-pt-list (make-point 2 2) the-empty-pt-list)))

(display+ (make-sorted-pt-list test-point first-list))
(display+ (make-sorted-pt-list test-point middle-list))
(display+ (make-sorted-pt-list test-point end-list))