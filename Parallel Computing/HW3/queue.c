#include "queue.h"
#include <stdio.h>

// =============================================================================
//
//   Queue
//
// =============================================================================

	

static int q_pos(queue_t* q, int i) {
	return (q->capacity + i) % q->capacity;
}
	
// returns -1 on error
int queue_init( queue_t* q, int capacity ) {
	q->capacity = capacity;
	q->head = 0;
	q->tail = 0;
	q->size = 0;
	q->items = (void**)malloc( capacity * sizeof(void*) );

	return q->items == NULL ? -1 : 0;
}

void queue_destroy( queue_t* q ) {
	free( q->items );
}

// returns -1 on error
int queue_enqueue( queue_t* q, void* item ) {
	// calculate the next position
	int new_tail = q_pos(q, q->tail + 1);

	// if the next is the start, then the queue is full. bail with error.
	if( queue_isfull( q ) ) {
		return -1; // queue is full
	}

	// otherwise put the item where the tail pointer is and set the new tail.
	q->items[ q->tail ] = item;
	q->tail = new_tail;
	
	q->size++;
	
	return 0;
}


// put item at the tail of the queue, to make it seem as if it was the first in
// NOTE: item is a value returned from queue_search
int queue_requeue( queue_t* q, void* item ) {

	// loop through all items to ensure that we find item
	// note: less efficient than it could be, but still O(n/2 + n/2) = O(n) average case, O(n^2) worst.
	int i;
	for(i = 0; i < q->size; i++) {
		int pos = q_pos(q, q->head + i);
		
		// we've found it
		if( item == q->items[pos] ) {
			
			// loop from item to the tail item and push them all backwards
			// by one slot, so item can go at the tail.
			int j;
			for(j = i; j < q->size - 1; j++) {
				int from = q_pos(q, q->head + j + 1);
				int to = q_pos(q, q->head + j);
				
				q->items[ to ] = q->items[ from ];
			}

			// enqueue increments tail after an item is inserted, so the
			// current tail is -1.
			int current_tail = q_pos(q, q->tail - 1); 
			q->items[ current_tail ] = item;

			return 0;

		}
	}



	
	// if we got here there must've been an error
	return -1;
}

// return NULL if nothing is there
void* queue_dequeue( queue_t* q ) {
	if( queue_isempty( q ) ) {
		return NULL;
	}

	// calculate the head
	int new_head = q_pos(q, q->head + 1);
//		fprintf(stderr, "<SEG FAULT>\n");
	// remove the item and set the new head
	void* item = q->items[ q->head ];
//		fprintf(stderr, "</SEG FAULT>\n");
	q->head = new_head;	
	q->size--;
	
	return item;
}

void* queue_search( queue_t* q, queue_search_cb cb, void* arg ) {
	if( queue_isempty( q ) ) {
		return NULL;
	}
	
	int i;
	for( i = 0; i < q->capacity; i++ ) {
		int pos = q_pos(q, q->head + i);
		
		void* item = q->items[ pos ];
		if( cb( q, item, arg ) ) {
			return item;
		}
		
		if( pos == q->tail - 1 ) {
			 return (void*)NULL;
		}
		
	}
	
	return NULL;
}

int queue_isempty( queue_t* q ) {
	return q->size == 0;
}

int queue_isfull( queue_t* q ) {
	//int new_tail = (q->tail + 1) % q->capacity;
	
	//return q->head == q->tail;
	
	return q->size == q->capacity;
}


// =============================================================================
//
//   Producer/Consumer
//
// =============================================================================

int prodcon_queue_init( prodcon_queue_t* q, int capacity ) {
	
	q->consume_all = 0;

	if (pthread_cond_init( &q->full_cv, NULL ) == -1) {
		fprintf(stderr, "pthread_cond_init error for full queue condition");
		return -1;
	}
	if (pthread_cond_init( &q->empty_cv, NULL ) == -1) {
		fprintf(stderr, "pthread_cond_init error for empty queue condition");
		return -1;
	}
	if (pthread_mutex_init( &q->mx, NULL ) == -1) {
		fprintf(stderr, "pthread_mutex_init error on queue");
		return -1;
	}
	
	if (queue_init( &q->q, capacity ) == -1) {
		fprintf(stderr, "queue_init error");
		return -1;
	}
	
	return 0;
}

void prodcon_queue_destroy( prodcon_queue_t* q) {
	queue_destroy( &q->q );
	
	if (pthread_mutex_destroy( &q->mx ) == -1) {
		fprintf(stderr, "Failed to destroy prodcon mutex lock");
		return;
	}
	if (pthread_cond_destroy( &q->full_cv ) == -1) {
		fprintf(stderr, "Failed to destroy prodcon full_cv");
		return;
	}
	if (pthread_cond_destroy( &q->empty_cv ) == -1) {
		fprintf(stderr, "Failed to destroy prodcon empty_cv");
		return;
	}
}


// produce item to queue using given CVs and lock

int queue_produce( prodcon_queue_t* q, void* item ) {

	pthread_mutex_lock( &q->mx );
	
	while( queue_isfull(&q->q) ) {

		pthread_cond_wait( &q->empty_cv, &q->mx );

	}

	queue_enqueue( &q->q, item );
	
	pthread_cond_signal( &q->full_cv );
	if (pthread_mutex_unlock( &q->mx ) == -1) {
		fprintf(stderr, "queue_produce - Failed to release lock.");
		return -1;
	}

	return 0;
}

// consume an item from the given queue using given CVs and lock
void* queue_consume( prodcon_queue_t* q ) {
	
	pthread_mutex_lock( &q->mx );
	
	while( queue_isempty(&q->q) ) {
		if( q->consume_all ) {
			return (void*)-1;
		}

		pthread_cond_wait( &q->full_cv, &q->mx );

	}

	void* item = queue_dequeue( &q->q );
	
	pthread_cond_signal( &q->empty_cv );
	if (pthread_mutex_unlock( &q->mx ) == -1) {
		fprintf(stderr, "queue_consume - Failed to release lock.");
		return NULL;
	}
	
	return item;
}

// consume all remaining items and return -1 upon completion. this 
// should trigger consumers to exit.
void queue_consume_all( prodcon_queue_t* q ) {
	pthread_mutex_lock( &q->mx );
	
	q->consume_all = 1;
	
	while( !queue_isempty( &q->q ) ) {
		pthread_cond_broadcast( &q->full_cv );
	}
	
	pthread_mutex_unlock( &q->mx );
}

// =============================================================================
//
//   Read/Write Lock
//
// =============================================================================


int rwlock_queue_init( rwlock_queue_t* q, int capacity ) {
	if (pthread_rwlock_init( &q->rwl, NULL ) == -1) {
		fprintf(stderr, "Failed to initialize RW lock");
		return -1;
	}
	
	if (queue_init( &q->q, capacity ) == -1) {
		fprintf(stderr, "Failed to initialize RW queue");
		return -1;
	}
	
	return 0;
}

void rwlock_queue_destroy( rwlock_queue_t* q ) {
	queue_destroy( &q->q );

	if (pthread_rwlock_destroy( &q->rwl ) == -1) {
		fprintf(stderr, "Failed to destry RW lock");
	}	
}

int queue_write( rwlock_queue_t* q, void* item ) {
	int return_status;
	pthread_rwlock_wrlock( &q->rwl );
	
	return_status = queue_enqueue( &q->q, item );
	
	if (pthread_rwlock_unlock( &q->rwl ) == -1) {
		fprintf(stderr, "queue_write - Failed to release RW lock");
		return -1;
	}
	return return_status;
}

// put item at the tail of the queue, to make it seem as if it was the first in
// NOTE: item is a pointer returned from rwlock_queue_search
int queue_rewrite( rwlock_queue_t* q, void* item ) { 
	int return_status;
	pthread_rwlock_wrlock( &q->rwl );
	
	return_status = queue_requeue( &q->q, item );
	
	if (pthread_rwlock_unlock( &q->rwl ) == -1) {
		fprintf(stderr, "queue_write - Failed to release RW lock");
		return -1;
	}
	return return_status;
}

void* queue_read( rwlock_queue_t* q ) {
	pthread_rwlock_wrlock( &q->rwl );

	void* item = queue_dequeue( &q->q );

	if (pthread_rwlock_unlock( &q->rwl ) == -1) {
		fprintf(stderr, "queue_read - Failed to release RW lock");
		return (void*)-1;
	}
	return item;
}

// return the item or null on failure
void* rwlock_queue_search( rwlock_queue_t* q, queue_search_cb cb, void* arg ) {
	pthread_rwlock_rdlock( &q->rwl );

	void* item = queue_search( &q->q, cb, arg );

	if (pthread_rwlock_unlock( &q->rwl ) == -1) {
		fprintf(stderr, "rwlock_queue_search - Failed to release RW lock");
		return (void*)NULL;
	}

	return item;
}
