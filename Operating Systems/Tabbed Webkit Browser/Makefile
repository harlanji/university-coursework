CC=gcc
CFLAGS=-DDEBUG -g -Wall `pkg-config --cflags gtk+-2.0 webkit-1.0`
LDFLAGS+=`pkg-config --libs gtk+-2.0 webkit-1.0`
LIB32=/soft/webkit/1.1.15.4/jaunty32/lib
LIB64=/soft/webkit/1.1.15.4/jaunty64/lib
SOURCES=wrapper.c wrapper.h browser.c browser.h controller.c router.c urlrenderer.c comm_channel.c browser_window.c

LBITS := $(shell getconf LONG_BIT)
ifeq ($(LBITS),64)
	LIB=${LIB64}
else
	LIB=${LIB32}
endif

all: multi-pro-web-browser bookmarks


bookmarks:
	touch bookmarks
	chmod 600 bookmarks

multi-pro-web-browser: browser.o wrapper.o controller.o urlrenderer.o router.o comm_channel.o browser_window.o
	$(CC) -L ${LIB} $(CFLAGS) $(LDFLAGS) -o $@ $^

browser.o:	browser.h wrapper.h wrapper.c
	$(CC) $(CFLAGS) -c -o $@ browser.c

wrapper.o:	browser.h wrapper.h wrapper.c
	$(CC) $(CFLAGS) -c -o $@ wrapper.c

controller.o:	browser.h wrapper.h controller.c
	$(CC) $(CFLAGS) -c -o $@ controller.c

router.o:	browser.h wrapper.h router.c
	$(CC) $(CFLAGS) -c -o $@ router.c

urlrenderer.o:	browser.h wrapper.h urlrenderer.c
	$(CC) $(CFLAGS) -c -o $@ urlrenderer.c

comm_channel.o:	browser.h wrapper.h comm_channel.c
	$(CC) $(CFLAGS) -c -o $@ comm_channel.c

browser_window.o:	browser.h wrapper.h browser_window.c 
	$(CC) $(CFLAGS) -c -o $@ browser_window.c 



clean:
	rm -rf *.o multi-pro-web-browser bookmarks

