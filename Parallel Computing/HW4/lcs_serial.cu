__global__ void vecAdd(float* A, float* B, float* C) {
	int i = threadIdx.x;
	A[i] = 0;
	B[i] = i;
	C[i] = A[i] + B[i];
}

#include <stdio.h>
#include <math.h>
#include <sys/time.h>

#define SIZE 10


void map_on( int x, int y, int* mx, int* my ) {
		*mx = x;
		*my =  *mx + y - 1;
}

void map_off( int mx, int my, int* x, int* y ) {
		*x = mx;
		*y = my - mx + 1;
}





char* strrev(char * string) {
	int length = strlen(string);
	char * result = (char*)malloc(length+1);
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

double get_timeofday() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec+(tv.tv_usec/1000000.0);
}



int parse_args( int argc, char* argv[], char** file1, char** file2, int* maxt, int* maxb ) {
	if( argc < 3 ) {
		return 0;
	}
	
	*file1 = argv[1];
	*file2 = argv[2];
	
	if( maxt != NULL ) {
		if(argc >= 4) {
			*maxt = atoi( argv[3] );
			if( !*maxt ) { 
				return 0; 
			}
		} else {
			*maxt = 32;
		}
	}
	
	if( maxb != NULL ) {
		if(argc >= 5) {
			*maxb = atoi( argv[3] );
			if( !*maxb ) { 
				return 0; 
			}
		} else {
			*maxb = 16;
		}
	}
	
	
	return 1;
}


// grid API

typedef enum { none = 0, up, left, upleft } dir_t;

typedef struct cell_t {
	int len;
	dir_t dir;
} cell_t;

typedef struct grid_t {
	int w;
	int h;
	int d;
	const char* sx;
	const char* sy;
	
	cell_t* cells;
} grid_t;


void grid_init(grid_t* grid, const char* s1, const int m, const char* s2, const int n) {
	grid->sx = s1;
	grid->sy = s2;
	grid->w = m;
	grid->h = n;
	grid->d = grid->w + grid->h - 1;
	
	int mh = grid->d, mw = grid->w;


	size_t size = (mh + 1) * (mw + 1) * sizeof(cell_t);
	grid->cells = (cell_t*)malloc( size );
	
	memset( grid->cells, 0, size );
}


cell_t* grid_cell(const grid_t* grid, const int x, const int y) {

	int mx, my;
	map_on( x, y, &mx, &my );

	return &(grid->cells[ (grid->w + 1)*x + y ]);
}

void lcs_length_cuda( const grid_t* grid, int maxt, int maxb ) {

	int d;
	for(d = 1; d <= grid->d; d++) {
		int x, sx, fx;
		sx = max(d - grid->h + 1, 1);
		fx = min(d, grid->w);
		
		for(x = sx; x <= fx; x++) {
			int i, j;
			map_off( x, d, &i, &j );
		
			//printf( "process [%i, %i] => [%i, %i]\n", d, x, j, i );


			cell_t* cell = grid_cell( grid, i, j );
			//printf("(%i,%i)\n", i, j);

			if(grid->sx[i-1] == grid->sy[j-1]) {
				cell->len = grid_cell( grid, i-1, j-1 )->len + 1;
				cell->dir = upleft;
				
				//printf("ul: [%i, %i] = %c\n", j, i, grid->sx[i-1]);
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



void lcs_backtrack_cuda(const grid_t* grid, int i, int j, const int maxlen, char* res, int maxt, int maxb) {

	int pos = 0;
	while(i > 0 && j > 0) {
		cell_t* cell = grid_cell(grid, i, j);
		
		if( cell->dir == upleft ) {
			//printf(":%c @ %i/%i\n", grid->s1[i-1], i, j);
			res[pos++] = grid->sx[i-1];
			i--; j--;
		} else if( cell->dir == up ) {
			i--;
		} else if( cell->dir == left) {
			j--;
		} else {
			//printf("\n---WTF BAD CELL!--\n");
		}
	}
	res[pos] = 0;
	
	strrev(res);
}



void lcs_cuda(const char* s1, const int m, const char* s2, const int n, const int maxlen, char* res, int maxt, int maxb) {
	grid_t grid;
	grid_init( &grid, s1, m, s2, n );

	lcs_length_cuda( &grid, maxt, maxb );
	lcs_backtrack_cuda(&grid, grid.w, grid.h, maxlen, res, maxt, maxb);
}

int main(int argc, char* argv[]) {
	char* s1;
	char* s2;
	int m, n;
	
	
	//s1="MZJAWXU";
	//s2="XMJYAUZ";
	//m = strlen(s1);
	//n = strlen(s2);
	
	char* file1;
	char* file2;
	int maxt, maxb;
	if( !parse_args( argc, argv, &file1, &file2, &maxt, &maxb ) ) {
		printf("Usage: %s file1.txt file2.txt [maxt] [maxb]\n", argv[0]);
		exit(-1);
	}
	
	read_string(file1, &s1, &m);
	read_string(file2, &s2, &n);
	
	
	

	
	// allocate a result string on the device.
	int reslen;
	char* res;
	reslen = max(m, n) + 1;
	res = (char*)malloc( reslen*sizeof(char) );

	double start = get_timeofday();

	lcs_cuda( s1, m, s2, n, reslen, res, maxt, maxb );

	double end = get_timeofday();

	printf("Time Taken: %f sec %i %s\n", end-start, strlen(res), res);
}
