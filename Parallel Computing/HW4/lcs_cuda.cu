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

__device__ __host__
void map_on( int x, int y, int* mx, int* my ) {
		*mx = x;
		*my =  x + y - 1;
}

__device__ __host__
void map_off( int mx, int my, int* x, int* y ) {
		*x = mx;
		*y = my - mx + 1;
}






/*
void transform(int m, int n) {
	// alloc d x n grid
	// copy each (x,y) => (d-y+1, d-x+1)

	int num_diag = m + n - 1;
	int nm = num_diag, nn = n;
	
	printf("tranforming %i x %i to %i x %i\n", m, n, nm, nn);

	int x, y;
	for(y = 1; y <= m; y++) {
		for(x = 1; x <= n; x++) {
			int mx, my;
			map_on( x, y, &mx, &my );
			
			//int ox = 0;
			//int oy = 0;
			//map_off( nx, ny, &ox, &oy );
			
			printf("(%i, %i) => (%i, %i) => (%i, %i)\n", x, y, mx, my);
		}
	}
}
*/


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
	char* sx;
	char* sy;
	
	cell_t* cells;
} grid_t;


void cudaMallocOrDie( void** pptr, const size_t size, const char* code ) {
	if( cudaMalloc(pptr, size) != cudaSuccess) {
		printf("cudaMalloc Failed: %s\n", code);
		exit(-1);
	}
}

void cudaMemcpyOrDie( void* dst, const void* src, const size_t size, const enum cudaMemcpyKind kind, const char* code ) {
	if( cudaMemcpy( dst, src, size, kind ) != cudaSuccess) {
		printf("cudaMalloc Failed: %s\n", code);
		exit(-1);
	}
}

void cudaMemsetOrDie( void* dst, char value, size_t size, const char* code ) {
	if( cudaMemset( dst, value, size ) != cudaSuccess) {
		printf("cudaMemset Failed: %s\n", code);
		exit(-1);
	}
}

void grid_init(grid_t* dgrid, const char* s1, const int m, const char* s2, const int n) {
	grid_t grid;

	// set sizes
	grid.w = m;
	grid.h = n;
	grid.d = grid.w + grid.h - 1;
	
	// copy strings to device
	cudaMallocOrDie( (void**)&(grid.sx), m*sizeof(char), "grid_init 1" );
	cudaMemcpyOrDie( grid.sx, s1, m*sizeof(char), cudaMemcpyHostToDevice, "grid_init 2" );
	
	cudaMallocOrDie( (void**)&(grid.sy), n*sizeof(char), "grid_init 3" );
	cudaMemcpyOrDie( grid.sy, s2, n*sizeof(char), cudaMemcpyHostToDevice, "grid_init 4" );

	// create cell grid on device
	size_t size = (grid.d + 1) * (grid.w + 1) * sizeof(cell_t);
	printf("size=%i\n", size);
	cudaMallocOrDie( (void**)&(grid.cells), size, "grid_init 5" );
	cudaMemsetOrDie( grid.cells, 0, size, "grid_init 6" );
	
	// copy the stuff we just created to the device. NOTE all pointers
	// are relative to device.
	cudaMemcpyOrDie( dgrid, &grid, sizeof(grid_t), cudaMemcpyHostToDevice, "grid_init 7" );
}

__device__ 
cell_t* grid_cell(const grid_t* grid, const int x, const int y) {

	int mx, my;
	map_on( x, y, &mx, &my );

	return &(grid->cells[ (grid->w + 1)*x + y ]);
}

/*
void build_table(int m, int n) {
	int num_diag = m + n - 1;
	
	int x, y;
	for(y = 1; y <= m; y++) {
		for(x = 1; x <= n; x++) {
			int mx, my;
			
			// get neighboring values
			map_on( x, y - 1, &mx, &my );
			int val_up = grid( mx, my );
			map_on( x - 1, y, &mx, &my );
			int val_left = grid( mx, my );
			map_on( x - 1, y - 1, &mx, &my );
			int val_upleft = grid( mx, my );
			
			// set value of cell
			int val;
			if( s2[x-1] == s1[y-1] ) {
				val = val_upleft + 1;
			} else {
				val = max( val_up, val_left );
			}

			map_on( x, y, &mx, &my );
			grid( mx, my ) = val;
			
		
			// same LCS build table code, but with nx and ny mapping.
			// x = thread. maybe x/p loop.
		}
	}
}

*/



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


__global__
void lcs_length_row_cuda( const grid_t* grid, int d, int bw, int bh ) {

	int x = blockDim.x * blockIdx.x + threadIdx.x;
	
	int y;
	for(y = d; y < d + bh; y++) {
		int i, j;
		map_off( x, y, &i, &j );
	
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


void lcs_length_cuda( const grid_t* dgrid, int maxb, int maxt ) {

	// FIXME
	grid_t lgrid;
	grid_t* grid = &lgrid;
	cudaMemcpyOrDie( grid, dgrid, sizeof(grid_t), cudaMemcpyDeviceToHost, "lcs_length_cuda 1" );


	int bw = ceil(grid->w / (double)maxb);
	int bh = 10;

	int nd = grid->d/bh;

	int d;
	for(d = 0; d < nd; d ++) {
	
		int sx = max(d - grid->h, 0);
		int fx = min(d, grid->w - 1);
		
		int nt = min(bw, maxt);
		int nb = min(ceil((fx - sx)/ (double)bw), (double)maxb);
		
		
		printf("sx=%i, fx=%i, nb=%i, nt=%i, bw=%i, bh=%i\n", sx, fx, nb, nt, bw, bh);

		
		//lcs_length_row_cuda<<<nb, nt>>>( dgrid, d, bw, bh );
	}

}



__global__
void lcs_backtrack_cuda(const grid_t* grid, int i, int j, const int maxlen, char* res) {

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
}



void lcs_cuda(const char* s1, const int m, const char* s2, const int n, const int maxlen, char* res) {
	
	// create grid on device
	grid_t* grid;
	cudaMallocOrDie( (void**)&grid, sizeof(grid_t), "lcs_cuda 1");
	grid_init( grid, s1, m, s2, n );


	// run length algorithm (makes kernel calls)
	lcs_length_cuda( grid, 20, 32 );
	
	// create a string on the device for result, and calculate result
	char* dres;
	cudaMallocOrDie( (void**)&dres, maxlen*sizeof(char), "lcs_cuda 2");

	// FIXME use grid h/w 
	//lcs_backtrack_cuda<<<1, 1>>>(grid, m, n, maxlen, dres);
	
	// copy result back, and reverse it (calculated backwards).
	cudaMemcpyOrDie( res, dres, maxlen, cudaMemcpyDeviceToHost, "lcs_cuda 3" );

	strrev(res);
}

int main() {
	char* s1;
	char* s2;
	int m, n;
	
	
	s1="MZJAWXUMZJAWXUMZJAWXUMZJAWXU";
	s2="XMJYAUZXMJYAUZXMJYAUZXMJYAUZ";
	m = strlen(s1);
	n = strlen(s2);
	
	read_string("small_test1.txt", &s1, &m);
	read_string("small_test2.txt", &s2, &n);
	

	
	// allocate a result string on the device.
	int reslen;
	char* res;
	reslen = max(m, n) + 1;
	res = (char*)malloc( reslen*sizeof(char) );

	double start = get_timeofday();

	lcs_cuda( s1, m, s2, n, reslen, res );

	double end = get_timeofday();

	printf("Time Taken: %f sec %i %s\n", end-start, strlen(res), res);
}

/*


int main() {
	char* s1;
	char* s2;
	int m, n;
	
	
	//s1="MZJAWXU";
	//s2="XMJYAUZ";
	//m = strlen(s1);
	//n = strlen(s2);
	
	read_string("large_test1.txt", &s1, &m);
	read_string("large_test2.txt", &s2, &n);
	
	// copy strings to device
	char* ds1;
	char* ds2;
	cudaMalloc( &ds1, m );
	cudaMalloc( &ds2, n );
	cudaMemcpy( ds1, s1, m, cudaMemcpyHostToDevice );
	cudaMemcpy( ds2, s2, n, cudaMemcpyHostToDevice );
	
	// allocate space for the grid on the device
	int d = m + n - 1;
	int mh = d, mw = m;
	size_t size = (mh + 1) * (mw + 1) * sizeof(cell_t);
	cell_t* cells;
	cudaMalloc( &cells, size );
	cudaMemset( cells, 0, size );
	
	// allocate a result string on the device.
	int reslen;
	char* res;
	reslen = max(m, n) + 1;
	cudaMalloc(&res, reslen*sizeof(char));

	double start = get_timeofday();

	lcs_cuda( ds1, m, ds2, n, reslen, res );

	double end = get_timeofday();
	
	char* rres = (char*)malloc(reslen);
	
	cudaMemcpy( rres, res, reslen, cudaMemcpyDeviceToHost );
	
	printf("Time Taken: %f sec %i %s\n", end-start, strlen(rres), rres);
	

}

*/
