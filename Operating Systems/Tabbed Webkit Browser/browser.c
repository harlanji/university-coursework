/* CSci4061 S2010 Assignment 2
* section: 5
* login: marsh413
* date: 03/12/10
* name: Philip Babcock, Harlan Iverson, Ben Marshall
* id:   3334517         3476594         3567208 */

#include "browser.h"


#ifdef DEBUG

void log(char* msg) {
	pid_t pid = getpid();


	fprintf(stderr, "Log [%d]: %s.\n", pid, msg);
}

#endif

void info(char *msg) {
	pid_t pid = getpid();
	fprintf(stderr, "INFO [Process %d]: %s\n", pid, msg);
}

int main() {

	router_process();

	return 0;
}





