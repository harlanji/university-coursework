#include "util.h"
#include "queue.h"
#include "server.h"
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <string.h>
#include <signal.h>



static pthread_t* pref_threads;
static pthread_t* dispatch_threads;
static pthread_t* worker_threads;
	
static prodcon_queue_t request_queue;
static prodcon_queue_t prefetch_queue;

// rather than time-based caching use the queue property to remove an item
// if the queue is full.
rwlock_queue_t cache_queue;

server_config_t config;

server_stats_t stats = {
	req_num: 0, 
	mx: PTHREAD_MUTEX_INITIALIZER
};


void force_quit_server_handler(int sig) {
	
	finish();

}



int server_stats_incr_req_num(server_stats_t* stats) {
	pthread_mutex_lock( &stats->mx );
	
	int req_num = ++stats->req_num;
	
	if (pthread_mutex_unlock( &stats->mx ) == -1) {
		fprintf(stderr, "Failed to release server stat lock.");
		return -1;
	}
	
	return req_num;
}


int main (int argc, char* argv[]) {

	if (argc != 8) {
		fprintf(stderr, "Usage: %s port path num_dispatch num_workers qlen caching cache-entries\n", argv[0]);
		return -1;
	}
	config.port = atoi(argv[1]);
	config.root =  argv[2];
	config.num_dispatch = atoi(argv[3]);
	config.num_workers = atoi(argv[4]);
	config.qlen = atoi(argv[5]);
	config.cache_enabled = atoi(argv[6]);
	config.cache_size = atoi(argv[7]);
	
	config.num_pref = 1;


	
	log_init();
	init( config.port );
	chdir( config.root );

	//Setting up force quit
	struct sigaction alarmAction;
	alarmAction.sa_handler = force_quit_server_handler;
	alarmAction.sa_flags = 0;
	sigemptyset(&alarmAction.sa_mask);
	sigaction(SIGINT, &alarmAction, NULL);


	if (prodcon_queue_init( &request_queue, config.qlen ) == -1) {
		fprintf(stderr, "Failed to initialize request queue.\n");
		return -1;
	}
	
	// only enable the prefetch_queue and cache_queue if caching is enabled.
	if( config.cache_enabled ) {
		if (prodcon_queue_init( &prefetch_queue, PREF_QUEUE_SIZE ) == -1) {
			fprintf(stderr, "Failed to initialize prefetcher queue.\n");
			return -1;
		}
		if (rwlock_queue_init( &cache_queue, config.cache_size ) == -1) {
			fprintf(stderr, "Failed to initialize cache.\n");
			return -1;
		}
	}
	
	int thread_id = 0;
	int* arg = NULL;

	// Create worker and dispatcher threads, pass corresponding methods into pthread_create.
	int i;
	
	dispatch_threads = (pthread_t*)malloc( config.num_dispatch * sizeof(pthread_t) );
	for (i = 0; i < config.num_dispatch; i++) {
		arg = malloc( sizeof(int) );
		*arg = thread_id++;
		
		if (pthread_create(&dispatch_threads[i], NULL, dispatcher_main, arg) == -1) {
			fprintf(stderr, "Failed to create dispatcher thread at index %d.\n", i);
			return -1;
		}
		
		if (pthread_detach( dispatch_threads[i] ) == -1) {
			fprintf(stderr, "Failed to detach dispatcher thread %d\n", i);
			return -1;
		}
	}
	
	worker_threads = (pthread_t*)malloc( config.num_workers * sizeof(pthread_t) );
	for (i = 0; i < config.num_workers; i++) {
		arg = malloc( sizeof(int) );
		*arg = thread_id++;
	
		if (pthread_create(&worker_threads[i], NULL, worker_main, arg) == -1) {
			fprintf(stderr, "Failed to create worker thread at index %d.\n", i);
			return -1;
		}
		
		if (pthread_detach( worker_threads[i] ) == -1) {
			fprintf(stderr, "Failed to detach worker thread %d\n", i);
			return -1;
		}
	}

	// Create prefetcher threads.
	if( config.cache_enabled ) {
	
		pref_threads = (pthread_t*)malloc( config.num_pref * sizeof(pthread_t) );
		for (i = 0; i < PREFETCH_THREADS; i++) {
			arg = malloc( sizeof(int) );
			*arg = thread_id++;
	
			if (pthread_create(&pref_threads[i], NULL, pref_main, arg) == -1) {
				fprintf(stderr, "Failed to create prefetcher thread at index %d.\n", i);
				return -1;
			}
			
			if (pthread_detach( pref_threads[i] ) == -1) {
				fprintf(stderr, "Failed to detach prefetcher thread %d\n", i);
				return -1;
			}
		}
	}
	
	while(1) {
		pause();
	}

	return 0;
}

void* dispatcher_main (void* arg) {
	int thread_id = *((int*)arg);
	free(arg);

	while (1) {

		printf("Waiting...\n");

		char* name = (char*)malloc( MAX_REQUEST ); // Buffer for filename
		int fd;
		if ((fd = accept_connection()) < 0) {
			fprintf(stderr, "Connection failure.\n");
			pthread_exit((void*)NULL);
		}
		
		printf("Got connection!\n");
		
		if( get_request(fd, name) != 0) {
			// request error!
			fprintf( stderr, "get_request failed\n");
			
			continue;
		}
		
		// create a request object. this is free'd in prefetch if caching is enabled
		// or worker if not.
		request_t* req = (request_t*)malloc( sizeof(request_t) );
		req->fd = fd;
		req->filename = name;
		req->req_num = server_stats_incr_req_num( &stats );
		
		printf( "Dispatcher: putting request in queue\n" );

		if (queue_produce( &request_queue, req ) == -1) {
			fprintf(stderr, "Dispatcher: error placing request in queue.\n");
		}
	}
}




void* worker_main (void* arg) {
	int thread_id = *((int*)arg);
	free(arg);

	while (1) {
		void* item = queue_consume( &request_queue );
		
		// this happens only if queue_consume_all() was called and no items remain.
		if( item == (void*)-1 ) {
			printf( "Worker exiting.\n" );
			pthread_exit( (void*)NULL );
		}
		
		request_t* req = (request_t*)item;
		char* buf = NULL;
		
		// if cache is enabled then try to get the cached entry.
		int size = config.cache_enabled ? get_cache( req->filename, &buf ) : -1;
		int cache_hit = (size != -1);
		
		// if it wasn't a hit, try to get the data from file.
		if( !cache_hit ) {
			size = get_file_data( req->filename, &buf );
			
			if( size == -1 ) {
				// file does not exist. send result and move on.
				log_message( thread_id, req->req_num, req->fd, cache_hit, req->filename, 404);
				return_error( req->fd, "404 - File not found" );
				
				continue;
			} 
			
			// if cache is enabled then put the value into the cache.
			if( config.cache_enabled ) {
				if( put_cache( req->filename, buf, size ) == -1 ) {
					// error. I think we can keep going?
					fprintf( stderr, "error putting into cache %s\n", req->filename );
					
					// do not escape. this is not a fatal error, so continue sending
					// request to client.
				}
			}
		} 
		
		char* content_type = get_content_type( req->filename );


		// send result and log.
		log_message(thread_id, req->req_num, req->fd, cache_hit, req->filename, size);
		if (return_result( req->fd, content_type, buf, size ) != 0) {
			fprintf(stderr, "Error returning request to client.");
		}

		// only put stuff into prefetch if cache is enabled. otherwise just free the request.
		if( config.cache_enabled ) {
			if( queue_produce( &prefetch_queue, req ) == -1 ) {
				fprintf( stderr, "Error putting request into prefetch queue '%s'\n", req->filename );
			}
		} else {
			// free request created by dispatch.
			free( req->filename );
			free( req );
			
			// free the buffer.
			free( buf );
		}
	}

}

void* pref_main (void* arg) {
	int thread_id = *((int*)arg);
	free(arg);
	while (1) {
		char guess[MAX_REQUEST]; // Buffer for guessed filename
		int size = 0;

		void* item = queue_consume( &prefetch_queue );
		
		// this happens only if queue_consume_all() was called and no items remain.
		if( item == (void*)-1 ) {
			printf( "Prefetcher exiting.\n" );
			pthread_exit( (void*)NULL );
		}
		
		request_t* req = (request_t*)item;

		if (nextguess(req->filename, guess) != 0) { 
			fprintf(stderr, "Prefetcher failed to get next guess\n");
			fprintf(stderr, " --filename: %s\n", req->filename );
			fprintf(stderr, " --guess: %s\n", guess );
		} else {
			// try to get the cache entry for the guess. if it isn't there
			// then put it there.
			char* data;
			if (get_cache(guess, &data) == -1) {
				size = get_file_data(guess, &data);
				put_cache(guess, data, size);
			}
		}

		// free request created by dispatch.
		free( req->filename );
		free( req );
			
	}

}


char* get_content_type(char* filename){
	// just do a switch on end of filename (according to assignment)
	//fprintf(stderr, "calling ext...\n");
	char* ext = strrchr(filename, '.');
	//fprintf(stderr, "ext = %s\n", ext);
	if (ext == NULL) {
		return "text/plain";
	}
	else if (strcmp(ext, ".html") == 0) {
		return "text/html";
	}
	else if (strcmp(ext, ".jpg") == 0) {
		return "image/jpeg";
	}
	else if (strcmp(ext, ".gif") == 0) {
		return "image/gif";
	}
	else {
		return "text/plain";
	}
}

int get_file_data(char* filename, char** buf) {
	FILE *f;

	//(filename + 1); // moves pointer just beyond starting /
	//    /images/ => images/

	if ((f = fopen((filename +1),"r")) == NULL) {
		fprintf(stderr, "get_file_data error.\n%s\n", filename);
		return -1;
	}
	struct stat filestat;
	if (fstat(fileno(f), &filestat) == -1) {
		fprintf(stderr, "fstat error.\n%s", filename);
		return -1;
	}
	size_t size = filestat.st_size;
	*buf = (char*) malloc(size);
	
	if( fread(*buf, size, 1, f) == -1 ) {
		fprintf(stderr, "fread error.\n%s", filename);
		return -1;
	}
	fclose(f);

	return (int)size;
}

void finish() {
	sigset_t masknew, maskold;	
	sigprocmask(SIG_SETMASK, NULL, &masknew);
	sigaddset(&masknew, SIGINT);
	sigprocmask(SIG_SETMASK, &masknew, &maskold);
	

	
	if( config.cache_enabled ) {
		queue_consume_all( &prefetch_queue );
	}
	
	// consume all remaining items and then queue_consume returns -1 and this
	// causes the treads to end.
	queue_consume_all( &request_queue );


	sigprocmask(SIG_SETMASK, &maskold, NULL);
	fprintf(stderr, "Server terminating...");
	exit(0);
	
}

