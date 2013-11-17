#include "packet_public.h"
#include <time.h>

// note: there is no need for MM to be global -H
message_t message;     /* current message structure */
mm_t MM;               /* memory manager will allocate memory for packets */
int pkt_cnt = 0;       /* how many packets have arrived for current message */
int pkt_total = 1;     /* how many packets to be received for the message */
int NumMessages = 3;   /* number of messages we will receive */
//int sizeOfMalloc = 0;

/* Idea:
for(i=0; i<pkt_total; i++) {
	sizeOfMalloc =+ sizeof(pkt->data);

}
	then call MSG = malloc(sizeOfMalloc);
*/

        
            

packet_t get_packet () {
  static int which = 0;

  packet_t pkt;

  pkt.how_many = 3;
  pkt.which = which;
  if (which == 0)
    strncpy (pkt.data, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", PACKET_SIZE);
  else if (which == 1)
    strncpy (pkt.data, "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", PACKET_SIZE);
  else
    strncpy (pkt.data, "cccccccccccccccccccccccccccccccccccccccccccccccccccccccc", PACKET_SIZE);
  which = (which + 1)%3 ;

  return pkt;
}


void packet_handler(int sig)
{
	//mask signals within handler
	void* old_handler = signal(sig, SIG_IGN); 

  	//fprintf (stderr, "IN PACKET HANDLER, sig=%d\n", sig); 

  	// get the next waiting packet
 	packet_t pkt = get_packet();

 	
 	int b = 1;
 	
 	if(pkt.which == 0) {
 		pkt_total = pkt.how_many;
 		pkt_cnt = 0;
 	}
 	
 	pkt_cnt++;
 	
	// create a chunk of memory and copy packet data there.
	void* memory = mm_get(&MM);
	memcpy(memory, pkt.data, PACKET_SIZE); // Not sure of syntax here...
	
	// add the new data chunk to the message struct
	message.data[ pkt.which ] = memory;
	message.num_packets = pkt_cnt;

	//unmask signal
	signal(sig, old_handler);
}


/* Create message from packets ... deallocate packets */
char *assemble_message () {

	int message_len = message.num_packets * PACKET_SIZE;
	char* MSG = (char*)malloc( message_len + 1 );
	int i;
	for(i = 0; i < message.num_packets; i++) {
		memcpy( MSG + i * PACKET_SIZE, message.data[ i ], PACKET_SIZE );
		mm_put( &MM, message.data[i] );
	}

	// add null pointer to the end.
	MSG[ message_len ] = '\0';

	

	message.num_packets = 0;

	return MSG;
}


int main (int argc, char **argv)
{

  /* init memory manager -- turns out that 64 is the packet size! */


	if(mm_init (&MM, 100, 64) == -1){
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
	//alarm(1);

  message.num_packets = 0;

	int i;
  //for (i=1; i<=NumMessages; i++) {
    while (pkt_cnt < pkt_total) {
      pause(); /* block until data[MaxPackets]next packet */
	}
      
    // stop handler
    itv.it_interval.tv_sec = itv.it_interval.tv_usec = 0;
    setitimer( ITIMER_REAL, &itv, NULL );
	signal(SIGALRM, old_handler); 

    char* MSG = assemble_message();
    fprintf (stderr, "GOT IT: message=%s\n", MSG); 
    free(MSG);
  //}

  /* Deallocate memory manager */
	mm_release(&MM);
}


