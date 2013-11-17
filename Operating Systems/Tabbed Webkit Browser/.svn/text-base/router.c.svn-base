#include "browser.h"
#include <sys/shm.h>

int shared_bookmarks;


// the main process for the ROUTER
void router_process() {
	info("router_process");

	router_create_bookmark_shm();

	router_create_controller();

	while(1) {
		router_handle_comm();		

		router_reap_children();
	}
}

// create the shared memory segment that will be used by all processes
void router_create_bookmark_shm() {
	key_t ipckey = ftok("bookmarks", 1);
	if(ipckey == -1) {
		info("Failure obtaining IPC key for bookmarks.");
		exit(-1);
	}

	// get the segment; create if needed.
	shared_bookmarks = shmget( ipckey, MAX_BOOKMARKS * sizeof(bookmarks), 0600 | IPC_CREAT );

	// could not create = fatal error.
	if(shared_bookmarks == -1) {
		info("Error getting shared memory segment for bookmarks.");
		exit(-1);
	}
	

}

// fork out the controller process and update the browser_window for it.
void router_create_controller() {


	// create a comm channel for the controller
	int ccid = allocate_comm_channel();
	if(ccid == -1) {
		info("No more comm channels can be allocated.");
		exit(-1);
	}

	// create a tab index for the controller
	int tab_index = new_browser_window();
	if(tab_index == -1) {
		info("Tab count has hit maximum.");
	}	



	pid_t pid = fork();
	
	if(pid == 0) { // CONTROLLER
		// run the controller process
		controller_process(ccid, tab_index);
		
		exit(0);
	} else if(pid == -1) {
		info("Error creating controller.");
		exit(-1);
	} else {
		// setup the struct the create_browser will setup in the forked
		// process.
		browser_window* b_window = get_browser_window(tab_index);
		b_window->tab_index = tab_index;
		b_window->channel = *get_comm_channel(ccid);
	}
}

// handle communication from child processes. 
void router_handle_comm() {


	// NOTE - not using poll here because of how our comm_channel code is structured.
	//        first, it only makes non-blocking read calls to valid channels which 
	//        would be FDs that populate the pollfd[] array. second, if we used 
	//        poll with an interval it would postpone reaping children which is 
	//        also non-blocking. so it would only make sense to poll with 
	//        an interval=0 if the read FDs were blocking.

	int ccid;
	for(ccid = 0; ccid < UNRECLAIMED_TAB_COUNTER; ccid++) {
		if(!is_comm_channel_valid(ccid)) {
			continue;
		}

		comm_channel* channel = get_comm_channel(ccid);

		// listen for messages. since child_req_to_parent. req is a union
		// we don't know how big it is. so rather than reading a struct 
		// just read the type, and then read the rest when we know what type it is.

		child_req_to_parent msg;
		int bytes_read = read( channel->child_to_parent_fd[PIPE_R], &msg, sizeof(child_req_to_parent) );

		if(bytes_read == -1) {
			if(errno == EAGAIN) {
				// no data. no problem.
			} // others?
		} else {
			router_handle_message(ccid, &msg);
		}	
	}
}

// handle a message from a child. note: error checking was already done
// by router_handle_comm
void router_handle_message(int ccid, child_req_to_parent* msg) {

	log("router_handle_message");

	switch(msg->type) {

		case NEW_URI_ENTERED: { 
			info("A new uri has been entered.");
			if( !is_tab_index_valid(msg->req.uri_req.render_in_tab ) ) {
				log("Invalid tab index.");
				info("An invalid tab index has been specified.  Please try again.");
				return;
			}
			
			// handle special case. NOTE - we could just send it 
			// anyway and let it respond by doing nothing.
			if( msg->req.uri_req.render_in_tab == 0 ) {
				log("Can't send URI to CONTROLLER");
				return;
			}
			
			// repeat the message on to the URL renderer
			browser_window* b_window = get_browser_window( msg->req.uri_req.render_in_tab );

			log(msg->req.uri_req.uri);

			if( write( b_window->channel.parent_to_child_fd[ PIPE_W ], msg, sizeof(child_req_to_parent) ) == -1 ) {
				// error writing message
				log("Error writing NEW_URI_ENTERED message to child.");
				exit(-1);
			}

			break;
		}
	
		case CREATE_TAB: {

			// allocate a comm channel for the new urlrenderer
			int ccid = allocate_comm_channel();
			if(ccid == -1) {
				log("Could not allocate a comm channel. Not creating tab.");
				return;
			}

			// get a tab index for the new urlrenderer
			// NOTE - this is a little confusing because we get a tab_index
			//        from the message... that is the 'tab' that initiated
			//        the request (controller). we actually allocate a new one.

			int tab_index = new_browser_window();
			if(tab_index == -1) {
				info("Tab count has reached maximum. Not creating tab.");
				return;
			}

			pid_t pid = fork();
			if(pid == 0) {
				// run the urlrenderer process
				urlrenderer_process(ccid, tab_index);
				exit(0);
			} else if(pid == -1) {
				// since we haven't updated our structs and stuff we can still
				// safely escape this situation.
				log("Error forking tab process.");
			} else {
				// setup the struct the create_browser will setup in the forked
				// process.
				browser_window* b_window = get_browser_window(tab_index);
				b_window->tab_index = tab_index;
				b_window->channel = *get_comm_channel(ccid);
			}

			break;
		}

		case TAB_KILLED: {
			browser_window* b_window = get_browser_window(msg->req.killed_req.tab_index);
			b_window->tab_index = msg->req.killed_req.tab_index;

			// pass the TAB_KILLED message on to the ROUTER or CONTROLLER
			if( write( b_window->channel.parent_to_child_fd[ PIPE_W ], msg, sizeof(child_req_to_parent) ) == -1 ) {
				// error writing message
				log("Error writing TAB_KILLED message to child.");
				exit(-1);
			}

			// close the pipes and free the browser_window struct.
			free_comm_channel(ccid);
			free_browser_window(msg->req.killed_req.tab_index);
			
			break;	
		}			
	}
}

// reap dead children. end process if errno=ECHILD.
void router_reap_children() {
	// reap dead children
	int stat_val = 0;
	pid_t child_pid = waitpid(-1, &stat_val, WNOHANG);
	if(child_pid == -1) {
		if(errno == ECHILD) {
				// no children.
				
				// if there are no children then terminate router
				log("ECHILD - all children are dead.");
				exit(0);
		} else if(errno == EINTR) {
				// inturrupted. ignore.
		} // EINVAL or unknown?
	} else if(child_pid == 0) {
		// no dead children - called with WNOHANG
		return;
	} else {
		// handle dead child
		log("child died");
		
	}
}


