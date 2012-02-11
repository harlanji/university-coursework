#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

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
	
	read_data(argv[1], &data, &n);
	
	unsigned long partition_size = n / p;
	
	double total_time = get_timeofday();


	// sort
	{
	pthread_t threads[ p ];
	sort_task_t sort_tasks[ p ];
	
	
	int r;
	for(r = 0; r < p; r++) {
		
			sort_tasks[r].task_id = r;
			sort_tasks[r].n = partition_size;
			sort_tasks[r].data = data;
			sort_tasks[r].start = r*partition_size;
		
			pthread_create( &threads[r], NULL, sort_thread_main, &sort_tasks[r] );
		
	}

	for(r = 0; r < p; r++) {
		pthread_join( threads[r], NULL );
	}
	}
	
	// merge
	{
	int nodes;
	for(nodes = p / 2; nodes > 0; nodes /= 2, partition_size *= 2) {
		pthread_t threads[ nodes ];
		merge_task_t merge_tasks[ nodes ];
		
		int r;
		for(r = 0; r < nodes; r++) {
			merge_tasks[r].task_id = r;
			merge_tasks[r].n = partition_size;
			merge_tasks[r].data = data;
			merge_tasks[r].start_left = (2*r) * partition_size;
			merge_tasks[r].start_right = (2*r + 1) * partition_size;
		
			int* temp = (int*)malloc( 2*partition_size*sizeof(int) );
		
			merge_tasks[r].result = temp;
		
			pthread_create( &threads[r], NULL, merge_thread_main, &merge_tasks[r] );
		}
		
		for(r = 0; r < nodes; r++) {
			pthread_join( threads[r], NULL );
			
			memcpy( merge_tasks[r].data + merge_tasks[r].start_left, merge_tasks[r].result, 2*merge_tasks[r].n*sizeof(int) );
			free( merge_tasks[r].result );
		}
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
