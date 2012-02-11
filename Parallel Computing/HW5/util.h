#ifndef __UTIL_H__
#define __UTIL_H__


#define LOG_NONE 0
#define LOG_DEBUG 1
#define LOG_INFO 2
#define LOG_BENCH 4
#define LOG_TRACE 8
#define LOG_ERROR 16
#define LOG_IO 32

#define LOG_LEVEL LOG_ERROR // | LOG_IO | LOG_INFO

#define LOG(level, s, rest...) if((LOG_LEVEL) & level) { fprintf(stderr, s, ## rest); }
#define LOG_IO_DONE() LOG(LOG_IO, "done.\n")

#define MPI_SEND_MSG "%u -- (size=%llu) --> %i [sending]\n"
#define MPI_RECV_MSG "%u -- (size=%llu) --> %i [receiving]\n"

#define CLEAN_EXIT(status) LOG(LOG_INFO,"CLEAN_EXIT CALLED. EXITING.\n"); MPI_Finalize(); exit(status);

	
	
#define MPI_CALL( stmt ) if( stmt != MPI_SUCCESS ) { LOG(LOG_ERROR, "MPI ERROR: %s:%i\n", __FILE__, __LINE__); CLEAN_EXIT(-1); }
#define CHECK_ALLOC( stmt ) if( (stmt) == NULL ) { LOG(LOG_ERROR, "allocation failed: %s:%i\n", __FILE__, __LINE__); CLEAN_EXIT(-1); }

#endif
