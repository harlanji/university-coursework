#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <string.h>


#include "common.h"

// NOTE: using gettimeofday to avoid dependence on OMPI. ompi_info says:
//       MPI_WTIME support: gettimeofday

double get_timeofday() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec+(tv.tv_usec/1000000.0);
}

// http://www.cas.mcmaster.ca/~kahl/SE2S03/2006/C/strrev.c

char* strrev(char * string) {
	int length = strlen(string);
	char * result = malloc(length+1);
	if( result != NULL ) {
		int i,j;                                         
		result[length] = '\0';
		for ( i = length-1, j=0;   i >= 0;   i--, j++ )  
			result[j] = string[i];
	}
	strcpy(string, result);
	free(result);
	
	return string;
}

int max(int a, int b) {
	return a > b ? a : b;
}

int read_string(char* filename, char** s, int* len) {
	FILE* fd = fopen( filename, "r" );
	if( fd == NULL ) {
		fprintf( stderr, "Could not open file %s for reading\n", filename );
		return -1;
	}

	fseek(fd, 0, SEEK_END);
	*len = ftell(fd);
	fseek(fd, 0, SEEK_SET);

	*s = (char*)malloc( *len * sizeof(char) );

	fread(*s, *len, 1, fd);

	fclose( fd );
	
	return 0;
}

int parse_args( int argc, char* argv[], char** file1, char** file2, int* p ) {
	if( argc < 3 ) {
		return 0;
	}
	
	*file1 = argv[1];
	*file2 = argv[2];
	
	if( p != NULL) {
		if(argc >= 4) {
			*p = atoi( argv[3] );
			if( !*p ) { 
				return 0; 
			}
		} else {
			*p = 1;
		}
	}
	
	return 1;
}


void grid_init(grid_t* grid, const char* s1, const char* s2) {
	grid->s1 = s1;
	grid->s2 = s2;
	grid->m = strlen(s1);
	grid->n = strlen(s2);
	
	size_t size = (grid->m + 1) * (grid->n + 1) * sizeof(cell_t);
	grid->cells = (cell_t*)malloc( size );
	memset( grid->cells, 0, size );
}


cell_t* grid_cell(const grid_t* grid, const int i, const int j) {
	return &(grid->cells[ (grid->m + 1)*i + j ]);
}


cell_t* grid_alloc_block( const int h, const int w ) {
	cell_t* block = (cell_t*)malloc( h * w * sizeof(cell_t) );
	
	return block;
}

cell_t* grid_serialize_block( const grid_t* grid, const int y, const int x, const int h, const int w ) {
	cell_t* serialized = grid_alloc_block(h, w);

	int i;
	// copy each w items from a row at a time.
	for( i = 0; i < h; i++ ) {
		cell_t* cell = grid_cell( grid, y + i, x );	
		memcpy(&serialized[w*i], cell, w*sizeof(cell_t));
	}
	
	return serialized;
}

void grid_deserialize_block( const grid_t* grid, const cell_t* serialized, const int y, const int x, const int h, const int w ) {

	int i;
	// copy each w items from a row at a time.
	for( i = 0; i < h; i++ ) {
		cell_t* cell = grid_cell( grid, y + i, x );	
		memcpy(cell, &serialized[w*i], w*sizeof(cell_t));
	}
}



/*

Computes a block of the LCS length matrix. Before the call, 
all cells immediately above and to the left of the block of interest 
must be calculated. that is, the cells above as ([x, x+w], y-1) and
to the left as ([y, y+h], x-1). These are the cells represented by #.

                  x       x+w
  +-------+-------+-------+-------+
  | * * * | * * * | * * * |       |
  | * * * | * * # | # # # |       |
  +-------+-------+-------+-------+ y
  | * * * | * * # | 0 0 0 |       |
  | * * * | * * # | 0 0 0 |       |
  +-------+-------+-------+-------+ y+h
  |       |       |       |       |
  |       |       |       |       |
  +-------+-------+-------+-------+
  
This structure allows for usage by either message passing or shared memory based
formulations.
  
*/
void lcs_length_block( const grid_t* grid, const int y, const int x, const int h, const int w  ) {
	int i, j;
	for(i = y; i < y + h; i++) {
		for(j = x; j < x + w; j++) {
			cell_t* cell = grid_cell( grid, i, j );
			//printf("(%i,%i)\n", i, j);
			
			if(grid->s1[i-1] == grid->s2[j-1]) {
				cell->len = grid_cell( grid, i-1, j-1 )->len + 1;
				cell->dir = upleft;
			} else {
				cell_t* cell_up = grid_cell( grid, i-1, j );
				cell_t* cell_left = grid_cell( grid, i, j-1 );
				
				if(cell_up->len >= cell_left->len) {
					cell->len = cell_up->len;
					cell->dir = up;
				} else {
					cell->len = cell_left->len;
					cell->dir = left;
				}
			}
		}
	}
}


void lcs_backtrack_block(const grid_t* grid, backtrack_state_t* state, int min_i, int min_j) {

	while(state->i > min_i && state->j > min_j) {
		cell_t* cell = grid_cell(grid, state->i, state->j);
		
		if( cell->dir == upleft ) {
			//printf(":%c @ %i/%i\n", grid->s1[i-1], i, j);
			state->res[state->pos++] = grid->s1[state->i-1];
			state->i--; state->j--;
		} else if( cell->dir == up ) {
			state->i--;
		} else if( cell->dir == left) {
			state->j--;
		} else {
			printf("\n---WTF BAD CELL!--\n");
		}
	}
	state->res[state->pos] = 0;
	

}
