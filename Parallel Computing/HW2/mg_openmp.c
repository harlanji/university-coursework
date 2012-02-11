#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

#include "serial_sort.h"

// must be adjacent. result will be at left_start.
typedef struct merge_task {
	int task_id;
	
	int* data;
	unsigned long start_left;
	unsigned long start_right;
	int* result;
	
	unsigned long n;
} merge_task_t;


typedef struct sort_task {
	int task_id;

	int* data;
	unsigned long start;
	
	unsigned long n;
} sort_task_t;

 

void* sort_thread_main(void* arg) {
	sort_task_t* task = (sort_task_t*)arg;
	
	log(LOG_DEBUG, "Started sort thread %i\n", task->task_id );
	
	mergesort( task->data + task->start, task->n );
}




void* merge_thread_main(void* arg) {
	merge_task_t* task = (merge_task_t*)arg;
	
	log(LOG_DEBUG, "Started merge thread %i. size=%u, l=%u, r=%u.\n", task->task_id, task->n, task->start_left, task->start_right );
	
	merge( task->data + task->start_left, task->data + task->start_right, task->n, task->result );
}



int main(int argc, char* argv[]) {

	
	

	// read input file
	unsigned long n;
	int* data;


	// validate input
	if(argc < 2) {
		fprintf(stderr, "Usage: %s filename [numprocs=8]\n", argv[0]);
		return -1;
	}
	
	
	int p;
	if( argc >= 3 ) {
		sscanf(argv[2], "%d", &p);
	}
	if(p < 1 || p > 8) {
		p = 8;
	}
	
	omp_set_num_threads(p);
	log(LOG_DEBUG, "p=%i\n", p);
	
	
	read_data(argv[1], &data, &n);

	unsigned long partition_size = n / p;
	
	double total_time = get_timeofday();

	// sort
	
	{
	sort_task_t sort_task;
	
	
	int r;
	#pragma omp parallel for private(sort_task)
	for(r = 0; r < p; r++) {
		sort_task.task_id = r;
		sort_task.n = partition_size;
		sort_task.data = data;
		sort_task.start = r*partition_size;
		
		sort_thread_main( &sort_task );
	}
	
	}
	
	// merge
	{
	int nodes;
	for(nodes = p / 2; nodes > 0; nodes /= 2, partition_size *= 2) {
		
		merge_task_t merge_task;
		
		int r;
		#pragma omp parallel for private(merge_task)
		for(r = 0; r < nodes; r++) {
			merge_task.task_id = r;
			merge_task.n = partition_size;
			merge_task.data = data;
			merge_task.start_left = (2*r) * partition_size;
			merge_task.start_right = (2*r + 1) * partition_size;
		
			int* temp = (int*)malloc( 2*partition_size*sizeof(int) );
		
			merge_task.result = temp;
			
			merge_thread_main( &merge_task );


			memcpy( merge_task.data + merge_task.start_left, merge_task.result, 2*merge_task.n*sizeof(int) );
			free( merge_task.result );
			
			
		}
		
		#pragma omp barrier
		
		
	}
	}
	
	total_time = get_timeofday() - total_time;
	
	printf(TIME_OUTPUT, total_time, p);
	
	// display
	{
	unsigned long i;
	for(i = 0; i < n; i++) {
		printf("%i ", data[i]);
	}
	printf("\n");
	}
}
