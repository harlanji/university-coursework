/**
 * This file has functions related to the parent/child communication struct.
 */

#include "browser.h"
#include <fcntl.h>

static comm_channel channel[UNRECLAIMED_TAB_COUNTER];
static int next_chan = 0;

// Get a comm channel by ID
comm_channel* get_comm_channel(int ccid) {
	return &(channel[ccid]);
}

// return 1 if the channel is valid, 0 otherwise.
int is_comm_channel_valid(int ccid) {

	// all FDs will be 0 if it is not valid. so we can test any.
	return get_comm_channel(ccid)->child_to_parent_fd[0] != 0;
}

// Allocate a comm channel (pipes) and put it in the channel[] array
// this also sets the read channels to non-blocking. 
// 
// NOTE: this keeps track of free channels in a vary naive way, 
// just incrementing next_chan each time. A more legit way of doing
// this would be to loop through the list and check for a free one.
int allocate_comm_channel() {
	if(next_chan >= UNRECLAIMED_TAB_COUNTER) {
		return -1;
	}

	int ccid = next_chan;
	next_chan++;

	comm_channel* chan = get_comm_channel(ccid);

	// create communication pipes for router and controller.
	if(pipe( chan->parent_to_child_fd ) == -1 
		|| pipe( chan->child_to_parent_fd ) == -1) {
	
		//log("Error creating pipe");
		info("Error creating pipe.");
		exit(-1);
	}

	// set the read channels to non-blocking.
	set_nonblocking( chan->child_to_parent_fd[ PIPE_R ] );
	set_nonblocking( chan->parent_to_child_fd[ PIPE_R ] );

	return ccid;
}

// Close the pipes associated with a comm channel and free it in the array.
void free_comm_channel(int ccid) {
	if(!is_comm_channel_valid(ccid)){
		info("comm_channel error: not valid");
	} else{
		log("free_comm_channel");
		comm_channel* chan = get_comm_channel(ccid);
		if((close(chan->child_to_parent_fd[ PIPE_R ])) == -1
				|| (close(chan->child_to_parent_fd[ PIPE_W ])) == -1
				|| (close(chan->parent_to_child_fd[ PIPE_R ])) == -1
				|| (close(chan->parent_to_child_fd[ PIPE_W ])) == -1){
			info("Failed to close pipe channels.");
		}
		
		// use memset as shorthand to clean the channels
		memset(chan, 0, sizeof(comm_channel));
	}
}

// set an FD to non-blocking and handle errors.
void set_nonblocking(int fd) {
	// set read pipe to non-blocking
	int flags = fcntl(fd, F_GETFL, NULL);
	if(flags == -1) {
		// couldn't get flags
		log("set_nonblocking: error getting FD flags");
		info("set_nonblocking: error getting FD flags.");
	}

	if(fcntl(fd, F_SETFL, flags | O_NONBLOCK) == -1) {
		log("set_nonblocking: error adding non-blocking to FD flags");
		info("set_nonblocking: error adding non-blocking to FD flags");
	}
}
