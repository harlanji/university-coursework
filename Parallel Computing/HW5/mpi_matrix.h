#ifndef __MPI_MATRIX_H__
#define __MPI_MATRIX_H__

#include <stdint.h>

#include "util.h"
#include "mpi.h"

/*
typedef unsigned short boolean_t;
typedef unsigned long rank_t;
typedef unsigned long long offset_t;
typedef double value_t; 
*/

#define boolean_t unsigned short
#define rank_t unsigned int
#define offset_t unsigned long
#define value_t double

#define MPI_VALUE_T MPI_DOUBLE
#define MPI_OFFSET_T MPI_UNSIGNED_LONG_LONG

typedef struct cell_t {
	offset_t j;
	value_t val;
} cell_t;

typedef struct matrix_row_t {
	offset_t num_cells;
	cell_t* cells;
} matrix_row_t;

typedef struct mapped_row_t {
	offset_t i;
	matrix_row_t row;
} mapped_row_t;

typedef struct matrix_t {
	offset_t m;
	offset_t n;
	offset_t from_i;
	offset_t to_i;
	matrix_row_t* rows;
	
	// these are transient (not serialized)
	offset_t num_mapped_rows;
	mapped_row_t* mapped_rows;
} matrix_t;


void matrix_init( matrix_t* mat, const offset_t m, const offset_t n, const offset_t from_i, const offset_t to_i );
void matrix_free( matrix_t* mat );

offset_t matrix_num_rows( const matrix_t* mat );
matrix_row_t* matrix_row( const matrix_t* mat, const offset_t i );

void matrix_print( const matrix_t* mat );

void matrix_serialize( const matrix_t* mat, char** buf, offset_t* bufsize );
void matrix_deserialize( matrix_t* mat, const char* buf );

void matrix_read(matrix_t* mat, const char* file, const offset_t m, const offset_t n, MPI_Comm comm, const boolean_t is_vec);
void matrix_read_rows(matrix_t* mat, FILE* input, const boolean_t is_vec);

void matrix_map_row(matrix_t* mat, const matrix_row_t* row, const offset_t i);



void matrix_sync_mult_rows(const matrix_t* mat, matrix_t* vec, MPI_Comm comm);

void matrix_vector_mult(const matrix_t* mat, const matrix_t* vec, matrix_t* res);













// =============================================================================
//      This comm_schedule stuff could be its own library, but there is one
//      remaining dependence on matrix_t in comm_schedule_sendrecv.
// =============================================================================


typedef struct comm_schedule_t {
	MPI_Comm comm;
	
	size_t map_size;
	offset_t* comm_map;

	offset_t** recv_cols;
} comm_schedule_t;

void comm_schedule_init( comm_schedule_t* schedule, MPI_Comm comm );
void comm_schedule_add( comm_schedule_t* schedule, rank_t src_r, offset_t element);
void comm_schedule_sync( comm_schedule_t* schedule);
void comm_schedule_sendrecv( comm_schedule_t* schedule, const matrix_t* mat, matrix_t* vec );



#endif
