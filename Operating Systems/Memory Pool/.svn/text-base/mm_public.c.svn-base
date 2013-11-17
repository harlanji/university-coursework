#include "mm_public.h"

/* Return usec */
double comp_time (struct timeval times, struct timeval timee)
{

  double elap = 0.0;

  if (timee.tv_sec > times.tv_sec) {
    elap += (((double)(timee.tv_sec - times.tv_sec -1))*1000000.0);
    elap += timee.tv_usec + (1000000-times.tv_usec);
  }
  else {
    elap = timee.tv_usec - times.tv_usec;
  }
  return ((unsigned long)(elap));

}

/* Create the memory manager.  Actual block array is of length hm*sz. */
int  mm_init (mm_t *MM, int hm, int sz) {
	if ((MM->blocks = malloc(hm * sz)) == -1) {
		fprintf(stderr, "Failed to allocate memory.");
		return -1;
	}
	MM->total_chunks = hm;
	MM->size = sz;
	
	/* Create array of length hm to keep track of which chunks have been allocated. */
	if((MM->allocated = (char*)malloc(hm)) == -1 ) {
		fprintf(stderr, "Failed to allocate array to keep track of allocated memory.");
		free(MM->blocks);

		return -1;
	}

	memset(MM->allocated, 0, hm);
	MM->last_allocated = -1;  // No chunks have been allocated yet.

	printf("%i chunks of %i bytes have been allocated.\n", hm, sz);
	return 1;
}

/* Allocate a chunk of memory.  Returns a pointer to the chunk. */
void* mm_get (mm_t *MM) {
	//printf("mm_get\n");

	void* chunk;
	int length = MM->total_chunks;
	// start looking for slots at the last allocated location, or 0 if
	// it is not initialized.
	int base = MM->last_allocated + 1;
	
	int i;
	for (i = 0; i < length; i++) {
		// wrap around to the beginning if we hit the end.
		int slot = (base + i) % length;
		//printf("Checking slot %d\n", slot);
	
		if (MM->allocated[ slot ] == FREE_BLOCK) {
		
			MM->allocated[ slot ] = 1;
			MM->last_allocated = slot;
			
			chunk = MM->blocks + slot * MM->size;
			return chunk;
		}
	}

	fprintf(stderr, "No more memory chunks are available!");
	return -1;


}

/* Return a chunk to the memory manager. */
void mm_put (mm_t *MM, void *chunk) {
	int i;
	int index = ((unsigned int)chunk - (unsigned int)MM->blocks) / MM->size;
	MM->allocated[index] = 0;
	
	// this will help performance for spacially local sequential allocate/deallocate
	// usage profiles.
	// MM->last_allocated = index - 1;

	memset(chunk, FREE_BLOCK, MM->size);
	
}

/* Free the memory manager. */
void  mm_release (mm_t *MM) {
	free(MM->blocks);
	free(MM->allocated);

	memset(MM, 0, sizeof(mm_t));
}


void timer_example ()
{
    struct timeval time_start, time_end;
    int j;

    /* start timer */
    j = gettimeofday (&time_start, (void *)NULL);

    int i;
	for (i = 0; i < 10; i++){
		printf("%i ", i);
	}
    j = gettimeofday (&time_end, (void *)NULL);

    fprintf (stderr, "Time taken =  %f msec\n",
	     comp_time (time_start, time_end)/1000.0);
}






