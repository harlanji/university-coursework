;; ivers300.scm 
;; Author: Harlan Iverson (ivers300)
;; successfully tested on appollo.itlabs


(define player-procedure
  (let () 

    ;; load regular expression support
    (load-option 'regular-expression)

    (define *NUM-ROWS* 6)
    (define *NUM-COLUMNS* 7)
    
    (define *PLAYER-1-SYMBOL* 'x)
    (define *PLAYER-2-SYMBOL* 'o)
    (define *EMPTY-SYMBOL* '())
    (define *ANY-SYMBOL* 'a)


    ;; helper to give the idx for use with a list-ref if needed
    (define (for-each-idx proc list)
      (define idx 0)
      (for-each (lambda(item) (proc item idx) (set! idx (+ 1 idx))) list))


    ;; =====================================================
    ;;   Pattern
    ;; =====================================================


    ;; creates an offsensive/defensive pattern
    (define (make-pattern rows #!optional weight)
      ;; take care of default value for weight
      (if (default-object? weight) (set! weight 1))


      ;; get a copy of the current pattern, flipped to work on the
      ;; right side
      (define (get-flipped)
	(define (flip . myrows) myrows)
	;; creates a list with the n element of each list as its own row
	(make-pattern (reverse (apply map flip rows)) weight))

      (define (symbol->regex symbol player-symbol)
	(define p1regex (if (eq? *PLAYER-1-SYMBOL* player-symbol) "[x\ ]" "x"))
	(define p2regex (if (eq? *PLAYER-2-SYMBOL* player-symbol) "[o\ ]" "o"))

	(cond ((eq? *ANY-SYMBOL* symbol) ".")
	      ((eq? *EMPTY-SYMBOL* symbol) " ")
	      ((eq? *PLAYER-1-SYMBOL* symbol) p1regex)
	      ((eq? *PLAYER-2-SYMBOL* symbol) p2regex)
	      (else (error "symbol->regex: unkonwn symbol"))))

      (define (get-width) (length (car rows)))
      (define (get-height) (length rows))
      (define (get-weight) weight)


      (define (get-player-positions player-symbol)
	(define positions '())

	(for-each-idx (lambda (cols i-row) 
			(for-each-idx (lambda (symbol i-col)
					(if (eq? player-symbol symbol)
					    (set! positions (append positions (list (make-position i-row i-col)))))
					) cols)
			) rows)

	positions)


      ;; we purposefully don't have trailing periods because part of a pattern might
      ;; be the last piece on the board
      (define (make-regex n-cols player-symbol)
	(define regex "")

	(for-each (lambda (cols)
		    (for-each (lambda (col)
				(set! regex (string-append regex (symbol->regex col player-symbol)))
				) cols)

		    (set! regex (string-append regex (make-string (- n-cols (get-width)) #\.)))
		    )  rows)

	;; chop off the last few periods
	(set! regex (string-head regex (- (string-length regex) (- n-cols (get-width)))))

	regex)


      ;; helper proc to go from a position to a coordinate
      ;; returns a position created with make-position
      (define (offset-to-position n-cols)
	(lambda (n) 
	  (let ((col (remainder n n-cols))
		(row (floor (/ n n-cols))))

	    (make-position row col))))


      ;; TODO move this to pattern
      ;; find all matches of a pattern on the board and return a list of
      ;; position objects
      (define (find-all-matches board player-symbol)
	(define (helper offset positions)
	  (define board-string (board 'get-string))

	  (if (>= offset (string-length board-string))
	      positions
	      (let* (
		     (pattern-string (make-regex (board 'get-n-cols) player-symbol))
		     (m (re-substring-search-forward pattern-string board-string offset (string-length board-string))))
		(if (eq? #f m)
		    positions
		    ;; for simplicity we're just adding the offset, but we will map the
		    ;; result of this proc to translate it to positions
		    (helper (+ 1 (re-match-start-index 0 m)) (cons (re-match-start-index 0 m) positions))))))

	;; translate
	(map (offset-to-position (board 'get-n-cols)) (helper 0 '())))


      (define (dispatch m . args)
	(cond ((eq? 'get m) rows)
	      ((eq? 'get-flipped m) (get-flipped))
	      ;; args - 0= width, 1= player-symbol
	      ((eq? 'get-regex m) (apply make-regex args))
	      ((eq? 'get-width m) (get-width))
	      ((eq? 'get-height m) (get-height))
	      ((eq? 'get-weight m) (get-weight))
	      ((eq? 'get-player-positions m) (get-player-positions (list-ref args 0)))
					; arg0 = string: pattern, arg1 = sumbol: player-symbol
	      ((eq? 'find-all-matches m) (apply find-all-matches args))
	      (else (error "make-pattern: unknown message"))))

      dispatch)


    ;; =====================================================
    ;;   Position
    ;; =====================================================


    ;; creates a position which can be either absolute or relative...
    ;; you can add two positions together using the add message
    (define (make-position row col #!optional weight)
      ;; take care of default value for weight
      (if (default-object? weight) (set! weight 1))

      ;; add two positions together and return the result
      (define (add pos)
	(make-position (+ row (pos 'get-row))
		       (+ col (pos 'get-col))))

      (define (dispatch m . args)
	(cond ((eq? 'get-row m) row)
	      ((eq? 'get-col m) col)
	      ((eq? 'get-weight m) weight)
	      ((eq? 'add m) (add (list-ref args 0)))

	      (else (error "make-position: unknown message"))))


      dispatch)


    ;; =====================================================
    ;;  Board
    ;; =====================================================


    ;; creates a representation of board that is friendly to the regex
    ;; matching. constructed by using the native board directly.
    (define (make-board raw-board)

      ;; translate a board symbol into a string representation to be regex'd
      (define (symbol->board-string symbol)
	(cond ((eq? *EMPTY-SYMBOL* symbol) " ")
	      ((eq? *PLAYER-1-SYMBOL* symbol) "x")
	      ((eq? *PLAYER-2-SYMBOL* symbol) "o")
	      (else (error "symbol->board-string: unkonwn symbol"))))

      ;; only define board-string once when it is constructed
      ;; rather than every time get-string is called
      (define board-string "")
      (for-each (lambda (cols)
		  (for-each (lambda (x)
			      (set! board-string (string-append board-string (symbol->board-string x)))
			      ) cols)
		  ) raw-board)



      (define (get-string) board-string)
      (define (get-n-cols) (length (car raw-board)))
      (define (get-n-rows) (length raw-board))


      (define (empty? x y)
	(define symbol (list-ref (list-ref raw-board y) x))
	(eq? *EMPTY-SYMBOL* symbol))


      (define (can-move-top? x y)
	;; iterate through each row up to y and check column x
	(define (helper remaining n-y)
	  

	  (cond ((null? remaining) #t)
		;; if we're at the row past y, make sure that it's either the bottom of the board
		;; or there is another piece to land on
		((= n-y (+ 1 y)) 
		 (not (eq? *EMPTY-SYMBOL* (list-ref (car remaining) x))))
		;; if we've run out of or run past n rows, true
		((> n-y y) #t)
		;; if we encounter an empty symbol, good sign... 
		;; keep going with next row
		((eq? *EMPTY-SYMBOL* (list-ref (car remaining) x))
		 (helper (cdr remaining) (+ 1 n-y)))
		;; otherwise there is something in the way
		(else #f)))

	(helper raw-board 0))

      (define (can-move-left? x y)
	;; iterate through row y and check each column up to x
	(define (helper remaining n-x)
	  ;; same idea as can-move-top? see above
	  (cond ((null? remaining) #t)
		((= n-x (+ 1 x)) 
		 (not (eq? *EMPTY-SYMBOL* (car remaining))))
		((> n-x x) #t)
		((eq? *EMPTY-SYMBOL* (car remaining))
		 (helper (cdr remaining) (+ 1 n-x)))
		(else #f)))

	(helper (list-ref raw-board y) 0))


      ;; returns 'top, 'left, or #f to indicate movement ability.
      (define (can-move? x y)

	(if (> x (get-n-cols)) (error "invalid x given"))
	(if (> y (get-n-rows)) (error "invalid y given"))

	(cond ((can-move-top? x y) 'top)
	      ((can-move-left? x y) 'left)
	      (else #f)))

      (define (get-position x y)
	(if (> x (get-n-cols)) (error "invalid x given"))
	(if (> y (get-n-rows)) (error "invalid y given"))

	(list-ref (list-ref raw-board y) x))


      (define (dispatch m . args)
	(cond ((eq? 'get-string m) (get-string))
	      ((eq? 'get-n-cols m) (get-n-cols))
	      ((eq? 'get-n-rows m) (get-n-rows))
	      ;; args = x,y
	      ((eq? 'can-move? m) (apply can-move? args))
	      ;; args = x,y
	      ((eq? 'get-position m) (apply get-position args))

	      (else (error "make-board: unkown message"))))


      dispatch)


    ;; =====================================================
    ;;   Sorted Position List - Modified from lab 7 sorted
    ;;                          point list
    ;; =====================================================



    ;; make-pt-list
    ;; make a list of points given a point and a list of points (could be
    ;; the-empty-pt-list)
    ;;
    ;; inputs: p - the point to add to the beginning of the list
    ;;         pt-list - the list to add onto
    ;; output: a list with pt-list and p at the beginning
    (define (make-position-list p pt-list)
      (cons p pt-list))


    ;; the-empty-pt-list
    ;; an empty list of points to be used as the intial value to make-pt-list
    (define the-empty-pos-list ())

    ;; get-first-point
    ;; gets the first point from a point list created with make-pt-list
    ;; inputs: pt-list - the point list
    ;; output: a point
    (define (get-first-position pt-list)
      (car pt-list))

    ;; get-rest-points
    ;; gets a list containing all except the first point from a list of points
    ;; created with make-pt-list
    ;;
    ;; inputs: pt-list - the point list
    ;; output: list of points except the first
    (define (get-rest-positions pt-list)
      (cdr pt-list))

    ;; make-sorted-pt-list
    ;; similar to make-pt-list, except adds them in order by distance from origin (closest first).
    ;; assumes pt-list is in sorted order before p is added (ie. the whole list was created using 
    ;; make-sorted-pt-list).
    ;; inputs: p - a point created by make-point
    ;;         pt-list - a list of points created with this proc
    ;; output: the new list with p in the proper position
    (define (make-sorted-position-list p pt-list)
      (define (helper remaining)
	(cond
					; no more remaining means p is at the end
	 ((null? remaining) (make-position-list p the-empty-pos-list))
					; if p is closer to the origin, put it in the list and append the remaining (incl. the point we just checked) on the end
	 ((< ((get-first-position remaining) 'get-weight)
	     (p 'get-weight)) (make-position-list p remaining))
					; otherwise leave the point where it is and try the next one
	 (else (make-position-list (get-first-position remaining) (helper (get-rest-positions remaining))))))

      (helper pt-list))



    ;; =====================================================
    ;;   Weight Manager
    ;; =====================================================


    (define (make-weight-manager)

      ;; contains (x . y) => weight
      (define table (make-equal-hash-table))


      (define (accum-weight x y weight)
	(let* ((key (cons x y))
	       (cur-weight (get-weight x y))
	       (new-weight (+ weight cur-weight)))

	  (hash-table/put! table key new-weight)))

      (define (get-weight x y)
	(let* ((key (cons x y))
	       (weight (hash-table/get table key 0)))

	  weight))

      (define (print-table)
	(newline)
	(display "  x |   y |  wt.")(newline)
	(display "================")(newline)

	(hash-table/for-each table 
			     (lambda (key datum)
			       (let ((x (car key))
				     (y (cdr key))
				     (weight datum))

				 (display (string-pad-left (number->string x) 3 #\space))
				 (display " | ")
				 (display (string-pad-left (number->string y) 3 #\space))
				 (display " | ")
				 (display (string-pad-left (number->string weight) 4 #\space))
				 (newline)

				 )))
	'ok)

      ;; returns a list of positions (make-position), highest weight first
      (define (get-sorted-positions)
	(define (helper remaining pos-list)
	  (if (null? remaining)
	      pos-list
	      (let* ((key (caar remaining))
		     (x (car key))
		     (y (cdr key))
		     (weight (cdar remaining)))

		(helper (cdr remaining) (make-sorted-position-list (make-position y x weight) pos-list)))))

	(helper (hash-table->alist table) the-empty-pos-list))


      (define (dispatch m . args)

	;; args: x, y, weight
	(cond ((eq? 'accum-weight m) (apply accum-weight args))
	      ;; args: x, y
	      ((eq? 'get-weight m) (apply get-weight args))
	      ((eq? 'print-table m) (print-table))
	      ((eq? 'get-sorted-positions m) (get-sorted-positions))

	      (else (error "make-weight-manager: unknown message"))))

      dispatch)


    ;; =====================================================
    ;;   Engine
    ;; =====================================================

    (define (make-engine board player)


      ;; -----------------------------------------------------
      ;;    Calculation Helpers
      ;; -----------------------------------------------------

      ;; board,player comes from make-engine
      ;; calls proc with: board, pattern, position, player
      (define (for-each-match proc pattern player)

	(define (handle-match position)

	  ;; TODO test this... make sure it is offset correctly
	  ;; if the pattern is within bounds...
	  (if (and 
	       (>= (board 'get-n-cols) (+ (position 'get-col) (pattern 'get-width)))
	       (>= (board 'get-n-rows) (+ (position 'get-row) (pattern 'get-height))))

	      ;; 5. for each potential spot
	      (proc board pattern position player))
	  'ok)

	;; find all occurences of pattern on board
	(define match-positions (pattern 'find-all-matches board player))
	
	(for-each handle-match match-positions)
	'ok)

      ;; board, player comes from make-engine
      ;; calls proc with: board, pattern, position, player
      (define (for-each-player-position proc pattern position player)
	
	(define (handle-player-position p-position)

	  (proc board pattern position p-position player))

	;; 4. find the potential spots on the pattern to play
	(define player-positions (pattern 'get-player-positions player))

	(for-each handle-player-position player-positions)

	'ok)

      ;; -----------------------------------------------------
      ;;    Calculate Planned Defense
      ;; -----------------------------------------------------


      ;; adds the weight for pattern to each empty spot in the deffense-patterns
      ;; list that is found on the board
      (define (calculate-planned-defense weight-manager)

	(define (handle-match board pattern position player)
	  (for-each-player-position handle-player-position pattern position player)

	  'ok)

	(define (handle-player-position board pattern position p-position player)
	  ;; add player position to match position
	  (let* ((abs-pos (p-position 'add position))
		 (x (abs-pos 'get-col))
		 (y (abs-pos 'get-row))
		 (pattern-weight (pattern 'get-weight)))

	    ;; finally, accumulate the weight at the coordinate we found
	    (weight-manager 'accum-weight x y pattern-weight))

	  'ok)


	(define (find-matches pattern)
	  (for-each-match handle-match pattern player)
	  'ok)


	(for-each find-matches planned-defense-patterns)


	'ok)
      

      ;; -----------------------------------------------------
      ;;    Calculate Generic Defense
      ;; -----------------------------------------------------


      ;; adds the weight for pattern to each empty spot in the deffense-patterns
      ;; list that is found on the board
      (define (calculate-defense weight-manager)

	(define opp-player (if (eq? player *PLAYER-1-SYMBOL*) 
			       *PLAYER-2-SYMBOL* 
			       *PLAYER-1-SYMBOL*))

	(define (handle-match board pattern position player)	  

					;(bkpt 'handle-match 'defense)

	  (define num-played 0)
	  (define weight 0)
	  (define position-list '())
	  (define 3x-weight (* 3 (pattern 'get-weight)))

	  (define (calc-weight! board pattern position p-position player)
	    (let* ((abs-pos (p-position 'add position))
		   (x (abs-pos 'get-col))
		   (y (abs-pos 'get-row))
		   (symbol (board 'get-position x y)))

	      (if (eq? symbol player)
		  (set! weight (+ weight (pattern 'get-weight))))

	      ;; absolutely go if there are 3 in a row
	      (if (>= weight 3x-weight)
		  (set! weight (* 100 weight)))

	      (set! position-list (cons p-position position-list)))

	    'ok)


	  (define (accum-weight!)
	    (define (helper remaining)
					;(bkpt 'accum-weight 'helper)

	      (if (null? remaining)
		  'ok
		  (let* ((p-position (car remaining))
			 (abs-pos (p-position 'add position))
			 (x (abs-pos 'get-col))
			 (y (abs-pos 'get-row)))

		    
		    ;; finally, accumulate the weight at the coordinate we found
		    (weight-manager 'accum-weight x y weight)

		    (helper (cdr remaining))))
	      'ok)


	    (helper position-list)
	    'ok)
	  
	  (for-each-player-position calc-weight! pattern position player)

	  (accum-weight!)

	  'ok)


	(define (handle-player-position board pattern position p-position player)
	  ;; add player position to match position
	  (let* ((abs-pos (p-position 'add position))
		 (x (abs-pos 'get-col))
		 (y (abs-pos 'get-row))
		 (pattern-weight (pattern 'get-weight)))

	    
	    ;; finally, accumulate the weight at the coordinate we found
	    (weight-manager 'accum-weight x y pattern-weight))

	  'ok)

	(define (find-matches pattern)
	  (for-each-match handle-match pattern opp-player)
	  'ok)


	(for-each find-matches defense-patterns)



	'ok)
      



      ;; -----------------------------------------------------
      ;;    Calculate Offense
      ;; -----------------------------------------------------


      ;; adds the weight for pattern to each empty spot in the offense-patterns list...
      ;; multiplies the weight by the number of spots that are filled with the player's 
      ;; piece so that those will take prescidence
      (define (calculate-offense weight-manager)

	(define (handle-match board pattern position player)	  

	  (define num-played 0)
	  (define weight 0)
	  (define position-list '())

	  (define (calc-weight! board pattern position p-position player)
	    (let* ((abs-pos (p-position 'add position))
		   (x (abs-pos 'get-col))
		   (y (abs-pos 'get-row))
		   (symbol (board 'get-position x y)))

	      (if (eq? symbol player)
		  (set! weight (+ weight (pattern 'get-weight))))

	      (set! position-list (cons p-position position-list)))

	    'ok)


	  (define (accum-weight!)
	    (define (helper remaining)
					;(bkpt 'accum-weight 'helper)

	      (if (null? remaining)
		  'ok
		  (let* ((p-position (car remaining))
			 (abs-pos (p-position 'add position))
			 (x (abs-pos 'get-col))
			 (y (abs-pos 'get-row)))

		    
		    ;; finally, accumulate the weight at the coordinate we found
		    (weight-manager 'accum-weight x y weight)

		    (helper (cdr remaining))))
	      'ok)


	    (helper position-list)
	    'ok)
	  
	  (for-each-player-position calc-weight! pattern position player)

	  (accum-weight!)

	  'ok)



	(define (handle-player-position board pattern position p-position)
	  ;; add player position to match position
	  (let* ((abs-pos (p-position 'add position))
		 (x (abs-pos 'get-col))
		 (y (abs-pos 'get-row))
		 (pattern-weight (pattern 'get-weight)))

	    
	    ;; finally, accumulate the weight at the coordinate we found
	    (weight-manager 'accum-weight x y pattern-weight))

	  'ok)

	(define (find-matches pattern)
	  (for-each-match handle-match pattern player)
	  'ok)


	(for-each find-matches offense-patterns)



	'ok)

      ;; -----------------------------------------------------
      ;;    Play - the main routine that is called to calculate
      ;;           the next move
      ;; -----------------------------------------------------

      (define (play)
	;; contains (x . y) => weight
	(define weight-manager (make-weight-manager))

	(calculate-defense weight-manager)
	(calculate-offense weight-manager)
	(calculate-planned-defense weight-manager)


					;(weight-manager 'print-table)

	(define (play-next-move position-list)

	  (if (null? position-list)
	      (error "need a backup plan... no positions to play.")
	      (let* ((position (get-first-position position-list))
		     (side (board 'can-move? (position 'get-col) (position 'get-row))))
		(cond ((eq? #f side) (play-next-move (get-rest-positions position-list)))
		      ((eq? 'left side) (list 0 (position 'get-row)))
		      ((eq? 'top side) (list 1 (position 'get-col)))))))

	(define next-move (play-next-move (weight-manager 'get-sorted-positions)))

	next-move)

      (define (dispatch m . args)
	(cond ((eq? 'play m) (play))
	      (else (error"make-engine: unknown message"))))

      dispatch)




    ;; =====================================================
    ;;   Test Cases
    ;; =====================================================



    ;; run tests once upon load...
    (define (run-tests)
      (define p1 (make-pattern '((o () ()) 
				 (o () ()) 
				 (o a a))))


      (define b1 (make-board '((x () () x x) 
			       (o o o o o) 
			       (o o o o o) 
			       (o o o o o))))

					; find-all-matches finds '(8 1)
      (define b2 (make-board '((() () () () ()) 
			       (() o () () ())
			       (() o () o ())
			       (() o () o ())
			       (() x () o ()))))


      (define p2 (make-pattern '((x)
				 (o)
				 (o)
				 (o))))


      (define b-canmove (make-board '((() () () x)
				      (() () () x)
				      (() x () ())
				      (x x x x))))





      (newline)


					; adding positions works
      (display (= 5 (((make-position 3 5) 'add (make-position 2 4)) 'get-row)))
      (display (= 9 (((make-position 3 5) 'add (make-position 2 4)) 'get-col)))(newline)


					; board matrix to string works
      (display (string=? "x  xxooooooooooooooo" (b1 'get-string)))(newline)

					; get regex works w/ same width as board
      (display (string=? "o  o  o.." (p1 'get-regex 3 'x)))(newline)

					; get regex works w/ less width than board
					; special attention to the lack of trailing periods
      (display (string=? "o  ..o  ..o.." (p1 'get-regex 5 'x)))(newline)


      ;; get-regex works w/ current players piece
      (display (string=? "[x\ ]....o....o....o" (p2 'get-regex 5 'x)))(newline)

					; flipping works
      (display (equal? ((p1 'get-flipped) 'get) '((() () a) (() () a) (o o o))))(newline)

					; seeing if a pattern is on a board works
					; NOTE these are always in reverse order (bottom right to top left)



      (display "can-move?")(newline)

      ;; left landing
      (display (eq? 'left (b-canmove 'can-move? 2 0)))

      ;; no landing
      (display (eq? #f (b-canmove 'can-move? 1 0)))

      ;; top landing
      (display (eq? 'top (b-canmove 'can-move? 1 1)))

      ;; neither top nor left landing
      (display (eq? #f (b-canmove 'can-move? 3 2)))

      ;; chosen space is blocked
      (display (eq? #f (b-canmove 'can-move? 1 2)))

      ;; blocked from top
      (display (eq? #f (b-canmove 'can-move? 3 0)))

      ;; blocked from left
      (display (eq? #f (b-canmove 'can-move? 0 3)))


      (newline)


      (define b1p2matches (p2 'find-all-matches b1 'x))

      (display "b1p2matches")(newline)

      (display (= 4 ((list-ref b1p2matches 0) 'get-col)))
      (display (= 3 ((list-ref b1p2matches 1) 'get-col)))
      (display (= 2 ((list-ref b1p2matches 2) 'get-col)))
      (display (= 1 ((list-ref b1p2matches 3) 'get-col)))
      (display (= 0 ((list-ref b1p2matches 4) 'get-col)))(newline)

					; patterns on multiple rows
      (define b2p2matches (p2 'find-all-matches b2 'x))
      (display "b2p2matches")(newline)
      (display (= 2 (length b2p2matches)))(newline)
 					;(3, 1)
      (display (= 3 ((list-ref b2p2matches 0) 'get-col)))
      (display (= 1 ((list-ref b2p2matches 0) 'get-row)))(newline)
 					;(1, 0)
      (display (= 1 ((list-ref b2p2matches 1) 'get-col)))
      (display (= 0 ((list-ref b2p2matches 1) 'get-row)))(newline)


      ;; this are in order top/left to bottom/right
      (define p2playerpos (p2 'get-player-positions 'x))

      (display "p2playerpos")(newline)
      (display (= 1 (length p2playerpos)))(newline)

      ;; (0,0)
      (display (= 0 ((list-ref p2playerpos 0) 'get-col)))
      (display (= 0 ((list-ref p2playerpos 0) 'get-row)))(newline)




      (display ((make-pattern '((x)
				(o)
				(o)) 5) 'get-regex 5 'x))(newline)





				(define pos1 (make-position 5 6 1))
				(define pos2 (make-position 6 5 2))
				(define pos3 (make-position 6 5 3))

				(define pos-list (make-sorted-position-list pos3 the-empty-pos-list))
				(set! pos-list (make-sorted-position-list pos1 pos-list))
				(set! pos-list (make-sorted-position-list pos2 pos-list))


				(display "make-sorted-position-list")(newline)

				(display (= 3 ((get-first-position pos-list) 'get-weight)))
				(display (= 2 ((get-first-position (get-rest-positions pos-list)) 'get-weight)))
				(display (= 1 ((get-first-position (get-rest-positions (get-rest-positions pos-list))) 'get-weight)))
				(newline)


				(define wm (make-weight-manager))

				(display "weight-manager")(newline)
				(display (= 0 (wm 'get-weight 1 1)))
				(wm 'accum-weight 1 1 2)
				(wm 'accum-weight 1 1 3)
				(display (= 5 (wm 'get-weight 1 1)))(newline)
				
				(wm 'accum-weight 5 6 10)
				(wm 'accum-weight 7 8 4)

				(wm 'print-table)

				(display "get-sorted-positions")(newline)
				(display (= 10 ((get-first-position (wm 'get-sorted-positions)) 'get-weight)))(newline)




				)

    (run-tests)





    ;; =====================================================
    ;;   Data: Patterns
    ;; =====================================================






    (define old-planned-defense-patterns
      '(
	(((x o x)) 1)

	(((x o o x)) 10)

	(((x o o o x)) 250)

	(((o x o)) 1)

	(((o o x o)) 250)

	(((o x o o)) 250)

	(((x)
	  (o)) 1)

	(((x)
	  (o)
	  (o)) 2)

	(((x)
	  (o)
	  (o)
	  (o)) 250)

	(((x a)
	  (a o)) 1)

	(((o ())
	  (a x)) 1)

	;; TODO all directions of this
	(((a ())
	  (o ())
	  (a a)) -5)

	(((x a a)
	  (a o a)
	  (a a o)) 2)


	(((o () a)
	  (a x a)
	  (a a o)) 2)

	;; TODO other diagonals
	(((x a a a)
	  (a o a a)
	  (a a o a)
	  (a a a o)) 250)

	(((o a () a)
	  (a o () a)
	  (a a x a)
	  (a a a o)) 250)

	(((o () a a)
	  (a x a a)
	  (a a o a)
	  (a a a o)) 250)

	(((x a a a)
	  (a o a a)
	  (a a o a)
	  (a a a o)) 250)

	(((o a a ())
	  (a o a ())
	  (a a o ())
	  (a a a x)) 250)

	))


    ;; avoid stupid stff
    (define planned-defense-patterns
      '(

        (((a x a)
	  (x o a)
	  (a a o)) -1000)




	))



    ;; be conservative and give defense a little more weight
    (define defense-patterns 
      '(
	(((o o o o)) 50)

	(((o)
	  (o)
	  (o)
	  (o)) 50)

	(((o a a a)
	  (a o a a)
	  (a a o a)
	  (a a a o)) 50)

	(((a a a o)
	  (a a o a)
	  (a o a a)
	  (o a a a)) 50)

	))


    (define offense-patterns 
      '(

	;; safety so we always have a move as long as one is playable
	(((x)) 1)

	(((x x x x)) 25)

	(((x)
	  (x)
	  (x)
	  (x)) 25)

	(((x a a a)
	  (a x a a)
	  (a a x a)
	  (a a a x)) 25)

	(((a a a x)
	  (a a x a)
	  (a x a a)
	  (x a a a)) 25)

	))



    ;; =============================================================
    ;;  Make patterns for current user, and rotate them CCW
    ;; =============================================================

    ;; there is no init routine, so this is done on the first run of main-procedure.
    ;; it takes defense and offense patterns and maps x / o to the correct players...
    ;; x turns into current, and o turns into other.
    (define patterns-made? #f)

    (define (make-patterns player)
      (set! patterns-made? #t)


      (define (translate-rows rows)
	(map (lambda (cols)
	       (map (lambda (cell)
		      ;; map 'x to current player,
		      ;; map 'o to other player,
		      ;; leave rest as-is
		      (cond ((eq? cell *PLAYER-1-SYMBOL*) player)
			    ((eq? cell *PLAYER-2-SYMBOL*) (if (eq? player *PLAYER-1-SYMBOL*) 
							      *PLAYER-2-SYMBOL* 
							      *PLAYER-1-SYMBOL*))
			    (else cell))
		      
		      ) cols)
	       ) rows))

      (define (translate-pattern-data pattern-data)
	(let* ((rows (translate-rows (list-ref pattern-data 0)))
	       (weight (list-ref pattern-data 1))
	       (pattern (make-pattern rows weight)))
	  pattern))


      ;; add a CCW rotation so patterns work from left side as well
      (define (add-flipped-patterns pattern-list)
	(define (helper remaining)

	  (if (null? remaining)
	      pattern-list

	      (let* ((pattern (car remaining))
		     (new-remaining (cdr remaining))
		     (flipped (pattern 'get-flipped)))

		;; put flipped pattern onto the beginning of the list
		(cons flipped (helper new-remaining)))))


	(helper pattern-list))


      ;; translate patterns for the current player (eg. they are all represented
      ;; with x as current player, but it might be o
      (set! defense-patterns (map translate-pattern-data defense-patterns))
      (set! offense-patterns (map translate-pattern-data offense-patterns))
      (set! planned-defense-patterns (map translate-pattern-data planned-defense-patterns))

      ;; add a CCW rotation so patterns work from left side as well
      (set! defense-patterns (add-flipped-patterns defense-patterns))
      (set! offense-patterns (add-flipped-patterns offense-patterns))
      (set! planned-defense-patterns (add-flipped-patterns planned-defense-patterns))


      'ok)





    ;; =====================================================
    ;;   Main Procedure
    ;; =====================================================


    ;; the main game procedure
    ;; player - symbol, either x or o
    ;; raw-board - a 2D list that represents the board...
    ;;             nil is empty, x and o are players
    ;; returns: list  [0] = 0|1, 0 = left, 1 = top
    ;;                [1] = 0-6,7 = row/column to play
    (define (main-procedure player raw-board)

      ;; since there is no init routine, do it here...
      (if (not patterns-made?)
	  (make-patterns player))
      

      (define board (make-board raw-board))
      (define engine (make-engine board player))

      (engine 'play))



    main-procedure))