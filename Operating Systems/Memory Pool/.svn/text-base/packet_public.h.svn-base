#include "mm_public.h"

#define MAX_MESSAGES 15
#define PACKET_SIZE 56
#define MaxPackets 10

typedef char data_t[PACKET_SIZE];

typedef struct {
  int how_many; /* number of packets in the message */
  int which;    /* which packet in the message -- currently ignored */
  int msg_id;
  data_t data;  /* packet data */
} packet_t;


/* Keeps track of packets that have arrived for the message */
typedef struct {
  int num_packets;
  int how_many_arrived;
  int id;
  void *data[MaxPackets];
} message_t;

