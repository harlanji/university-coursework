#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <assert.h>


#include "util.h"
#include "mpi_matrix.h"
#include "mpi.h"


#define TIME_OUTPUT "Total execution time: %f seconds with %d processors.\n"



int main(int argc, char* argv[]) {
	if(argc < 4) {
		fprintf(stderr, "Usage: %s matrix-file.ij vector-file.vec n\n", argv[0]);
		exit(-1);
	}

	MPI_CALL( MPI_Init(&argc, &argv) );
	
	int n = atoi(argv[3]);
	MPI_Comm comm = MPI_COMM_WORLD;
	
	rank_t p, r;
	
	MPI_CALL( MPI_Comm_size(comm, &p) );
	MPI_CALL( MPI_Comm_rank(comm, &r) );
	
	double start = MPI_Wtime();

	matrix_t mat;
	LOG(LOG_INFO, "Reading matrix for distribution.\n");
	matrix_read( &mat, argv[1], n, n, comm, 0 );
	//matrix_print( &mat );

	matrix_t vec;
	LOG(LOG_INFO, "Reading vector for distribution.\n");
	matrix_read( &vec, argv[2], n, 1, comm, 1 );
	

	LOG(LOG_INFO, "Input is distributed..\n");
	
	double after_read = MPI_Wtime();
	
	MPI_Barrier( comm );
	
	LOG(LOG_INFO, "Synchronizing columns for matrix multiplication.\n");
	
	comm_schedule_t schedule;
	comm_schedule_init( &schedule, comm );

	matrix_sync_build_schedule( &schedule, p, &mat, &vec ); 
	comm_schedule_sync( &schedule );
	
	MPI_Barrier( comm );
	
	double after_sync_schedule = MPI_Wtime();
	comm_schedule_sendrecv( &schedule, &mat, &vec );


	MPI_Barrier( comm );
	
	double after_sync_vec = MPI_Wtime();
	

	matrix_t res;
	LOG(LOG_INFO, "Performing computation matrix for distribution.\n");
	matrix_vector_mult( &mat, &vec, &res );
	
	MPI_Barrier( comm );
	
	
	double after_mult = MPI_Wtime();
	
	// NOTE this is not completely legit since there aren't barriers. this is
	// only p0 times. other processes could still be calculating.
	if(r == 0) {
	/*
		printf("Total: %f\n IO + Dist: %f\n Sync: %f\n Mult: %f\n",
			done - start,
			after_read - start,
			after_sync - after_read,
			done - after_sync ); // 
			*/
		printf("Total Time Taken: %f sec Time Taken (Steps 5&6) : %f sec\n",
			after_mult - after_read,
			after_mult - after_sync_schedule ); 
	}

	//matrix_read( &res, argv[2], n, 1, comm, 1 );

	printf("---res---\n");
	//matrix_print( &res );

	
	MPI_Finalize();
	return 0;
	
	//CLEAN_EXIT(0);
}
