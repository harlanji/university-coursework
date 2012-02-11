#ifndef _QUEUE_H_
#define _QUEUE_H_

#include <pthread.h>
#include <stdlib.h>


typedef struct queue {
	int capacity;
	int size;  
	int head;
	int tail;
	
	void** items;
} queue_t;


typedef struct prodcon_queue {
	pthread_cond_t empty_cv;
	pthread_cond_t full_cv;
	pthread_mutex_t mx;
	queue_t q;
	
	int consume_all;
} prodcon_queue_t;  

typedef struct rwlock_queue {
	pthread_rwlock_t rwl;
	queue_t q;
} rwlock_queue_t;

// returns 1 if the item matches, 0 otherwise.
typedef int(*queue_search_cb)(queue_t* q, void* item, void* arg);

// NOTE these are not synchronized. synch happens with queue_produce/consume.
int queue_init( queue_t* q, int capacity );  // create a queue
void queue_destroy( queue_t* q );  // free the queue
int queue_enqueue( queue_t* q, void* item );  // put an item into a queue
void* queue_dequeue( queue_t* q );  // get an item from a queue
int queue_requeue( queue_t* q, void* item );
// search within a queue. normally not a queue operation but that's okay.
// the last argument is passed into the callback along with a reference to the
// queue and a reference to the item.
void* queue_search( queue_t* q, queue_search_cb cb, void* arg );
int queue_isempty( queue_t* q );
int queue_isfull( queue_t* q );

// these are synchronized using pthread CVs and a MX lock.
int prodcon_queue_init( prodcon_queue_t* q, int capacity );
void prodcon_queue_destroy( prodcon_queue_t* q);
int queue_produce( prodcon_queue_t* q, void* item );
void* queue_consume( prodcon_queue_t* q );
void queue_consume_all( prodcon_queue_t* q );
	
// these are synchronized using pthread rwlock
int rwlock_queue_init( rwlock_queue_t* q, int capacity );
void rwlock_queue_destroy( rwlock_queue_t* q );
int queue_write( rwlock_queue_t* q, void* item );
int queue_rewrite( rwlock_queue_t* q, void* item );
void* queue_read( rwlock_queue_t* q );
void* rwlock_queue_search( rwlock_queue_t* q, queue_search_cb cb, void* arg );
	
#endif
