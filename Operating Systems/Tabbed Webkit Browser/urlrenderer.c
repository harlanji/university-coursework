/**
 * This file has functions related to the URL-RENDERER process.
 */
 
 
 #include "browser.h"



// This is the 'main' procedure for the URL-RENDERER process. It is executed
// just after the ROUTER forks it out in response to the CREATE_TAB message.
void urlrenderer_process(int ccid, int tab_index) {
	info("urlrenderer_process");

	// get the comm_channel and b_window associated with the tab.
	comm_channel* channel = get_comm_channel(ccid);
	browser_window* b_window = get_browser_window( tab_index );


	// create the tab using info from above. no callbacks on the URL-RENDERER 
	// tab.
	int ret = create_browser( URL_RENDERING_TAB, 
								tab_index, 
								G_CALLBACK(NULL), 
								G_CALLBACK(NULL), 
								&b_window, 
								*channel );


	// the URL-RENDERER event loop. both of these calls are non-blocking.
	while(1) {
		// handle communication from the ROUTER if there is any
		urlrenderer_handle_comm(b_window);

		// handle GTK events.
		process_single_gtk_event();
	}
}

// handle communication from the ROUTER to the URL-RENDERER
void urlrenderer_handle_comm(browser_window* b_window) {

	// read a message from the comm_channel
	child_req_to_parent msg;

	int fd = b_window->channel.parent_to_child_fd[ PIPE_R ];
	int bytes_read = read( fd, &msg, sizeof(child_req_to_parent) );

	// if there was a read 'error' it may just be that there was no data
	// since the FD is non-blocking.
	if( bytes_read == -1 ) {
		if(errno == EAGAIN) {
			// no data. no problem.
		} else {
			info("urlrenderer: A read error has occurred.");
		}
	// we got some data. handle it.
	} else {
		log("urlrenderer_handle_comm: got message");
		if(msg.type == NEW_URI_ENTERED) {
			log("NEW_URI_ENTERED");
			log(msg.req.uri_req.uri);
			// render the URI in the browser
			render_web_page_in_tab( msg.req.uri_req.uri, b_window );
		}
		else if (msg.type == TAB_KILLED) {
			log("TAB_KILLED");
			// handle all remaining GTK events and exit with normal status
			process_all_gtk_events();
			exit(0);
		}
		else {
			info("urlrenderer: An invalid message has been received.");
		}
	}

}
