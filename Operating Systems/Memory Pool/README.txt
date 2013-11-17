/*CSci4061 S2010 Assignment 3
*section: 5
*login: marsh413
*date: 03/29/10
*names: Philip Babcock, Harlan Iverson, Ben Marshall
*id:    3334517         3476594         3567208*/

TO COMPILE:
From the command line, type "make" (without quotes) to create the executables.
To test malloc, type "./main_malloc".
To test our memory manager, type "./main_mm".
To test malloc and our memory manager at the same time, type "./timer".
For main_malloc, main_mm and timer, an integer argument x can be supplied (e.g.
"./timer 8").  This will test the function x number of times.  It is recommended
to supply an argument greater than or equal to 
To test the packet function, type "./packet".
To test the extra credit packet function, type "./packet_extra".

This program is our own method of memory management that is faster than
malloc/free in that the disk is not accessed every time we allocate a chunk of
memory.  Instead, we have a local pool of memory that we work with.
Our memory manager has four main functions: mm_init, mm_put, mm_get and
mm_release.

mm_init calls malloc to create a memory pool.  This pool consists
of contiguous "chunks" of memory of size (in bytes) specified by the user.
The total size of the memory pool is this chunk size multiplied by how many
chucks are in the pool (which is also specified by the user).  The pool itself
is a struct containing a char* array of length equivalent to the total size of
the pool.

mm_get is analogous to malloc, in that it grabs the next available chunk in the
pool and marks it as allocated.  We keep track of which chunks are allocated
through a separate array in the struct of length equivalent to the number of
chunks.  Each index in this array corresponds to the starting index of each
chunk in the block array.  If a chunk is free, the value in the allocated array
at that index is 0.  If it is allocated, the value is 1.

mm_put is analogous to free, in that it marks the specified chunk in the pool
as available to use.  The memory contained in the chunk is not freed, but it
is able to be written over.

mm_release is the opposite of init, in that it de-allocates the entire memory
pool by calling free().


