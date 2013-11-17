## ASSIGNMENT: Homework4
## NAME: Harlan Iverson
## X500: ivers300
##   ID: 3476594
## SECT: 2
##
## ITLabs Machine Tested On: 

## Utility Procedures ##
def do_tests(case):
    print "Problem " + str(case) + " Test Cases"
    exec(eval("test_case_" + str(case)))
    print "Test Completed"

## End Utility Procedures ##


##=================================================##
##  Problem 1 To Be Done in Scheme -- See Writeup  ##
##=================================================##


#### ===============
####    Problem 2
#### ===============

def member(x, lst):
    retlst = []

    for val in lst:
        if val == x or len(retlst) > 0:
            retlst.append(val)

    if len(retlst) == 0:
        return False
    else:
        return retlst
            


## Test Code ##
test_case_2 = """
print member(1,[])                       # False
print member(2,[0])                      # False
print member(1,[-2, -1, 1, 2])           # [1,2]
print member(5,[3, 4, 5, 6, 10])         # [5,6,10]
print member(3,[1, -100, 200, 1, 3])     # [3]
print member(3,[1-3, 4-1, 49-23, 100+2]) # [3, 26, 102]
"""

## Uncomment do_tests to run test code.
do_tests(2)



#### ===============
####    Problem 3
#### ===============

## Builds a new list made of the larger of the first items of lst1 and lst2, the
##   larger of the second items of lst1 and lst2, etc.  If one list is longer
##   than the other, add the remaining values of the larger list once
##   the shorter list has run out of elements.   See test cases for examples.
def super_list(lst1, lst2):
    maxlen = max( len(lst1), len(lst2) )

    retlst = []

    for i in range( 0, maxlen ):
        if len(lst1) <= i:
            #print "a"
            retlst.append( lst2[i] )
        elif len(lst2) <= i:
            #print "b"
            retlst.append( lst1[i] )
        else:
            ###print "c"
            retlst.append( max( lst1[i], lst2[i] ) )

    return retlst
        
    



## Test Code ##
test_case_3 = """
print super_list([],[])                      # []
print super_list([1,2,3],[2,1,3])            # [2,2,3] 
print super_list([9,3,5,1,5],[2,3,1,8,3])    # [9,3,4,8,5] 
print super_list([1,2,3,4],[])               # [1,2,3,4] 
print super_list([],[1,2,3,4])               # [1,2,3,4] 
print super_list([4],[1,2,3,4])              # [4,2,3,4] 
print super_list([1,2,3,4],[4])              # [4,2,3,4] 
"""

## Uncomment do_tests to run test code.
do_tests(3)




#### ===============
####    Problem 4
#### ===============

## Takes in a list of lists and builds a new list as in Problem 3, but can use
##   any number of lists rather than requiring two.
def ultra_list(lst):

    ## determine the max length
    maxlen = 0
    for i in range( 0, len(lst) ):
        maxlen = max( maxlen, len(lst[i]) )

    retlst = []
    ## the column of the given lst
    for colnum in range( 0, maxlen ):
        colmax = 0

        # the row of the given lst (in column)
        for rownum in range( 0, len(lst) ):
            if colnum < len(lst[rownum]):
                colmax = max( colmax, lst[rownum][colnum] )

        retlst.append( colmax )

    return retlst
            
    

    
        



## Test Code ##
test_case_4 = """
print ultra_list([[1,2,4,5],       # [7,6,4,8]
                  [2,6,1,8],
                  [3,4,2,7],
                  [7,2,3,1]]) 
print ultra_list([[1,2,4,5],       # [7,4,4,5]
                  [3,4,2],
                  [7,2]]) 
print ultra_list([[1,2,4,5],       # [7,6,4,8,5,1]
                  [2,6,1,8,5,1],
                  [3,4,2],
                  [7,2,3,1]]) 
print ultra_list([[1,2,4,5]])     # [1,2,4,5] 
print ultra_list([[]])            # [] 
print ultra_list([])              # [] 
"""

## Uncomment do_tests to run test code.
do_tests(4)

