#ifndef _SERVER_H_
#define _SERVER_H_


// as defined in util.h
#define MAX_REQUEST 1024

#define MAX_CONTENT_TYPE 100;

#define PREF_QUEUE_SIZE 10
#define PREFETCH_THREADS 10


#define CACHE_NONE 0
#define CACHE_OLDEST 1
#define CACHE_LRU 2

#include <time.h>
#include <pthread.h>


typedef struct request {
	int fd;
	char* filename;
	int req_num;
} request_t;



typedef struct cache_entry {
	char* filename;
	char* filedata;
	int file_size;
	time_t timestamp;
} cache_entry_t;


typedef struct server_config {
	int port;
	char* root;
	int cache_enabled; //cache type... didn't want to change in every instance with the posibility of messing up stuff
	int cache_size;
	int num_dispatch;
	int num_workers;
	int num_pref;
	int qlen;
} server_config_t;

typedef struct server_stats {
	int req_num;
	pthread_mutex_t mx;
} server_stats_t;


void* dispatcher_main (void*);
void* worker_main (void*);
void* pref_main (void*);


// Get contents of file, store it in buf, return size (in bytes) of file.
// buf will be allocated by this function.
int get_file_data(char* filename, char** buf);
	// open the file and fread()? :D

// Put a file from the disk into the cache.  Synchronization required. DONE
int put_cache(char* filename, char* data, int size);

// Get a file from the cache, store name and data in buf.  If file isn't there, return -1.  Synchronization required. ALMOST DONE
int get_cache(char* filename, char** buf);

// Put a file request into the request queue. Synchronization required. DONE
void put_queue(request_t* queue, int fd, char* filename);

// Get a file request from the request queue, store data in pointers.  Synch required. DONE
void get_queue(request_t* queue, int* fd, char* filenamebuf);

// Get the type of the file that we are working with
char* get_content_type(char* filename);
	//fork and exec file -i filename


void log_init();
void log_message(int thread_id, int request_num, int fd, int cache_hit, const char* request_string, int bytes);
void finish();
#endif
