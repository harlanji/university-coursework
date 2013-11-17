#include "mm_public.h"

void main_mm();

void main_mm() {

	struct timeval time_start, time_end;
	int j,i;

	j = gettimeofday (&time_start, (void *)NULL);
	mm_t MM;
	if(mm_init (&MM, 10000, 64) == -1){
		perror("failed to initialize mm");
	}
	for (i = 0; i < 10000; i++){
		mm_get (&MM);
	}
	for (i = 0; i < 10000; i++){
		mm_put (&MM, (void*) (MM.blocks + i * MM.size));
	}
	mm_release(&MM);
	j = gettimeofday (&time_end, (void *)NULL);
	fprintf (stderr, "Time taken for MM =  %f msec\n\n",
		 comp_time (time_start, time_end)/1000.0);
}

void main(int argc, char* argv[]) {
	int i = 1;
	if(argc == 2) {
		i = atoi(argv[1]);
	}
	for(;i>0; i--)
		main_mm();
}
