#ifndef _BROWSER_H_
#define _BROWSER_H_

#include "wrapper.h"
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <poll.h>
#include <stdio.h>

// standard C variables
extern int errno;

// helper constants
#define MAX_LEN 1024
#define PIPE_R 0
#define PIPE_W 1

// this is arbitrary.
#define SHM_KEY = 5433;

// log function will be declared if in DEBUG mode, otherwise
// a dummy macro will be defined which expands to nothing. this
// keeps the log calls from being compiled into the binary.
#ifdef DEBUG
void log(char* msg);
#else 
#define log(msg)
#endif


void info(char* msg);

// NOTE: function descriptions are in the files. omitting description here
// to avoid duplication and also because function names are fairly self
// documenting.

// router.c
void router_process();
void router_create_bookmark_shm();
void router_create_controller();
void router_handle_comm();
void router_handle_message(int ccid, child_req_to_parent* msg);
void router_reap_children();

// controller.c
void controller_process(int ccid, int tab_index);

// urlrenderer.c
void urlrenderer_process(int ccid, int tab_index);
void urlrenderer_handle_comm(browser_window* b_window);

// comm_channel.c
int allocate_comm_channel();
comm_channel* get_comm_channel(int ccid);
void free_comm_channel(int ccid);
int is_comm_channel_valid(int ccid);
void set_nonblocking(int fd);

// browser_window.c
int new_browser_window();
browser_window* get_browser_window(int tab_index);
void free_browser_window(int tab_index);
int is_tab_index_valid(int tab_index);

#endif
