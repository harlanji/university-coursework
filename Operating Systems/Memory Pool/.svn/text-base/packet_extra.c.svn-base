#include "packet_public.h"
#include <time.h>
#include <string.h>
#include <unistd.h>

// note: there is no need for MM to be global -H


//
message_t g_messages[ MAX_MESSAGES ];
mm_t g_MM;

int g_has_more = 1;

int g_sent_packets[ MAX_MESSAGES ][ MaxPackets ];


// this is a black box that simulates network packets arriving.
// it is called from within the alarm handler
packet_t get_packet () {
	static int num_messages = 4; // random number of messages
	static int num_packets = 0; // this is generated per message.

	static int which_msg = 0;
	static int which_pkt = 0;
	static char c = 'a';
	
	packet_t pkt;
	
	// NOTE randomization is possible but time did not permit implementing it.
	//		the code supports arrival in random order. see packet_arrived.

	while( which_msg < num_messages ) {
		// generate how many packets are in this message
		if( num_packets == 0 ) {
			num_packets = 4;
		}
	
		while( which_pkt  < num_packets) {
			pkt.msg_id = which_msg;
			pkt.which = which_pkt;
			pkt.how_many = num_messages;

			memset (pkt.data, c, PACKET_SIZE);
			
			which_pkt++;
			
			c = (c == 'z') ? 'a' : c + 1;
			
			return pkt;
		}
		
		num_packets = 0;
		which_pkt = 0;
		which_msg++;
	}
	
	// lacking a proper way to return errors, use
	// a hack.
	pkt.msg_id = -1;
	
	return pkt;
}




/* Create message from packets ... deallocate packets */
char *assemble_message (message_t* message) {

	int message_len = message->num_packets * PACKET_SIZE;
	char* MSG = (char*)malloc( message_len + 1 );
	int i;
	for(i = 0; i < message->num_packets; i++) {
		memcpy( MSG + i * PACKET_SIZE, message->data[ i ], PACKET_SIZE );
		mm_put( &g_MM, message->data[i] );
	}

	// add null pointer to the end.
	MSG[ message_len ] = '\0';

	return MSG;
}

// iterates the messages array looking for newly completed 
// packets. outputs GOTIT if how_many == how_many_arrived.
void handle_complete_messages() {
	//mask signals within handler
	void* old_handler = signal(SIGALRM, SIG_IGN); 

	int i;
	for( i = 0; i < MAX_MESSAGES; i++ ) {
		if( g_messages[ i ].id == -1 ) {
			continue;
		}
	
		if( g_messages[ i ].how_many_arrived == g_messages[ i ].num_packets ) {
			char* msg = assemble_message( &g_messages[ i ] );
			
			printf( "GOT IT: msg_id=%d, message=%s\n", g_messages[ i ].id, msg );
			
			free( msg );
			
			// clear it so we don't handle it again.
			g_messages[ i ].id = -1;
		}
	}
	
	//unmask signal
	signal(SIGALRM, old_handler);
}

void packet_handler(int sig)
{
	//mask signals within handler
	void* old_handler = signal(sig, SIG_IGN); 

  	//fprintf (stderr, "IN PACKET HANDLER, sig=%d\n", sig); 

  	// get the next waiting packet
 	packet_t pkt = get_packet();
 	
 	// this is the trigger to stop, since get_packet returns void.
 	if(pkt.msg_id == -1) {
 		g_has_more = 0;
 	}
 	
 	// set fields of message
 	g_messages[ pkt.msg_id ].id = pkt.msg_id;
 	g_messages[ pkt.msg_id ].num_packets = pkt.how_many;
 	
 	g_messages[ pkt.msg_id ].how_many_arrived++;
 	
	// create a chunk of memory and copy packet data there.
	void* memory = mm_get(&g_MM);
	memcpy(memory, pkt.data, PACKET_SIZE); // Not sure of syntax here...
	
	// add the new data chunk to the message struct
	g_messages[ pkt.msg_id ].data[ pkt.which ] = memory;

	//unmask signal
	signal(sig, old_handler);
}


int main (int argc, char **argv)
{
	// init all messages to id = -1 so that we don't try to handle them.
	int i;
	for( i = 0; i < MAX_MESSAGES; i++ ) {
		g_messages[ i ].id = -1;
	}

	if(mm_init (&g_MM, 100, 64) == -1){
		fprintf(stderr, "failed to initialize mm for packets");
	}

  /* set up alarm handler -- mask all signals within it */
	void* old_handler = signal(SIGALRM, packet_handler);




  /* turn on alarm timer ... use  INTERVAL and INTERVAL_USEC for sec and usec values */
	struct itimerval itv;
	itv.it_interval.tv_sec = INTERVAL;
	itv.it_interval.tv_usec = INTERVAL_USEC;
	itv.it_value.tv_sec = 0;
	itv.it_value.tv_usec = 100;
	
	setitimer( ITIMER_REAL, &itv, NULL );
	
	while( g_has_more ) {
		handle_complete_messages();
		
		pause();
	}
	
	
    // stop handler
    itv.it_interval.tv_sec = itv.it_interval.tv_usec = 0;
    setitimer( ITIMER_REAL, &itv, NULL );
	signal(SIGALRM, old_handler); 



  /* Deallocate memory manager */
	mm_release(&g_MM);
	
	return 0;
}


