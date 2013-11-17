#include "server.h"
#include "queue.h"
#include <string.h>
#include <pthread.h>
#include <stdio.h>

extern rwlock_queue_t cache_queue;
extern server_config_t config;

// return true if the argument = the request filename
int queue_cb(queue_t* q, void* item, void* arg) {
	return strcmp(((cache_entry_t*)item)->filename, (char*) arg) == 0;
}

// Put a file from the disk into the cache.  Synchronization required.
int put_cache(char* filename, char* data, int size) {

	cache_entry_t* entry = (cache_entry_t*)malloc(sizeof(cache_entry_t));
	
	// copy the filename to make sure that we own it.
	entry->filename = (char*)malloc( MAX_REQUEST * sizeof(char) );
	strncpy( entry->filename, filename, MAX_REQUEST );
	
	// do not copy data. the user of cache is responsible for it.
	entry->filedata = data;
	entry->file_size = size;
	
	
	while(queue_write(&cache_queue, entry) == -1) {
		fprintf(stderr, "Cache is full\n" );
		// remove an item from the queue (oldest/LRU)
		cache_entry_t* cached = queue_read(&cache_queue);
		// clean up cache entry.
		free( cached->filedata );
		free( cached->filename );
		free( cached );
	}
	return 0;
}

// Get a file from the cache, store data in buf.  If file isn't there, return -1.  Synchronization required.
int get_cache(char* filename, char** buf) {
	cache_entry_t* entry;


	if((entry = (cache_entry_t*)rwlock_queue_search(&cache_queue, queue_cb, (char*)filename)) != NULL) { 
		*buf = entry->filedata;
		
		//
		// LRU caching happens here.
		//
		if (config.cache_enabled == CACHE_LRU) {
			if (queue_rewrite(&cache_queue, entry) == -1) {
				fprintf(stderr, "File found, failed to requeue.\n");
				return -1;
			}
			fprintf(stderr, "REQUEUE SUCCESSFUL\n");
		}
		return entry->file_size; //no need to check rest of buff
	}

	return -1;
}

