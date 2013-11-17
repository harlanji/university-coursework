#include "browser.h"

static browser_window windows[UNRECLAIMED_TAB_COUNTER];
static int next_tab = 0;

int new_browser_window() {
	if(next_tab >= UNRECLAIMED_TAB_COUNTER) {
		return -1;
	}

	int i = next_tab;
	next_tab++;

	return i;
}

int is_tab_index_valid(int tab_index) {
	// all FDs will be 0 if it is not valid. so we can test any.
	// this is a little ghetto, but it works...
	return get_browser_window(tab_index)->channel.child_to_parent_fd[ PIPE_R ] != 0;
}

browser_window* get_browser_window(int tab_index) {
	return &(windows[tab_index]);
}

void free_browser_window(int tab_index) {
	memset( &(windows[tab_index]), 0, sizeof(browser_window) );
}

