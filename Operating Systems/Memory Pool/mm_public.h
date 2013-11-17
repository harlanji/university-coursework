#include <sys/time.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

#define INTERVAL 0
#define INTERVAL_USEC 50000
#define FREE_BLOCK 0

typedef struct {
	char* blocks; // The actual area of memory.
	int total_chunks; // The total number of chunks in the memory area.
	int size; // The size of a chunk.

	char* allocated; // Array to keep track of which chunks have been allocated.
					 // allocated[i] = blocks[i * size]
	int last_allocated; // Which chunk was the last one to be allocated
} mm_t;


// allocate all memory, returns -1 on failure. allocates all memory
// ahead of time.
int  mm_init (mm_t *MM, int hm, int sz);

// get a chunk of memory (pointer to void), NULL on failure
void* mm_get (mm_t *MM);

// give back ‘chunk’ to the memory manager, don’t free it though!
void mm_put (mm_t *MM, void *chunk);

// release all memory back to the system
void  mm_release (mm_t *MM);
double comp_time (struct timeval times, struct timeval timee);

void main_malloc();
void main_mm();	


