#include "browser.h"
#include <sys/shm.h>


/*
 * Name:		uri_entered_cb
 * Input arguments:'entry'-address bar where the url was entered
 *			 'data'-auxiliary data sent along with the event
 * Output arguments:void
 * Function:	When the user hits the enter after entering the url
 *			in the address bar, 'activate' event is generated
 *			for the Widget Entry, for which 'uri_entered_cb'
 *			callback is called. Controller-tab captures this event
 *			and sends the browsing request to the router(/parent)
 *			process.
 */

void uri_entered_cb(GtkWidget* entry, gpointer data) {
	log("uri_entered_cb");
	if(!data)
		return;
	browser_window* b_window = (browser_window*)data;
	comm_channel channel = b_window->channel;
    
	// Get the tab index where the URL is to be rendered
	int tab_index = query_tab_id_for_request(entry, data);

	// NOTE: error checking is done in the ROUTER because the CONTROLLER 
	// process does not have a list of valid tab_index's.

	// Get the URL.
	char* uri = get_entered_uri(entry);

	// Prepare 'request' packet to send to router (/parent) process.
	// Append your code here

	child_req_to_parent msg = {
		.type = NEW_URI_ENTERED,
		.req = {
			.uri_req = {
				//.uri = copied below
				.render_in_tab = tab_index
			}
		}
	};
	
	// copy URL to msg struct, avoid buffer overflow that strcpy could introduce
	memcpy(msg.req.uri_req.uri, uri, sizeof(msg.req.uri_req.uri));
	
	// write the struct to memory.
	int fd = channel.child_to_parent_fd[ PIPE_W ];
	if( write( fd, &msg, sizeof(msg) ) == -1 ) {
		// error writing
		//log("Error writing NEW_URI_ENTERED message");
		info("Error writing NEW_URI_ENTERED message.");
		exit(-1);
	}
}





/*

 * Name:		new_tab_created_cb
 * Input arguments:	'button' - whose click generated this callback
 *			'data' - auxillary data passed along for handling
 *			this event.
 * Output arguments:    void
 * Function:		This is the callback function for the 'create_new_tab'
 *			event which is generated when the user clicks the '+'
 *			button in the controller-tab. The controller-tab
 *			redirects the request to the parent (/router) process
 *			which then creates a new child process for creating
 *			and managing this new tab.
 */ 
void new_tab_created_cb(GtkButton *button, gpointer data) {
	//log("new_tab_created_cb");
	if(!data)
		return;
 	int tab_index = ((browser_window*)data)->tab_index;
	comm_channel channel = ((browser_window*)data)->channel;

	// Create a new request of type CREATE_TAB

	child_req_to_parent msg = {
		.type = CREATE_TAB,
		.req = {
			.new_tab_req = {
				.tab_index = tab_index
			}
		}
	};

	// write the struct to memory.
	int fd = channel.child_to_parent_fd[ PIPE_W ];
	if( write( fd, &msg, sizeof(msg) ) == -1 ) {
		// error writing
		//log("Error writing CREATE_TAB message.");
		info("Error writing CREATE_TAB message.");
	}

}


/*
 * Name:                bookmark_curr_page_cb
 * Input Arguments:     data - pointer to 'browser_window' data
 *                      which got initialized after call to 'create_window'
 * Output arguments:    void
 * Function:            The callback is called when the user-clicks the
 *                      bookmark menu in the URL-RENDERING window. The function
 *                      extracts the list of bookmarked web-pages from the
 *                      shared memory and appends the current webpage
 *                      into the list.
 */

void bookmark_curr_page_cb(void *data) {

	browser_window* b_window = (browser_window*)data;
	const char* curr_webpage = get_current_uri(b_window);

	// open shared memory
	bookmarks* bookmarks_shm = shmat(shared_bookmarks, NULL, 0600);

	// add a bookmark if we have space
	int bookmark_num = bookmarks_shm[0].bookmarks_count;
	if(bookmark_num < MAX_BOOKMARKS) {

		// copy string to bookmark struct
		char* bookmark_str = bookmarks_shm[ bookmark_num ].uri;
		memcpy(bookmark_str, curr_webpage, strlen(curr_webpage));

		// increment count
		bookmarks_shm[0].bookmarks_count++;

	} else {
		log("too many bookmarks. not bookmarking.");
		info("Too many bookmarks have been saved!");
	}

	// close shared memory segment.
	shmdt(bookmarks_shm);
}



void controller_process(int ccid, int tab_index) {
	info("controller_process");
	comm_channel* channel = get_comm_channel(ccid);
	browser_window* b_window = get_browser_window( tab_index );


	int ret = create_browser( CONTROLLER_TAB, 
								tab_index, 
								G_CALLBACK(new_tab_created_cb), 
								G_CALLBACK(uri_entered_cb), 
								&b_window, 
								*channel );
	info("New tab created.");
	

	show_browser();

}


