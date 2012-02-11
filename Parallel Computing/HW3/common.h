#ifndef __COMMON_H__
#define __COMMON_H__


// misc utils

int parse_args( int argc, char* argv[], char** file1, char** file2, int* p );
int read_string(char* filename, char** s, int* len);
int max(int a, int b);
char* strrev(char * string);
double get_timeofday();



// grid API

typedef struct cell_t {
	int len;
	enum { none = 0, up, left, upleft } dir;
} cell_t;

typedef struct grid_t {
	int m;
	int n;
	const char* s1;
	const char* s2;
	
	cell_t* cells;
} grid_t;

void grid_deserialize_block( const grid_t* grid, const cell_t* serialized, const int y, const int x, const int h, const int w );
cell_t* grid_serialize_block( const grid_t* grid, const int y, const int x, const int h, const int w );
cell_t* grid_alloc_block( const int h, const int w );
cell_t* grid_cell(const grid_t* grid, const int i, const int j);
void grid_init(grid_t* grid, const char* s1, const char* s2);

// lcs API


typedef struct backtrack_state_t {
	int i;
	int j;
	int pos;
	char* res;
} backtrack_state_t;

void lcs_backtrack_block(const grid_t* grid, backtrack_state_t* state, int min_i, int min_j);
void lcs_length_block( const grid_t* grid, const int y, const int x, const int h, const int w  );


#endif // __COMMON_H__
