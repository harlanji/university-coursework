#include "queue.h"
#include <stdio.h>
#include <string.h>

int queue_search_test_cb(queue_t* q, void* item, void* arg) {
	return strcmp((char*)item, (char*) arg) == 0; 
}


void test_search() {
	queue_t q;

	queue_init( &q, 5 );

	char* res = (char*)queue_search( &q, queue_search_test_cb, "one" );
	if( res != NULL ) {
		fprintf( stderr, "queue_search failed 1\n" );
	}

	queue_enqueue( &q, "one" );

	res = (char*)queue_search( &q, queue_search_test_cb, "one" );
	if( res == NULL ) {
		fprintf( stderr, "queue_search failed 2\n" );
	}

	queue_dequeue( &q );

	res = (char*)queue_search( &q, queue_search_test_cb, "one" );
	if( res != NULL ) {
		fprintf( stderr, "queue_search failed 3\n" );
	}

	queue_destroy( &q );	
	
	printf("test_search done\n");
}

void test_queue() {
	queue_t q;
	int values[] = { 1, 2, 3, 4, 5 };
	
	queue_init( &q, 5 );
	
	if( q.capacity != 5 
		|| q.size != 0
		|| q.head != 0
		|| q.tail != 0
		|| q.items == NULL ) {
	
		fprintf( stderr, "queue_init failed\n" );
	}
	
	if( !queue_isempty( &q ) ) {
		fprintf( stderr, "queue_empty failed 1\n" );
	}
	
	queue_enqueue( &q, &values[0] );
	
	if( queue_isempty( &q ) ) {
		fprintf( stderr, "queue_empty failed 2\n" );
	}
	
	queue_enqueue( &q, &values[1] );
	queue_enqueue( &q, &values[2] );
	queue_enqueue( &q, &values[3] );
	
	if( queue_isfull( &q ) ) {
		fprintf( stderr, "queue_full failed 1\n" );
	}
	
	queue_enqueue( &q, &values[4] );
	
	if( !queue_isfull( &q ) ) {
		fprintf( stderr, "queue_full failed 2\n" );
	}

	if( queue_enqueue( &q, &values[4] ) != -1 ) {
		fprintf( stderr, "queue_enqueue failed (inserted into full queue)\n" );
	}
	
	int i;
	for( i = 0; i < 5; i++ ) {
		const int* val = queue_dequeue( &q );
		
		if( *val != values[i] ) {
			fprintf( stderr, "queue_dequeue failed %d\n", i );
		}
	}
	
	if( !queue_isempty( &q ) ) {
		fprintf( stderr, "queue_empty failed 3\n" );
	}
	
	
	
	printf("test_queue done\n");
}

void test_requeue() {
	queue_t rq;
	int values[] = {0, 1, 2, 3, 4};
	queue_init(&rq, 5);

	queue_enqueue(&rq, &values[0]);
	queue_enqueue(&rq, &values[1]);
	queue_enqueue(&rq, &values[2]);
	queue_enqueue(&rq, &values[3]);
	queue_enqueue(&rq, &values[4]);
	
	// queue = 0,1,2,3,4


	// try a middle value
	if (queue_requeue(&rq, &values[3]) == -1) {
		fprintf(stderr, "queue_requeue failed to requeue 1\n");
	}
	
	// queue = 0,1,2,4,3
	if( *(int*)rq.items[0] != 0
		|| *(int*)rq.items[1] != 1
		|| *(int*)rq.items[2] != 2
		|| *(int*)rq.items[3] != 4
		|| *(int*)rq.items[4] != 3 ) {
		
		fprintf(stderr, "requeue fail 1.\n");
	}
	
	// try start value
	if (queue_requeue(&rq, &values[0]) == -1) {
		fprintf(stderr, "queue_requeue failed to requeue 2\n");
	}
	
	// queue = 1,2,4,3,0
	if( *(int*)rq.items[0] != 1
		|| *(int*)rq.items[1] != 2
		|| *(int*)rq.items[2] != 4
		|| *(int*)rq.items[3] != 3
		|| *(int*)rq.items[4] != 0 ) {
		
		fprintf(stderr, "requeue fail 2.\n");
	}
	
	// try end value
	if (queue_requeue(&rq, &values[0]) == -1) {
		fprintf(stderr, "queue_requeue failed to requeue 3\n");
	}
	
	// queue = 1,2,4,3,0 (should remain unchanged)
	if( *(int*)rq.items[0] != 1
		|| *(int*)rq.items[1] != 2
		|| *(int*)rq.items[2] != 4
		|| *(int*)rq.items[3] != 3
		|| *(int*)rq.items[4] != 0 ) {
		
		fprintf(stderr, "requeue fail 3.\n");
	}



	fprintf(stderr, "test_requeue done\n");
}


int main(int argc, char* argv[]) {
	test_queue();
	test_search();
	test_requeue();
	
	return 0;
	
}
