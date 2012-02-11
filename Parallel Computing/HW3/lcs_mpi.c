#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "mpi.h"

#include "common.h"

#define TAG_DIM 0
#define TAG_BLOCK 1
#define TAG_BT_STATE 3
#define TAG_BT_RES 4


void lcs_length_mpi(const grid_t* grid, const int p, const int r) {
	int w = ceil((double)grid->m / (p*p));
	int h = ceil((double)grid->n / p);
	
	//printf("%i: processing %i x %i blocks\n", r, w, h);
	
	// for each block on this row (m/p)
	int x, y;
	y = r*h + 1;
	for(x = 1; x < grid->m + 1; x += w) {
		if(x + w > grid->m) {
			w = grid->m - x + 1;
		}
		
		if(y + h > grid->n) {
			h = grid->n - y + 1;
		}
		

		if( r != 0 ) {
			// recv upper block from p-1 
			int up_y = y - 1;	
			
			//printf("%i: recv upper block, y=%i, x=[%i,%i] from %i\n", r, up_y, x, x + w - 1, r - 1);

			MPI_Status status;			
			cell_t* recv_cells = grid_cell( grid, up_y, x );
			MPI_Recv(recv_cells, w*sizeof(cell_t), MPI_BYTE, r - 1, TAG_BLOCK, MPI_COMM_WORLD, &status );
		}
	
		// calculate this block
		//printf("%i: calc block (%i,%i) to (%i,%i)\n", r, x, y, x + w - 1, y + h - 1);
		lcs_length_block(grid, y, x, h, w);

		if(r != p - 1) {
			// async send this block to p+1
			//printf("%i: send lower block y=%i, x=[%i,%i] to %i\n", r, y + h - 1, x, x + w - 1, r + 1);

			cell_t* send_cells = grid_cell( grid, y + h - 1, x );
			MPI_Request* request = malloc(sizeof(MPI_Request));
			MPI_Isend(send_cells, w*sizeof(cell_t), MPI_BYTE, r + 1, TAG_BLOCK, MPI_COMM_WORLD, request);
		}
	}
	
}




void lcs_backtrack_mpi(const grid_t* grid, char* res, int p, int r) {

	int w = ceil((double)grid->m / p);
	int h = ceil((double)grid->n / p);
	// 1 row/col before start of block.
	int min_i = r*h;  
	int min_j = 0; 


	backtrack_state_t state;
	
	if(r == p - 1) {
		state.i = grid->n;
		state.j = grid->m;
		state.pos = 0;
	} else {
		MPI_Status status;
		MPI_Recv( &state, sizeof(backtrack_state_t), MPI_BYTE, r + 1, TAG_BT_STATE, MPI_COMM_WORLD, &status ); 
		//printf("%i: got backtrack state. start=(%i, %i). reslen=%i\n", r, state.i, state.j, state.pos);
		MPI_Recv( res, state.pos * sizeof(char), MPI_BYTE, r + 1, TAG_BT_RES, MPI_COMM_WORLD, &status ); 
		//printf("%i: got backtrack sofar=%s\n", r, res);
	} 
	state.res = res;
	
	//printf("%i: backtrack: start=(%i, %i), end=(%i, %i)\n", r, state.i, state.j, min_i, min_j);
	lcs_backtrack_block(grid, &state, min_i, min_j);
	
	if(r == 0) {
		strrev(state.res);
		//printf("%i: backtrack done. end=(%i, %i). reslen=%i\n", r, state.i, state.j, state.pos);
	} else {
		MPI_Send( &state, sizeof(backtrack_state_t), MPI_BYTE, r - 1, TAG_BT_STATE, MPI_COMM_WORLD ); 
		MPI_Send( state.res, state.pos * sizeof(char), MPI_BYTE, r - 1, TAG_BT_RES, MPI_COMM_WORLD ); 
	}
}


void lcs_mpi(const char* s1, const char* s2, const int maxlen, char* res) {

	int p, r;
	MPI_Comm_size( MPI_COMM_WORLD, &p );
	MPI_Comm_rank( MPI_COMM_WORLD, &r );

	grid_t grid;
	grid_init( &grid, s1, s2 );

	lcs_length_mpi( &grid, p, r );
	lcs_backtrack_mpi( &grid, res, p, r );
}


int main(int argc, char* argv[]) {

	MPI_Init(&argc, &argv);
	int r;
	MPI_Comm_rank( MPI_COMM_WORLD, &r );


	char* s1;
	char* s2;
	int m, n;

	int reslen;
	char* res;

	if( r == 0 ) {
		char* file1, * file2;
	
		if(!parse_args(argc, argv, &file1, &file2, NULL)) {
			MPI_Finalize();
			printf("Usage: %s file1.txt file2.txt\n", argv[0]);
			return -1;
		}
	
		read_string(file1, &s1, &m);
		read_string(file2, &s2, &n);
	}
	
	// broadcast info to other processes. length of
	// string before string itself so that it knows
	// how much data to expect.
	MPI_Bcast( &m, 1, MPI_INT, 0, MPI_COMM_WORLD );
	if(r != 0) {
		s1 = malloc( m * sizeof(char) );
	}
	MPI_Bcast( s1, m, MPI_CHAR, 0, MPI_COMM_WORLD );
	
	MPI_Bcast( &n, 1, MPI_INT, 0, MPI_COMM_WORLD );
	if(r != 0) {
		s2 = malloc( n * sizeof(char) );
	}
	MPI_Bcast( s2, n, MPI_CHAR, 0, MPI_COMM_WORLD );

	// the longest result can be the longer of the two strings
	reslen = max(m, n) + 1;
	res = (char*)malloc(reslen*sizeof(char));
		
	double start = get_timeofday();
	
	lcs_mpi( s1, s2, reslen, res );
	
	if(r == 0) {
		double end = get_timeofday();
		printf("Time Taken: %f sec %i %s\n", end-start, strlen(res), res);
	}
	
	MPI_Finalize();
	
	return 0;

}
