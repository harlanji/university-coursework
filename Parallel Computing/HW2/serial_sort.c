#include "serial_sort.h"

#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>


void merge(const int* a, const int* b, const unsigned long n, int* out) {
	unsigned long cura=0, curb=0, curout=0;

	while( cura < n && curb < n ) {
		if(  a[ cura ] < b[ curb ] ) {
			out[ curout ] = a[ cura ];
			cura++; 
		} else {
			out[ curout ] = b[ curb ];
			curb++;
		}
		
		curout++;
	}
	
	while( curb < n ) {
		out[ curout ] = b[ curb ];
		curb++; curout++;
	} 
		
	while( cura < n ) {
		out[ curout ] = a[ cura ];
		cura++; curout++;
	}
}


// NOTE: using gettimeofday to avoid dependence on OMPI. ompi_info says:
//       MPI_WTIME support: gettimeofday
double get_timeofday() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec+(tv.tv_usec/1000000.0);
}

int read_data(char* filename, int** input_values, unsigned long* input_len) {
	FILE* fd = fopen( filename, "r" );
	if( fd == NULL ) {
		fprintf( stderr, "Could not open file %s for reading\n", filename );

		return -1;
	}
	
	char input_line[16];
	
	fgets(input_line, sizeof(input_line), fd);
	*input_len = atol(input_line);
	
	log(LOG_DEBUG, "reading file of size %u\n", *input_len);
	
	*input_values = (int*)malloc( (*input_len) * sizeof(int) );
	
	unsigned long i = 0;
	for( i = 0; i < *input_len; i++ ) {
		fscanf(fd, "%i", &(*input_values)[i]);
		
		log(LOG_DEBUG, "input_values[%u] = %i\n", i, (*input_values)[i] );
	}
	
	
	fclose( fd );
	
	return 0;
}




// -----------------------------------------------------------------------------
// mergesort impl from:
// http://www.cprogramming.com/tutorial/computersciencetheory/merge.html
// -----------------------------------------------------------------------------


/* Helper function for finding the min of two numbers */
unsigned long min(unsigned long x, unsigned long y)
{
    if(x > y)
    {
        return y;
    }
    else
    {
        return x;
    }
}



/* left is the index of the leftmost element of the subarray; right is one
 * past the index of the rightmost element */
void merge_helper(int *input, unsigned long left, unsigned long right, int *scratch)
{
    /* base case: one element */
    if(right == left + 1)
    {
        return;
    }
    else
    {
        unsigned long i = 0;
        unsigned long length = right - left;
        unsigned long midpoint_distance = length/2;
        /* l and r are to the positions in the left and right subarrays */
        unsigned long l = left, r = left + midpoint_distance;

        /* sort each subarray */
        merge_helper(input, left, left + midpoint_distance, scratch);
        merge_helper(input, left + midpoint_distance, right, scratch);

        /* merge the arrays together using scratch for temporary storage */ 
        for(i = 0; i < length; i++)
        {
            /* Check to see if any elements remain in the left array; if so,
             * we check if there are any elements left in the right array; if
             * so, we compare them.  Otherwise, we know that the merge must
             * use take the element from the left array */
            if(l < left + midpoint_distance && 
                    (r == right || min(input[l], input[r]) == input[l]))
            {
                scratch[i] = input[l];
                l++;
            }
            else
            {
                scratch[i] = input[r];
                r++;
            }
        }
        /* Copy the sorted subarray back to the input */
        for(i = left; i < right; i++)
        {
            input[i] = scratch[i - left];
        }
    }
}

/* mergesort returns true on success.  Note that in C++, you could also
 * replace malloc with new and if memory allocation fails, an exception will
 * be thrown.  If we don't allocate a scratch array here, what happens? 
 *
 * Elements are sorted in reverse order -- greatest to least */

int mergesort(int *input, unsigned long size)
{
    int *scratch = (int *)malloc(size * sizeof(int));
    if(scratch != NULL)
    {
        merge_helper(input, 0, size, scratch);
        free(scratch);
        return 1;
    }
    else
    {
        return 0;
    }
}


// -----------------------------------------------------------------------------
