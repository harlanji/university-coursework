CFLAGS = -D_REENTRANT -g -Wall -DDEBUG
LDFLAGS = -lpthread

COMPILED_OBJS = server.o cache.o queue.o log.o util.o

all: web_server_http
test: queue_test
	./queue_test

web_server_http: $(COMPILED_OBJS)
	${CC} ${LDFLAGS} -o $@ $+
	
queue_test: queue_test.c queue.o
	${CC} ${CFLAGS} ${LDFLAGS} -o $@ $+

%.o: %.c util.h server.h queue.h
	${CC} ${CFLAGS} -c -o $@ $<

clean:
	rm -f $(COMPILED_OBJS) queue_test web_server_http

run-server:	web_server_http
	./web_server_http 9001 ./testing 10 10 3 2 3
	
debug-server:	web_server_http
	gdb --args ./web_server_http 9002 ./testing 10 10 3 2 3 
