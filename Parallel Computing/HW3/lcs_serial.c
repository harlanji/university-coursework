#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "common.h"

void lcs_backtrack_serial(const grid_t* grid, int i, int j, const int maxlen, char* res) {

	int pos = 0;
	while(i > 0 && j > 0) {
		cell_t* cell = grid_cell(grid, i, j);
		
		if( cell->dir == upleft ) {
			//printf(":%c @ %i/%i\n", grid->s1[i-1], i, j);
			res[pos++] = grid->s1[i-1];
			i--; j--;
		} else if( cell->dir == up ) {
			i--;
		} else if( cell->dir == left) {
			j--;
		} else {
			printf("\n---WTF BAD CELL!--\n");
		}
	}
	res[pos] = 0;
	
	strrev(res);
}


void lcs_length_serial(const grid_t* grid) {
	int i, j;
	for(i = 1; i <= grid->n; i++) {
		for(j = 1; j <= grid->m; j++) {
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


void lcs_serial(const char* s1, const char* s2, const int maxlen, char* res) {
	grid_t grid;
	grid_init( &grid, s1, s2 );

	lcs_length_serial( &grid );
	lcs_backtrack_serial(&grid, grid.n, grid.m, maxlen, res);
}



int main(int argc, char* argv[]) {
	char* s1;
	char* s2;
	int m, n;
	
	int reslen;
	char* res;

	read_string("large_test1.txt", &s1, &m);
	read_string("large_test2.txt", &s2, &n);

	reslen = max(m, n) + 1;
	res = (char*)malloc(reslen*sizeof(char));

	lcs_serial( s1, s2, reslen, res );

	printf( "%s\n", res );

	return 0;

}
