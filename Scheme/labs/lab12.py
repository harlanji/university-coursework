## CSCI 1901 - Fall 2008
## Lab 12 Template
##
## Name(s): 
##          
## Section:  
##

## Utility Procedures ##
def do_tests(case):
    exec(eval("test_case_" + str(case)))
    print "Test Completed"

## End Utility Procedures ##



## Step 2 - Add It Up
## ---------------------------------------------------------

## Example Code:
def sum(lst):
  if lst == []:
    return 0
  else:
    return lst[0] + sum(lst[1:])

def is_even(n):
    return n % 2 == 0

def sum_even(lst):
    if lst == []:
        return 0
    elif is_even(lst[0]):
        return lst[0] + sum_even(lst[1:])
    else:
        return sum_even(lst[1:])
    

## Step 2 Test Code ##
test_case_2 = """
print \"Step 2 Test Cases\"
print sum_even([1, 2, 2])     # 4
print sum_even([1, 3, 5])     # 0
print sum_even([10, 20, 30])  # 60
"""

## Uncomment do_tests to run.
do_tests(2)



## Step 3 - List Building
## ---------------------------------------------------------

## Example Code:
def list_even(start, end):
  if start > end:
    return []
  elif start % 2 == 0:
    return [start] + list_even(start + 1, end)
  else:
    return list_even(start + 1, end)

def list_div_2_3(start, end):
    if start > end:
        return []
    elif start % 2 == 0 or start % 3 == 0:
        return [start] + list_div_2_3(start + 1, end)
    else:
        return list_div_2_3(start + 1, end)
    

## Step 3 Test Code ##
test_case_3 = """
print \"Step 3 Test Cases\"
print list_div_2_3(1, 4)   # [2, 3, 4]
print list_div_2_3(5, 6)   # [6]
print list_div_2_3(6, 7)   # [6]
print list_div_2_3(1, 1)   # []
"""

## Uncomment do_tests to run.
do_tests(3)



## Step 4 - More List Building
## -------------------------------------------------------------------
 
def div_by_element(x, lst):
    if lst == []:
        return False
    elif x % lst[0] == 0:
        return True
    else:
        return div_by_element(x, lst[1:])
        


def list_div_by_el(list1, list2):
    if list1 == []:
        return []
    elif div_by_element(list1[0], list2):
        return [list1[0]] + list_div_by_el(list1[1:], list2)
    else:
        return list_div_by_el(list1[1:], list2)
    


## Step 4 Test Code ##
test_case_4 = """
print \"Step 4 Test Cases\"
l = [1, 2, 3, 4, 5, 6, 7, 8, 9]
print div_by_element(8, [3, 5, 7])   # False
print div_by_element(8, [2, 5, 7])   # True
print div_by_element(8, [3, 5, 4])   # True
print list_div_by_el(l, [2, 3])      # [2, 3, 4, 6, 8, 9]
print list_div_by_el(l, [4, 8])      # [4, 8]
print list_div_by_el(l, [20])        # []
print list_div_by_el(l, [])          # []
"""

## Uncomment do_tests to run.
do_tests(4)



## Step 5 - Running Sum
## -----------------------------------------------------------------------------

def running_sum(lst):
    def helper(partial, working):
        if working == []:
            return []
        else:
            new_partial = partial + working[0]
            return [new_partial] + helper(new_partial, working[1:])

    return helper(0, lst)



## Step 5 Test Code ##
test_case_5 = """
print \"Step 5 Test Cases\"
print running_sum([1, 1, 1, 1])          # [1, 2, 3, 4]
print running_sum([2, -2, 2, -2])        # [2, 0, 2, 0]
print running_sum([9, 1, 5, 5])          # [9, 10, 15, 20]
print running_sum([100, -50, -25, -25])  # [100, 50, 25, 0]
"""

## Uncomment do_tests to run.
do_tests(5)

