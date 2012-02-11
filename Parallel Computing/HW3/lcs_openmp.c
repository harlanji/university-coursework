#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <omp.h>

#include "queue.h"
#include "common.h"

void lcs_length_openmp(const grid_t* grid, prodcon_queue_t* q, const int p) {
	

	int r = omp_get_thread_num();
	int w = ceil((double)grid->m / (p*p));
	int h = ceil((double)grid->n / p);
	int y = r*h + 1;
	
	prodcon_queue_init( &q[r], ceil((double)grid->m /w) );
	
	#pragma omp barrier
	
	int next = 0;
	while( next <= grid->m ) {
		
		if(r == 0) {
			next = (next == 0 ? 1 : next + w);
		} else {
			next = queue_consume( &q[r] );
		}
	
		
		//printf("%i: next=%i\n", r, next);
	
		if( next <= grid->m) {
			int x = next;
			
			if(x + w > grid->m) {
				w = grid->m - x + 1;
			}
	
			if(y + h > grid->n) {
				h = grid->n - y + 1;
			}


			// calculate this block
			//printf("%i: calc block y=[%i,%i], x=[%i,%i]\n", r, y, y + h - 1, x, x + w - 1);
			lcs_length_block(grid, y, x, h, w);
		}

		if(r != p - 1) {
			queue_produce( &q[r+1], next );
		}
	}
	
	prodcon_queue_destroy( &q[r] );
	
}



void lcs_backtrack_openmp(const grid_t* grid, prodcon_queue_t* q, const int p, char* res) {

	int r = omp_get_thread_num();
	int h = ceil((double)grid->n / p);
	int y = r*h + 1;
	
	if(y + h > grid->n) {
		h = grid->n - y + 1;
	}

	prodcon_queue_init( &q[r], 2 );
	
	#pragma omp barrier
	
	backtrack_state_t* state;
	if(r == p - 1) {
		state = malloc( sizeof(backtrack_state_t) );
		state->i = grid->n;
		state->j = grid->m;
		state->pos = 0;
		state->res = res;
	} else {
		state = queue_consume( &q[r] );
	}
	
	int min_i = r*h;  
	int min_j = 0; 

	lcs_backtrack_block(grid, state, min_i, min_j);

	if( r != 0 ) {
		queue_produce( &q[r-1], state );
	} else {
		strrev(state->res);
		free( state );
	}
	
	prodcon_queue_destroy( &q[r] );

}



void lcs_openmp(const char* s1, const char* s2, int p, const int maxlen, char* res) {

	grid_t grid;
	grid_init( &grid, s1, s2 );
	prodcon_queue_t q[p];

	#pragma omp parallel num_threads(p) default(none) shared(grid, q, p, res)
	{
		lcs_length_openmp( &grid, q, p );
		lcs_backtrack_openmp( &grid, q, p, res );
	}
}


int main(int argc, char* argv[]) {


	char* s1;
	char* s2;
	int m, n;

	int reslen;
	char* res;
	
	int p;

	{
		char* file1, * file2;
	
		if(!parse_args(argc, argv, &file1, &file2, &p)) {
			printf("Usage: %s file1.txt file2.txt\n", argv[0]);
			return -1;
		}
	
		read_string(file1, &s1, &m);
		read_string(file2, &s2, &n);
	}
	

	reslen = max(m, n) + 1;
	res = (char*)malloc(reslen*sizeof(char));
		
	double start = get_timeofday();
	
	lcs_openmp( s1, s2, p, reslen, res );

	double end = get_timeofday();
	printf("Time Taken: %f sec %i %s\n", end-start, strlen(res), res);

	
	
	return 0;

}
