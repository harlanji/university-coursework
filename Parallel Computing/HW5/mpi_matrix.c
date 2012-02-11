#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <assert.h>


#include "util.h"
#include "mpi_matrix.h"
#include "mpi.h"




// read sparse matrix
// LIL representation: 
// http://en.wikipedia.org/wiki/Sparse_matrix#List_of_lists_.28LIL.29
void matrix_init( matrix_t* mat, const offset_t m, const offset_t n, const offset_t from_i, const offset_t to_i ) {
	mat->m = m;
	mat->n = n;
	mat->from_i = from_i;
	mat->to_i = (to_i >= m) ? m-1 : to_i;
	mat->num_mapped_rows = 0;
	mat->mapped_rows = NULL;
	
	assert( mat->from_i >= 0 );
	
	assert( mat->to_i >= mat->from_i );
	assert( mat->to_i < mat->m );
	
	offset_t rows_size = matrix_num_rows(mat) * sizeof(matrix_row_t);
	mat->rows = (matrix_row_t*)malloc( rows_size );
	LOG(LOG_DEBUG, "alloc %lu x %lu matrix. rows_size=%lu. from_i=%lu, to_i=%lu, # rows=%lu\n", m, n, rows_size, mat->from_i, mat->to_i, matrix_num_rows(mat));
	CHECK_ALLOC( mat->rows );
	
	memset( mat->rows, 0, rows_size );
}





offset_t matrix_num_rows( const matrix_t* mat ) {
	offset_t num_rows = mat->to_i - mat->from_i + 1;
	
	assert( num_rows <= mat->m );

	return num_rows;
}

matrix_row_t* matrix_row( const matrix_t* mat, const offset_t i ) {
	matrix_row_t* ret = NULL;
	
	if(i <= mat->to_i && i >= mat->from_i) {
		ret = &(mat->rows[ i - mat->from_i ]);
		
		if( ret == NULL ) {
			LOG(LOG_ERROR, "wtf? matrix with range [%uul,%uul] does not have row %uul??\n", mat->from_i, mat->to_i, i );
		}
		
		assert( ret != NULL );
	} else {
		offset_t mi;
		for(mi = 0; mi < mat->num_mapped_rows; mi++) {
			mapped_row_t* mapped_row = &(mat->mapped_rows[ mi ]);
			if(mapped_row->i == i) {
				ret = &(mapped_row->row);
				
				assert( ret != NULL );
			}
		}
	}
	
	return ret;
}

void matrix_print( const matrix_t* mat ) {
	offset_t i;
	for(i = mat->from_i; i <= mat->to_i; i++) {
		matrix_row_t* row = matrix_row( mat, i );
		offset_t sj;
		for(sj = 0; sj < row->num_cells; sj++) {
			cell_t* cell = &(row->cells[ sj ]);
			
			printf("(%lu, %lu, %f)\n", i, cell->j, cell->val);
		}
	}
	
	if(mat->num_mapped_rows > 0) {
		printf("---mapped:\n");
	
		for(i = 0; i < mat->num_mapped_rows; i++) {
			mapped_row_t* mr = &(mat->mapped_rows[i]);
			matrix_row_t* row = &(mr->row);
			
			assert( row != NULL );
			
			offset_t sj;
			for(sj = 0; sj < row->num_cells; sj++) {
				cell_t* cell = &(row->cells[ sj ]);
				
				assert( cell != NULL );
			
				printf("(%lu, %lu, %f)\n", mr->i, cell->j, cell->val);
			}
		}
	}
}


void matrix_serialize( const matrix_t* mat, char** buf, offset_t* bufsize ) {
	*bufsize = sizeof(matrix_t) + matrix_num_rows(mat) * sizeof(matrix_row_t);
	
	// calculate buffer size
	offset_t i;
	for( i = mat->from_i; i <= mat->to_i; i++ ) {
		*bufsize += matrix_row(mat, i)->num_cells * sizeof(cell_t);
	} 
	LOG(LOG_DEBUG, "serialize buffer size: %lu\n", *bufsize);
	
	*buf = (char*)malloc( *bufsize );
	CHECK_ALLOC( *buf );
	
	size_t offset = 0;
	size_t copy_size = 0;
	
	// copy matrix
	copy_size = sizeof(matrix_t);
	memcpy( *buf, mat, copy_size  );
	offset += copy_size;
	
	// copy rows
	copy_size = matrix_num_rows(mat) * sizeof(matrix_row_t);
	memcpy( *buf + offset, matrix_row(mat, mat->from_i), copy_size );
	offset += copy_size;
	
	// copy cells of each row
	for( i = mat->from_i; i <= mat->to_i; i++ ) {
		matrix_row_t* row = matrix_row(mat, i);

		if(row->num_cells > 0) {
			LOG(LOG_DEBUG, "-->(%lu) has %lu\n", i, row->num_cells);
		
			copy_size = row->num_cells * sizeof(cell_t);
			memcpy( *buf + offset, row->cells, copy_size );
			offset += copy_size;
		}
	}
	
	assert( offset == *bufsize );
}

void matrix_deserialize( matrix_t* mat, const char* buf ) {
	size_t offset = 0;
	size_t copy_size = 0;
	// copy matrix
	copy_size = sizeof(matrix_t);
	memcpy( mat, buf, copy_size );
	offset += copy_size;
	
	// explicitly set this null to avoid problems.
	mat->num_mapped_rows = 0;
	mat->mapped_rows = NULL;
	
	LOG(LOG_DEBUG, "deserializing matrix... from_i=%lu, to_i=%lu. #=%lu\n", mat->from_i, mat->to_i, matrix_num_rows(mat) );

	// copy rows
	copy_size = matrix_num_rows(mat) * sizeof(matrix_row_t);
	mat->rows = (matrix_row_t*)malloc( copy_size );
	CHECK_ALLOC( mat->rows );
	memset( mat->rows, 0, copy_size );
	
	memcpy( matrix_row(mat, mat->from_i), buf + offset, copy_size );
	offset += copy_size;

	LOG(LOG_DEBUG, "deserializing matrix... from_i=%lu, to_i=%lu\n", mat->from_i, mat->to_i );

	// copy cells of each row
	offset_t i;
	for( i = mat->from_i; i <= mat->to_i; i++ ) {
		
		matrix_row_t* row = matrix_row(mat, i);
		
		assert( row != NULL );
		assert( row->num_cells <= mat->n );
		
		
		LOG(LOG_DEBUG, "(%lu) has %lu\n", i, row->num_cells);
		
		if( row->num_cells > 0 ) {
			copy_size = row->num_cells * sizeof(cell_t);
			row->cells = (cell_t*)malloc( copy_size );
			CHECK_ALLOC( row->cells );
			memcpy( row->cells, buf + offset, row->num_cells * sizeof(cell_t) );
			offset += copy_size;
		}
	}
}


void matrix_read_rows(matrix_t* mat, FILE* input, const boolean_t is_vec) {

	const char* sep = "(), \n";
	
	offset_t line_num = 0;
	
	
	while( !feof( input ) ) {
		offset_t i, j, cell_val;
	
		fpos_t start_pos;
		char line[ 50 ];
		fgetpos( input, &start_pos );
		fgets( line, 50, input );
		
		// HACK
		if(is_vec) {
			i = mat->from_i + line_num;
			j = 0;
			cell_val = atoi( line );
		} else {
			char* tok = NULL;
			char* brk = NULL;
			offset_t num_toks = 0;
			for(tok = strtok_r(line, sep, &brk);
				tok;
				tok = strtok_r(NULL, sep, &brk), num_toks++ ) {
				value_t val = atoi( tok );

				switch(num_toks) {
					case 0:
						i = val;
						break;
					case 1:
						j = val;
						break;
					case 2:
						cell_val = val;
						break;
				};
			}
		
			if(num_toks < 2) {
				break;
			}
			
			if( j >= mat->n || j < 0 || i >= mat-> m || i < 0 ) {
				LOG(LOG_ERROR, "Out of bounds cell: (%lu, %lu).\n", i, j);
				CLEAN_EXIT(-1);
			} 
			
			assert( i < mat->m );
			assert( j < mat->n );
		}
		
		if( i > mat->to_i ) {
			fsetpos( input, &start_pos );
			break;
		}
		
		assert( i >= mat->from_i );
		assert( i <= mat->to_i );
	
		
		matrix_row_t* row = matrix_row(mat, i);
		
		assert( row != NULL );
	
		size_t cells_size = sizeof(cell_t)*(row->num_cells + 1);
		row->cells = (cell_t*)realloc( row->cells, cells_size );
		CHECK_ALLOC( row->cells );
		
		cell_t* cell = &(row->cells[ row->num_cells ]);
		CHECK_ALLOC( cell );
		cell->j = j;
		cell->val = cell_val;
	
		LOG(LOG_DEBUG, "read-->(%lu, %lu, %lu)\n", i, j, cell_val);
	
		row->num_cells++;
		line_num++;
		
		// this could go father and assert sparse-ness
		assert( row->num_cells <= mat->n );
		
		// FIXME why is this failing?
		assert( line_num <= mat->from_i + mat->n * matrix_num_rows( mat ) );
	}
}

#define MSG_PARTITION_SIZE 1
#define MSG_MATRIX_PARTITION 2

void matrix_read(matrix_t* mat, const char* file, const offset_t m, const offset_t n, MPI_Comm comm, const boolean_t is_vec) {
	rank_t p, r;
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );

	if( r == 0 ) {
		matrix_t root_mat;
		const offset_t partition_size = floor( (double)m / (double)p );
	
		LOG(LOG_IO, "matrix_read: m=%lu, p=%u, partition_size (m/p)=%lu\n", m, p, partition_size);

		FILE* input = fopen(file, "r");
		
		size_t mem_size = 2*p*sizeof(MPI_Request);
		MPI_Request* request = (MPI_Request*)malloc( mem_size );
		memset( request, 0, mem_size );
		
		char** buf = (char**)malloc( p*sizeof(char*) );

		rank_t to_r;
		for(to_r = 0; to_r < p; to_r++) {
		
			{ // limit scope of from/to_i because matrix_init may change them.
			offset_t from_i = to_r * partition_size;
			offset_t to_i = (to_r+1) * partition_size - 1;
			
			// since we floor divisions, give the last processor the slack...
			if(to_r == p - 1) {
				//printf("last fix\n");
				to_i = m - 1;
			}
			
			
			matrix_init( mat, m, n, from_i, to_i );
			
			LOG(LOG_IO, "give partition of range [%lu, %lu] to r=%u, \n", mat->from_i, mat->to_i, to_r);
			
			matrix_read_rows( mat, input, is_vec );
			
			// >= because the last row can be bigger.
			assert(matrix_num_rows( mat ) >= partition_size );
			assert(matrix_num_rows( mat ) < 2*partition_size );
			}
			
			if( to_r != 0 ) {
				offset_t bufsize;

				matrix_serialize( mat, &(buf[to_r]), &bufsize );
			
				assert( buf[to_r] != NULL );
				assert( bufsize > 0 );

				MPI_CALL( MPI_Send(&bufsize, 1, MPI_OFFSET_T, to_r, 0, comm ) ); // , &request[to_r - 1]
				MPI_CALL( MPI_Isend(buf[to_r], bufsize, MPI_BYTE, to_r, 1, comm, &request[p + to_r - 2] ) ); // , 

				matrix_free( mat );
			} else {
				memcpy( &root_mat, mat, sizeof(matrix_t) ); 
			}
		}
		
		LOG(LOG_IO, "waiting for distribution to complete...\n", 0);
		
		fclose( input );
		
		
		
		
		//MPI_Waitall( 2*p - 2, request, MPI_STATUSES_IGNORE );
		
		for(to_r = 1; to_r < p; to_r++) {
			//free(buf[to_r]);
		} 
		//free(buf);
		//free(request);
		
		memcpy( mat, &root_mat, sizeof(matrix_t) );
		
		LOG(LOG_IO, "matrix dist done.\n");

	} else {
		char* buf;
		offset_t bufsize;
		MPI_Status stat;
	
		LOG(LOG_IO, "%u: waiting for parition size...\n", r );
	
		MPI_CALL( MPI_Recv(&bufsize, 1, MPI_OFFSET_T, 0, 0, comm, &stat ) );
		assert( bufsize >= 0 );
	
		buf = (char*)malloc( bufsize );
	
		CHECK_ALLOC( buf );
	
		LOG(LOG_IO, "%u: waiting for parition buffer of size %lu...\n", r, bufsize );

		MPI_CALL( MPI_Recv(buf, bufsize, MPI_BYTE, 0, 1, comm, &stat ) );

		LOG(LOG_IO, "%u: got partiton buffer. about to deserialize.\n", r );

		matrix_deserialize( mat, buf );
	
		LOG(LOG_IO, "%u: got partiton buffer. partition is size=%lu...\n", r, matrix_num_rows( mat ) );
	
		free( buf );
	}
	
	//MPI_Barrier( comm );
}

void matrix_free( matrix_t* mat ) {

	//TODO free mapped cells

	// free cells for each row
	offset_t i;
	for( i = mat->from_i; i <= mat->to_i; i++ ) {
		matrix_row_t* row = matrix_row(mat, i);

		if(row->num_cells > 0) {
			free( row->cells );
		}
	}

	// free rows
	free( matrix_row(mat, mat->from_i) );


	// do not free matrix itself. but 0 it.
	memset( mat, 0, sizeof(matrix_t) );
}

void matrix_map_row(matrix_t* mat, const matrix_row_t* row, const offset_t i) {

	if( matrix_row( mat, i ) != NULL ) {
		//printf(" problem, sir" );
		return;
	}
	
	// allocate space to copy the row
	size_t copy_size =  (mat->num_mapped_rows+1)*sizeof(mapped_row_t);
	mat->mapped_rows = (mapped_row_t*)realloc( mat->mapped_rows, copy_size );
	CHECK_ALLOC( mat->mapped_rows );

	// setup the mapped row
	copy_size = sizeof(matrix_row_t);
	mapped_row_t* mapped_row = &(mat->mapped_rows[mat->num_mapped_rows]);
	mapped_row->i = i;
	memcpy( &(mapped_row->row), row, copy_size );
	
	assert( row->num_cells >= 0 );
	assert( row->num_cells <= mat->n );
	
	// allocate space for the copied cells and copy them
	copy_size = row->num_cells * sizeof(cell_t);
	mapped_row->row.cells = (cell_t*)malloc( copy_size );
	CHECK_ALLOC( mapped_row->row.cells );
	memcpy( mapped_row->row.cells, row->cells, copy_size );
	
	
	mat->num_mapped_rows++;
	
	assert( mat->num_mapped_rows <= mat->m - matrix_num_rows( mat ) );
}

// =============================================================================
//      This comm_schedule stuff could be its own library, but there is one
//      remaining dependence on matrix_t in comm_schedule_sendrecv.
// =============================================================================


void comm_schedule_init( comm_schedule_t* schedule, MPI_Comm comm ) {
	rank_t p, r;
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );

	schedule->comm = comm;

	schedule->map_size = p*p*sizeof(offset_t);
	schedule->comm_map = (offset_t*)malloc( schedule->map_size );
	CHECK_ALLOC( schedule->comm_map );
	memset( schedule->comm_map, 0, schedule->map_size );
	
	schedule->map_size = p*sizeof(offset_t*);
	schedule->recv_cols = (offset_t**)malloc( schedule->map_size );
	CHECK_ALLOC(schedule->recv_cols);
	memset( schedule->recv_cols, 0, schedule->map_size );
}


// FIXME offset_t vs. value_t!!!
void comm_schedule_add( comm_schedule_t* schedule, rank_t src_r, offset_t element) {
	rank_t p, r;
	MPI_Comm comm = schedule->comm;
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );
	
	assert(src_r < p);

	offset_t idx = r*p + src_r;

	assert(idx < p*p);

	
	offset_t num_elems = schedule->comm_map[ idx ];
	
	// avoid duplicates.
	offset_t i;
	for(i = 0; i < num_elems; i++) {
		offset_t el = schedule->recv_cols[ src_r ][ i ];
		
		if( el == element ) {
			return; // num_elems;
		}
	}



	LOG(LOG_TRACE, "%u NEEDS: row %lu from %u. comm_map idx=%lu\n", r, element, src_r, idx);

	// add the column to receive
	size_t alloc_size = (schedule->comm_map[ idx ] + 1)*sizeof(offset_t);
	schedule->recv_cols[ src_r ] = (offset_t*)realloc( schedule->recv_cols[ src_r ], alloc_size );
	CHECK_ALLOC( schedule->recv_cols[ src_r ] );
	schedule->recv_cols[ src_r ][ schedule->comm_map[ idx ] ] = element;
	
	//LOG(LOG_TRACE, "%lu NEEDS: row %lu (%lu) from %lu.\n", r, element, schedule->recv_cols[ src_r ][ schedule->comm_map[ idx ] ], src_r);
	
	// increment the number of columns to receive
	schedule->comm_map[ idx ]++;
	
}

void comm_schedule_sync( comm_schedule_t* schedule) {
	rank_t p, r;
	MPI_Comm comm = schedule->comm;
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );

	LOG(LOG_TRACE, "map.before(%u): %lu %lu\n", r, schedule->comm_map[0], schedule->comm_map[1]);
	
	MPI_CALL( MPI_Allgather( schedule->comm_map + r*p, p, MPI_OFFSET_T, schedule->comm_map, p, MPI_OFFSET_T, comm ) );
	
	LOG(LOG_TRACE, "map.after(%u): %lu %lu %lu %lu\n", r, schedule->comm_map[0], schedule->comm_map[1], schedule->comm_map[2], schedule->comm_map[3] );
}

// FIXME generalize by taking out snip sections are replacing them with some
//       kind of hook functions that have mat and vec in an argument object.
// FIXME rename variables. they make no sense.
// TODO  split this up and make all sends happen async in the beginning, and
//       interleave recvs into computation.
void comm_schedule_sendrecv( comm_schedule_t* schedule, const matrix_t* mat, matrix_t* vec ) {
	rank_t p, r;
	MPI_Comm comm = schedule->comm;
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );
	
	offset_t comm_id;
	MPI_Status stat;
	for(comm_id = 0; comm_id < p*p; comm_id++) {
		offset_t num_cells = schedule->comm_map[comm_id];
		
		// FIXME why is this failing? duplicates...
		//assert( num_cells <= mat->n );
		
		assert( num_cells >= 0 );
		
		if( num_cells > 0 ) {
			rank_t send_r = comm_id % p;
			rank_t recv_r = comm_id / p;
			
			assert( send_r != recv_r );
			assert( send_r < p );
			assert( recv_r < p );
		

			if(r == send_r) {
				LOG(LOG_IO, "%u: send %llu cells to %u\n", r, num_cells, recv_r );
				
				// FIXME offset_t vs. value_t
				
				// recv column numbers (offset_t) to send values for
				offset_t* requested_cols = (offset_t*)malloc( num_cells*sizeof(offset_t) );
				CHECK_ALLOC( requested_cols );
				MPI_CALL( MPI_Recv( requested_cols, num_cells, MPI_OFFSET_T, recv_r, 2, comm, &stat ) );

				

				// collect values for those columns
				value_t* cell_values = (value_t*)malloc( num_cells*sizeof(value_t) );
				offset_t row_num;
				for(row_num = 0; row_num < num_cells; row_num++) {
					// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv //
					matrix_row_t* send_row = matrix_row( vec, requested_cols[row_num] );
					
					assert( send_row != NULL );
					
					cell_values[row_num] = send_row->cells->val;
					
					LOG(LOG_TRACE, "%u -- (col %lu = %f) --> %u\n", r, requested_cols[row_num], cell_values[row_num] , recv_r );
					
					
					// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ //
				}
				
				// actually send the values (value_t)
				
				MPI_Request* req = (MPI_Request*)malloc(sizeof(MPI_Request));
				MPI_CALL( MPI_Isend( cell_values, num_cells, MPI_VALUE_T, recv_r, 3, comm, req ) );
			} else if( r == recv_r ) {
				LOG(LOG_IO, "%u: recv %llu cells from %u\n", r, num_cells, send_r );
				
				// tell sender which columns (offset_t) we want values for

				MPI_CALL( MPI_Send( schedule->recv_cols[ send_r ], num_cells, MPI_OFFSET_T, send_r, 2, comm ) );
				
				
				// get those values back (value_t)
				value_t* cell_values = (value_t*)malloc( num_cells*sizeof(value_t) );
				CHECK_ALLOC( cell_values );
				MPI_CALL( MPI_Recv( cell_values, num_cells, MPI_VALUE_T, send_r, 3, comm, &stat ) );
				
				offset_t row_num;
				for(row_num = 0; row_num < num_cells; row_num++) {
					offset_t element = schedule->recv_cols[send_r][row_num];
					value_t val = cell_values[row_num];
					LOG(LOG_TRACE, "%u <-- (got %lu = %f) -- %u\n", r, element, val , send_r );
					
					// vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv //

					assert( element >= 0 );
					assert( element <= mat->n );
					
					cell_t new_cell = {
						j: 0,
						val: val
					};
					matrix_row_t new_row = {
						num_cells: 1,
						cells: &new_cell
					};
					
					matrix_map_row( vec, &new_row, element );
					// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ //
				}
				
			}
		} 
	}
}

// =============================================================================



void matrix_sync_build_schedule( comm_schedule_t* schedule, rank_t p, const matrix_t* mat, const matrix_t* vec ) {
	offset_t partition_size = floor( (double)mat->m / (double)p );

	offset_t i;
	for(i = mat->from_i; i <= mat->to_i; i++) {
		matrix_row_t* row = matrix_row( mat, i );
		offset_t sj;
		for(sj = 0; sj < row->num_cells; sj++) {
			cell_t* cell = &(row->cells[ sj ]);
			
			// see if the vector we're multiplying with has the row
			
			//matrix_row_t* dest_row = matrix_row( vec, cell->j );
			//if( dest_row == NULL ) {
			
			if( cell->j < mat->from_i || cell->j > mat->to_i ) {
				rank_t src_r = floor( (double)cell->j / (double)partition_size ); 
				
				// HACK there should be a better comm function to handle this...
				if(src_r >= p) {
					src_r = p - 1;
				}
				offset_t element = cell->j;
				
				comm_schedule_add( schedule, src_r, element);
			}
		}
	}
}

void matrix_sync_mult_rows(const matrix_t* mat, matrix_t* vec, MPI_Comm comm) {

	rank_t p, r;
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );
	
	
	
	comm_schedule_t schedule;
	comm_schedule_init( &schedule, comm );


	matrix_sync_build_schedule( &schedule, p, mat, vec ); 

	comm_schedule_sync( &schedule );
	
	//MPI_Barrier( comm );
	
	comm_schedule_sendrecv( &schedule, mat, vec );
}

void matrix_vector_mult(const matrix_t* mat, const matrix_t* vec, matrix_t* res) {
	matrix_init( res, mat->m, 1, mat->from_i, mat->to_i );

	offset_t i;
	for(i = mat->from_i; i <= mat->to_i; i++) {
		matrix_row_t* Arow = matrix_row( mat, i );
		
		value_t val = 0;
		
		offset_t sj;
		for(sj = 0; sj < Arow->num_cells; sj++) {
			cell_t* Acell = &(Arow->cells[ sj ]);
		
			matrix_row_t* xrow = matrix_row( vec, Acell->j );
			cell_t* xcell = xrow->cells;

			//printf("res[%lu] += %lu x %lu = %lu\n", i, Acell->val, xcell->val, Acell->val * xcell->val ); 
			

			
			val += Acell->val * xcell->val;

		}
		
		matrix_row_t* brow = matrix_row( res, i );
		
		brow->num_cells = 1;
		brow->cells = (cell_t*)malloc(sizeof(cell_t));
		CHECK_ALLOC( brow->cells );
		brow->cells->j = 0;
		brow->cells->val = val;
	}
}
