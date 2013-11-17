;; =============================================================================
;;   Prior Abstractions
;; =============================================================================

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
(define origin (make-point 0 0))




;; distance
;; gets the distance between two points
;; inputs: pt1, pt2 - points, the points to get the distance of
;; output: number, the distance
(define (distance pt1 pt2)
  (sqrt
   (+
    (square (- (get-x pt2)(get-x pt1)))
    (square (- (get-y pt2)(get-y pt1))))))


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

;; taken from book, page 116
(define (accumulate op initial sequence)
  (if (null? sequence)
      initial
      (op (car sequence)
	  (accumulate op initial (cdr sequence)))))


;; reverse
;; reverse a list of items, non-recursively
;; inputs: ls - the list to reverse
;; output: list, the reversed list
(define (reverse ls)
  (define (helper remaining newls)
    (if (null? remaining)
        newls
        (helper
         (cdr remaining)
         (cons (car remaining) newls))))

  (helper ls '()))



;; =============================================================================
;;   Problem 1
;; =============================================================================

;;
;; converts an unsorted point list to a sorted point list
;; inputs: pt-list - a list of unsorted points
;; output: a list of sorted points from the given pt-list
;;
(define(convert-to-sorted-pt-list pt-list)
  (define (helper remaining newlst)
    (if (null? remaining)
	newlst
	(helper 
	 (get-rest-points remaining)
	 (make-sorted-pt-list (get-first-point remaining) newlst))))

  (helper pt-list '()))


(display (convert-to-sorted-pt-list2 (make-pt-list (make-point 1 1) (make-pt-list (make-point 3 3) (make-pt-list (make-point 2 2) ()))))) (newline)




;; =============================================================================
;;   Problem 2
;; =============================================================================

;;
;; gets a list of all numbers in a given list that have the same
;; remainder when divided by 2 as the first number
;; inputs: . args arbitrary number of number args
;; output: a list of numbers from given args that meet function description
;;
(define (same-mod . args)
  (define (helper remaining newlst expectedmod)
    (if (null? remaining)
	newlst
	; if the mod of the first item remaining matches
	(if (= expectedmod (remainder (car remaining) 2))
	    ; add it to the newls and carry on
	    (helper (cdr remaining) (cons (car remaining) newlst) expectedmod)
	    ; otherwise just carry on with the next item
	    (helper (cdr remaining) newlst expectedmod))))

  (helper args '() (remainder (car args) 2)))

; order isn't preserved
(display (same-mod 1 2 3 4 5 6 7))(newline)
(display (same-mod 2 3 4 5 6 7))(newline)


;; =============================================================================
;;   Problem 3
;; =============================================================================

;;
;; returns a list of the square roots of numbers in a given list
;; inputs: lst - a list of numbers
;; output: a list of square roots of lst
;;
(define (map-sum-sqrt-list lst)
  ; for each list of lists...
  (map (lambda (sublst)
	 ; add each item in the sublist
	 (accumulate + 0 
		     ; ... but first sqrt all items in sublst
		     (map sqrt sublst))) lst))



(display (map-sum-sqrt-list '((1 4 9) (4 25) (1 9))))(newline)

;;
;; define reverse 1st level sublists only
;; inputs: lst - a tree of numbers
;; output: a tree of numbers
;;
(define (map-reverse-sublists lst)
  (map (lambda (sublst)
	 (if (list? sublst)
	     (reverse sublst)
	     sublst)) lst))

(display (map-reverse-sublists '(1 2 3 4)))(newline)
(display (map-reverse-sublists '(1 (2 3) 4)))(newline)
(display (map-reverse-sublists '((1 2 3 4))))(newline)
(display (map-reverse-sublists '(0 1 (2 3 (4 5) 6 7) 8 9)))(newline)

;;
;; divide each element of a list by a given number.
;; inputs: lst - a list of numbers
;;         n - the number to divide by
;; output: a list of numbers, each elem of lst divided by n
(define (map-div-n lst n)
  (map (lambda (x)
	 (/ x n))
       lst))

(display (map-div-n '(100 200 300 400) 100))(newline)


;; =============================================================================
;;   Problem 4
;; =============================================================================

;;
;; makes a single, ordered list from two lists of numbers
;; inputs: setA, setB - ordered lists of numbers
;; output: a list containing all elements of A and B, sorted and non-distinct.
;;
(define (make-collection-from-sets setA setB)

  ;; convenience method for making the recursive call.
  ;; if m is 'a, it will car the first item from setA and call 
  ;; make-collection-from-sets with the cdr of setA and setB itself.
  ;; if the message is 'b, it does the same but with the car of setB, etc.
  (define (cons-from m)
    (cond 
     ((eq? 'a m) (cons (car setA) (make-collection-from-sets (cdr setA) setB)))
     ((eq? 'b m) (cons (car setB) (make-collection-from-sets setA (cdr setB))))
     (else (error "unknown message"))))


  ; this could be condensed into 4 conditions, but I left it 6 for clarity.
  (cond
   ; if both sets are empty, we are done
   ((and (null? setA) (null? setB)) '())
   ; if set A is empty then cons first of set B and carry on
   ((null? setA) (cons-from 'b))
   ; if set B is empty then cons first of set A and carry on
   ((null? setB) (cons-from 'a))
   ; if first of set A is less than first of set B cons it and carry on
   ((< (car setA) (car setB)) (cons-from 'a))
   ; if first of set A is less than first of set B cons it and carry on
   ((<= (car setB) (car setA)) (cons-from 'b))
   ; all cases should have been covered, so there is a problem
   (else (error "uknown condition"))))


(define mySet1 (list 2 5 7 8 12))
(define mySet2 (list 1 3 5 8 9 13))

(display (make-collection-from-sets mySet1 mySet2))(newline)