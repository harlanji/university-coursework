/* CSci4061 S2010 Assignment 5
*section: 5
*login: marsh413 
*date: 05/05/10
*name: Philip Babcock, Harlan Iverson, Benjamin Marshall
*id:   3334517         3476594         3567208 
*TESTED ON blender, fax, clock, toaster, computer */

How to run:
To compile, type "make".  To run, type the following:
	./web_server_http <port (1025 or greater recommended)> <path to directory containing test file relative to working directory>
				<number of dispatcher threads><number of worker threads>
				<queue length> <caching (0 for none, 1 for oldest, 2 for LRU)> <number of cache entries>

This program simulates a multithreaded webserver.  There are three types of
threads: dispatcher, worker and prefetcher.  The dispatcher threads accept
requests from the client and place them into a queue.  The worker threads wait
for requests to be put into the queue.  When a request arrives, the worker
threads check a cache (if caching is enabled) for the reqested file.  If the file is not cached, it is
retrieved from the disk, placed into the cache and sent back to the client.
The worker threads also place the file in a prefetch queue if caching is enabled.  When a request is
placed inside this queue, the prefetcher reads it and guesses what the next
requested file will be.  That file is then retrieved from the disk and placed
into the cache (if it's not already there).

We programmed the cache and queues in an object-oriented fashion with built-in
synchronization.  The cache acts as a queue with RW locks and the request and
prefetcher queues use the producer-consumer model.

There are special structs for rwlock and prodcon queues which are synchronized with 
appropriate locks and locking functions which are built around an unsynchronized 
queue data structure--all access to the queue is performed via functions with 
locking so it inherits synchronization.

Shutdown is handled by catching the SIGINT signal and making the worker and prefetch 
consumers handle all remaining items. When they are finished and in a consume_all 
state they will return -1 from queue_consume, which signifies that the 
thread should exit (similar to accept_connection).

UPDATE:  We have manually implemented the networking functionality that was previously
given to us.

Upon starting the program, a socket is created, bound to a user-specified
port, and begins listening for connections.

When a connection comes in, the socket accepts it and sends a file descriptor
representing the accepted connection to a dispatcher thread.

When a dispatcher thread is ready to get a request from the accepted connection, the file descriptor
is opened, and whatever is inside of the file (socket) is checked for proper formatting
(for example, if it has "HTTP" printed at its head).  If everything checks out,
the request is placed into a buffer that is sent back to the dispatcher thread.

When the worker thread has retrieved the requested file information from the cache
or disk, the connection socket (the one that originally represented the accepted conenction)
is re-opened and the header (protocol, content type) and body of the file are placed inside
and sent back to the client, who receives it in its proper form (for example, a
picture instead of html code for a picture).  The connection is then closed, but
the original socket is still listening for conenctions.

If the worker thread is unable to locate the file in the cache or disk, an error
message (404 Not Found) is sent through the connection socket back to the client.

Caching can either be disabled(0), set to and oldest implementation(1), or a LRU
implementation(3). Oldest works as a normal queue, we add to the queue at the tail
and pop from the head. LRU works in a similair fashion, but if there is a hit in
the queue, the item is taken out and replaced at the beginning, shifting everything
down to close the gap of it's previous location. 
