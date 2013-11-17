#include "server.h"
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>


static pthread_mutex_t logmx = PTHREAD_MUTEX_INITIALIZER;
static FILE* log_file;


static void log_shutdown();

// registers log_shutduwn
void log_init() {
	log_file = fopen( "web_server_log", "a" );
	if( log_file == NULL ) {
		// error!
		fprintf( stderr, "Error opening log file :(\n" );
		return;
	}
	
	atexit( log_shutdown );
}

// is called at process shutdown, installed by log_init().
static void log_shutdown() {
	if(log_file != NULL) {
		fclose( log_file );
	}
}

// the public logging function.
void log_message(int thread_id, int request_num, int fd, int cache_hit, const char* request_string, int bytes) {

	pthread_mutex_lock( &logmx );
	
	// [ThreadID#][Request#][fd][Cache HIT/MISS][Request string][bytes/error]
	if( fprintf( log_file,
		"[%d][%d][%d][%d][%s][%d]\n",
		thread_id,
		request_num,
		fd,
		cache_hit,
		request_string,
		bytes ) < 0) {
		
		fprintf( stderr, "error writing to log file\n" );
		
	}
	
	fflush( log_file );
	
	
	if (pthread_mutex_unlock( &logmx ) == -1) {
		fprintf(stderr, "Failed to release logging lock");
	}
}



