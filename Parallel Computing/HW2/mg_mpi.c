#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "serial_sort.h"
#include "mpi.h"

void mg_mpi(int* data, const unsigned long n, const int rank, const int size, const MPI_Comm comm);
void sort_partition(int** partition, const unsigned long partition_size);
void collect_results(int** data, const unsigned long n, int** partition, unsigned long* partition_size, const int rank, const int size, const MPI_Comm comm);

int main(int argc, char* argv[]) {
	int mpi_err, rank, size;
	char* filename;
	int* data;
	unsigned long n;
	
	// validate input
	if(argc < 2) {
		fprintf(stderr, "Usage: %s filename\n", argv[0]);
		return -1;
	}
	

	filename = argv[1];	
	
	// setup MPI
	mpi_err = MPI_Init(&argc, &argv);
	
	MPI_Comm_size( MPI_COMM_WORLD, &size );
	MPI_Comm_rank( MPI_COMM_WORLD, &rank );
	
	// read the input data to sort, on root only
	if(rank == 0) {
		read_data(filename, &data, &n);
	}
	
	double total_time;
	if(rank == 0) {
		total_time = get_timeofday();
	}
	// sort the data
	mg_mpi(data, n, rank, size, MPI_COMM_WORLD);
	
	if(rank == 0) {
		total_time = get_timeofday() - total_time;
	
		printf(TIME_OUTPUT, total_time, size);
		
		// display
		{
		unsigned long i;
		for(i = 0; i < n; i++) {
			printf("%i ", data[i]);
		}
		printf("\n");
		}
		
	}
	
	
	// cleanly shutdown MPI and exit.
	mpi_err = MPI_Finalize();
	
	return 0;
}


void mg_mpi(int* data, const unsigned long n, const int rank, const int size, const MPI_Comm comm) {

	// root tells each process how much data to expect.
	unsigned long partition_size;
	if(rank == 0) {
		partition_size = n / size;	
		
		// TODO handle invalid multiplicity (eg 100 / 8 = 12.5)	
	}
	MPI_Bcast( &partition_size, 1, MPI_UNSIGNED_LONG, 0, comm );
	
	log(LOG_DEBUG, "part size: %u\n", partition_size);

	// allocate a partition of the correct size to work in.
	int* partition = (int*)malloc( partition_size * sizeof(int) );
	
	// scatter data to the partitions
	MPI_Scatter( data, partition_size, MPI_INT, partition, partition_size, MPI_INT, 0, comm );	
	
	// clear initial data, to avoid confusion.
	if(rank == 0) {
		memset(data, 0, n);
	}
	
	// sort inividual pieces using mergesort
	sort_partition(&partition, partition_size);

	// gather results up the tree, merging 2 pieces at each step, until results
	// end up in the root. they are stored in data.
	collect_results(&data, n, &partition, &partition_size, rank, size, comm);
	
	// partition buffer is no longer needed so free it.
	free( partition );
}



void sort_partition(int** partition, const unsigned long partition_size) {
	mergesort(*partition, partition_size);
}


// TODO be conscious of underlying architecture
void collect_results(int** data, const unsigned long n, int** partition, unsigned long* partition_size, const int rank, const int size, const MPI_Comm comm) {
	unsigned long levels = (unsigned long) (log10(size)/log10(2));
	
	if(rank == 0) {
		log(LOG_DEBUG, "Collecting with %d levels.\n", levels);
	}

	// for each level in the logical tree, each right sibling node sends
	// its buffer to the left sibling, and the left merges them.
	unsigned long i;
	for(i = 1; i <= levels; i++) {
		if(rank == 0) { 
			log(LOG_DEBUG, "Starting level %d.\n", i);
		}
	
		int left_sib = (int)pow(2, i);
		int right_sib = (int)pow(2, i-1);
	
		// if this is a left sibling then receive from right
		if( (rank % left_sib) == 0 ) {
			unsigned long new_partition_size = 2 * (*partition_size);
			*partition = (int*)realloc( *partition, new_partition_size * sizeof(int) );
			
			int sender = rank + right_sib;
			MPI_Status status;

			MPI_Recv( (*partition + *partition_size), *partition_size, MPI_INT, sender, 0, comm, &status );
			log(LOG_DEBUG, "%i <- %i\n", rank, sender);


			// merge results 
			int* temp = (int*)malloc( new_partition_size * sizeof(int) );

			
			{
			merge(*partition, *partition + *partition_size, *partition_size, temp);
			memcpy( *partition, temp, new_partition_size * sizeof(int));
			*partition_size = new_partition_size;
			}
			
			
			free(temp);
			
			/*{
			unsigned long i;
			for(i = 0; i < *partition_size; i++) {
				log(LOG_TRACE, "[%i] partition[%i]: %i\n", rank, i, (*partition)[i]);
			}
			}*/

			
		// if this is a right sibling then send to left
		} else if( ((rank+right_sib) % left_sib) == 0 ) {
			int receiver = rank - right_sib;

			MPI_Send( *partition, *partition_size, MPI_INT, receiver, 0, comm );
			log(LOG_DEBUG, "%i ->  %i\n", rank, receiver);
			// partition is freed after this function.
		} else {
			// we're done
			log(LOG_DEBUG, "%i is done.\n", rank);
		}
		
		//MPI_Barrier( comm );
		
		if(rank == 0) { 
			log(LOG_DEBUG, "Level %d is done.\n", i);
		}
	}
	
	if(rank == 0) {
		memcpy( *data, *partition, n * sizeof(int) );
	}
}

