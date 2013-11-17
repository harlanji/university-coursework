#include "util.h"
#include "server.h"

#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BACKLOG 10


struct sockaddr_in addr;
static int listen_fd;

void init(int port) {
	if ((listen_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {  // Create socket
		fprintf(stderr, "Socket creation error.\n");
		exit(-1);
	}
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;  // Any IP address will work
	addr.sin_port = htons(port);  // Set up host-to-network port
	int enable = 1;
	// Make the port reusable sooner rather than later, avoid collisions
	if (setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, (char*)&enable, sizeof(int)) == -1) {
		fprintf(stderr, "setsockopt error.\n");
		exit(-1);
	}
	if (bind(listen_fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {  // Bind fd to address
		fprintf(stderr, "Failed to bind.\n");
		exit(-1);
	}
	listen(listen_fd, BACKLOG);  // Listen for connections with custom backlog
}

int accept_connection(void) {
	// Returns new socket fd
	struct sockaddr client_addr;
	socklen_t addr_len = sizeof(client_addr);

	int accept_fd;
	while( (accept_fd = accept(listen_fd, &client_addr, &addr_len)) == -1 && (errno == EINTR) ) {
		// no problem, just inturrupted. try again.
		fprintf(stderr, "Error accepting.\n" );
	}

	return accept_fd;
}


int get_request(int fd, char *filename) {
	// Read request from socket, return URL name or error (badly formed request)


	// TODO is there anything we have to to to get rid of a FILE* gotten 
	// with fdopen? we don't close here.
	FILE* sock = fdopen( fd, "r" );

	if( sock == NULL ) {
		fprintf(stderr, "Error opening socket.");
		return -1;
	}

	// copy the request string
	char request_buf[MAX_REQUEST];
	if( fgets( request_buf, sizeof(request_buf), sock ) == NULL ) {
		fprintf(stderr, "Error reading request from socket.");
		return -1;
	}

	char* saveptr = NULL;
	char* method = strtok_r( request_buf, " ", &saveptr );
	char* req_filename = strtok_r( NULL, " ", &saveptr );
	char* version = strtok_r( NULL, " ", &saveptr );

	if( strncmp( method, "GET", 3 ) != 0 ) {
		fprintf(stderr, "ERROR: Invalid method.");
		return -1;
	}

	// this could also be the effect of a request filename being too long.
	if( strncmp( version, "HTTP/1.0", 8 ) != 0 && strncmp( version, "HTTP/1.1", 8 ) != 0 ) {
		fprintf(stderr, "ERROR: Invalid protocol version.");
		return -1;
	}

	if( strstr( req_filename, ".." ) != NULL || strstr( req_filename, "//" ) != NULL ) {
		fprintf(stderr, "ERROR: illegal character sequence.");
		return -1;
	}

	// we're good to go
	strncpy( filename, req_filename, MAX_REQUEST );

	return 0;
}

int return_result(int fd, char *content_type, char *buf, int numbytes) {
	// Write header, content type, content to client

	FILE* sock = fdopen( fd, "w" );

	if( sock == NULL ) {
		fprintf(stderr, "Error opening socket.");
		return -1;
	}

	if( fprintf( sock, 
		"HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: Close\r\n\r\n", 
		content_type,
		numbytes) < 0) {

		fprintf(stderr, "Error writing response header.");
		return -1;

	}

	// write as an array in case of binary data.
	if( fwrite( buf, 1, numbytes, sock ) != numbytes ) {
		fprintf(stderr, "Error writing response body.");
		return -1;
	}

	fclose( sock );
	close( fd );
	return 0;
}

int return_error(int fd, char *buf) {
	// Called when there's a problem opening the file thet the URL refers to
	// Write header + msg to stderr

	FILE* sock = fdopen( fd, "w" );

	fprintf( sock, 
		"HTTP/1.1 404 Not Found\r\nContent-Type: text/html\r\nContent-Length: %d\r\nConnection: Close\r\n\r\n%s", 
		(int)strnlen(buf, MAX_REQUEST),
		buf);


	fclose( sock );
	close( fd );
	return 0;
}

int nextguess(char *filename, char *guessed) {
	// dummy function
	return -1;
}
