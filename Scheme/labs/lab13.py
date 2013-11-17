## CSCI 1901 - Fall 2008
## Lab 13 Template

## Student Information:
## ------------------------------
## Name:  
## Name:  
## Sect:  


## Utility Procedures ##
def do_tests(case):
    exec(eval("test_case_" + str(case)))
    print "Test Completed"

def read_int(prompt, min_value, max_value):
    # Returns a user-provided integer.
    # Repeats prompt until valid data is provided.
    # read_int("Enter Selection", 0, 2) displays:
    #   Enter Selection [0-2]: _
    if min_value > max_value: raise ValueError, "read_int: min_value cannot be greater than max_value"
    while True:
        try:
            val = input(prompt + " [" + str(min_value) + "-" + str(max_value) + "]: ")
            if val >= min_value and val <= max_value: return val
        except:
            True # Display it again due to invalid input.

## End Utility Procedures ##



## Step 1 - all_have_value
## ---------------------------------------------------------
##   Return True if all elements have a value other than '-'.
##   Return False if the list is empty, or any element is '-'.
##
##   You may assume the list is length 3, but you must also
##   handle the case where it is empty (null).
##
## all_have_value(['x','o','x'])  => True
## all_have_value(['x','x','x'])  => True
## all_have_value([3, 9, 2])      => True
## all_have_value(['x','o','-'])  => False
## all_have_value(['-','x','-'])  => False
## all_have_value([])             => False

def all_have_value(lst):

    if len(lst) == 0: return False
    
    has_value = True

    for x in lst:
        has_value = has_value and x != '-'


    return has_value
              
        


## Step 1 Test Code ##
test_case_1 = """
print \"Step 1 Test Cases\"
print all_have_value(['x','o','x'])
print all_have_value(['x','x','x'])
print all_have_value([3, 9, 2])
print all_have_value(['x','o','-'])
print all_have_value(['-','x','-'])
print all_have_value([])"""

# Uncomment the following line to run test cases.
do_tests(1)



## Step 2 - all_equal
## ---------------------------------------------------------
##   Return True if all elements have values (not '-') and are equal.
##   Return False if the list is empty, or any element is '-'.
##
##   You may assume the list is length 3, but you must also
##   handle the case where it is empty (null).
##
## all_equal(['x', 'x', 'x']) => True
## all_equal(['o', 'o', 'o']) => True
## all_equal([5, 5, 5])       => True
## all_equal(['x', 'o', 'o']) => False
## all_equal(['-', '-', '-']) => False
## all_equal([])              => False

def all_equal(lst):
    if len(lst) == 0: return False

    prev_value = None

    for x in lst:
        ##print "%s %s" % (x, prev_value)
        if x != prev_value and prev_value != None:
            return False
        elif x == '-':
            return False
        else:
            prev_value = x

    return True
            

 
## Step 2 Test Code ##
test_case_2 = """
print \"Step 2 Test Cases\"
print all_equal(['x', 'x', 'x'])
print all_equal(['o', 'o', 'o'])
print all_equal([5, 5, 5])
print all_equal(['x', 'o', 'o'])
print all_equal(['-', '-', '-'])
print all_equal([])"""

# Uncomment the following line to run test cases.
do_tests(2)



## Provided Procedures - select_col, select_row
## -------------------------------------------------------------------
## select_row returns the row with index i in a 2D list.
## select_col returns the column with index i in a 2D list.
##
## Notes:
##      Indexes start at 0.  0 is the first row, 1 is the second, etc.
##      A 3-row by 2-column box has rows 0-2 and columns 0-1.
##      The item in the third row (row 2) and second column (column 1)
##          is referenced using lst[2][1].
##      Assumes i is a valid index for the given list.
##
## Usage:
##   l = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
##   select_row(l, 0)  => [1, 2, 3]
##   select_row(l, 2)  => [7, 8, 9]
##   select_col(l, 0)  => [1, 4, 7]
##   select_col(l, 2)  => [3, 6, 9]
##   select_col([[1,2],[3,4],[5,6],[7,8]], 1)  => [2, 4, 6, 8] 

def select_row(lst, i):
    return lst[i]

def select_col(lst, i):
    return [lst[idx][i] for idx in range(len(lst))]

def num_rows(lst):
    return len(lst)

def num_cols(lst):
    return len(lst[0])


# If the above is confusing, here are some other examples:
# def select_col(lst, i):
#     new_lst = []
#     for row in lst:
#         new_lst = new_lst + row[i]
#     return new_lst
#
# In Scheme:
# (define (select_col lst i)
#   (map (lambda (row) (list-ref i row)) lst))



## Provided Procedures - select_main_diag, select_counter_diag
## ------------------------------------------------------------
## See lab writeup for detailed information on these procedures.

def select_main_diag(array) :
    return [array[i][i] for i in range(len(array))]

def select_counter_diag(array) : 
    return [array[len(array)-i-1][i] for i in range(len(array))]


## Step 3 - Find The Winner
## -----------------------------------------------------------------------------
## Check each column, row, and diagonal to see if there has been a winner.
##   Return 'x' or 'o' if there is a winner.
##   Return "Draw" if there is no winner and the board is full.
##   Return False if there is no winner and it is still possible to make a move.
##
## You may assume the board is 3x3.
## Use the procedures above to simplify this problem.

def winner(board):

    for row_n in range(0, num_rows(board)):
        row = select_row(board, row_n)

        if( all_equal( row ) ):
            return row[0]
        
        
    for col_n in range(0, num_cols(board)):
        col = select_col(board, col_n)

        if all_equal(col):
            return col[0]

    main_diag = select_main_diag(board)

    if all_equal(main_diag):
        return main_diag[0]

        
    counter_diag = select_counter_diag(board)

    if all_equal(counter_diag):
        return counter_diag[0]


    all_full = True
    for row_n in range(0, num_rows(board)):
        for col_n in range(0, num_cols(board)):
            if board[row_n][col_n] == '-':
                ## is there a way to break 2 levels?
                all_full = False

    if all_full:
        return "Draw"


    return False
    



## Step 3 Test Code ##
test_case_3 = """
print \"Step 5 Test Cases\"
print winner([['-','-','-'], ['-','-','-'], ['-','-','-']])
print winner([['x','x','x'], ['-','-','-'], ['-','-','-']])
print winner([['o', '-','-'], ['-', 'o','-'], ['-','-','o']])
print winner([['-','-','x'], ['-','-','x'], ['-','-', 'x']])
print winner([['x','o','x'], ['x','o','o'], ['o','x','x']])
print winner([['x','o','x'], ['x','o','o'], ['o','-','x']])"""

# Uncomment the following line to run test cases.
do_tests(3)



## Provided Procedure - display_board
## --------------------------------------------------------------------------
## Displays the tic-tac-toe board. For example:
##
##    x  |  o  |  -  
##  -----+-----+-----
##    o  |  x  |  -  
##  -----+-----+-----
##    -  |  o  |  x  
##

def display_board(board):
    def display_row(row) : 
	print " " + row[0] + " | " + row[1] + " | " + row[2] 
    display_row(board[0])
    for i in range(1,3) :
        print "---+---+---"
        display_row(board[i])				



## Step 4 - play_game
## ---------------------------------------------------------------
## This procedure ties all of the above procedures together to
##   let a user play the game.  Most of the structure is provided,
##   as is the loop to get the user input.
##
## You need to write the code to check if the selected position
##   is available, make the changes to the board, and switch
##   between Player 1 and Player 2.

def play_game():
    # Create Board
    new_board = [['-', '-', '-'], ['-', '-', '-'], ['-', '-', '-']]

    # Display Header
    print "-~ Tic-Tac-Toe ~-"

    # Initialize Variables
    current_player = 1  # Start with Player 1 (x)
    current_row = -1    # Temporary Values for Row/Column
    current_col = -1

    # Start Main Loop
    while winner(new_board) == False:
        display_board(new_board)

        # Get Input From User
        print "Player " + str(current_player) + "'s Turn: "
        current_row = read_int("Select Row", 0, 2)
        current_col = read_int("Select Col", 0, 2)

        # Check if Position is Empty (Empty Positions Contain '-')
        #   If it is, mark it for current_player and switch player.
        #   If already taken, display warning and let current player try again.

        # Notes:
        #   current_player is either 1 or 2 (not 'x' or 'o').
        #     If current_player == 1, then you will place a 'x' on the board.
        #     If current_player == 2, then you will place a 'o' on the board.
        #     Then switch the value of current_player.
        #
        #   If the position selected was already taken, just print a message
        #     notifying the player of an Invalid Selection.
        #   No other action is required because the while loop will start
        #     again with the same current_player value and the same board.
        #     This allows the player to try again.

        def current_piece():
            if current_player == 1: return 'x'
            else: return 'o'

        def next_player():
            if current_player == 1: return 2
            else: return 1

        if new_board[current_row][current_col] == '-':
            new_board[current_row][current_col] = current_piece()
            current_player = next_player()
        else:
            print "Position is already taken, try again."



    # Display Final Result of Game
    display_board(new_board)

    if winner(new_board) == 'x':          print "Player 1 has won!"
    if winner(new_board) == 'o':          print "Player 2 has won!"
    if winner(new_board) == "Draw":       print "Game has resulted in a draw."

# To test your code, uncomment the following line.
play_game()


