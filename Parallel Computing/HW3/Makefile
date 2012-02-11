CFLAGS=-lm -lpthread -g

all: lcs_mpi lcs_serial lcs_pthreads lcs_openmp

common.o: common.c common.h
	gcc $(CFLAGS) -o common.o -c common.c

queue.o: queue.c queue.h
	gcc $(CFLAGS) -o queue.o -c queue.c

lcs_mpi: common.o lcs_mpi.c
	mpicc $(CFLAGS) -o lcs_mpi common.o lcs_mpi.c


lcs_serial: common.o lcs_serial.c
	gcc $(CFLAGS) -o lcs_serial common.o lcs_serial.c

lcs_pthreads: common.o queue.o lcs_pthreads.c
	gcc $(CFLAGS) -lpthread -o lcs_pthreads queue.o common.o lcs_pthreads.c
	
lcs_openmp: common.o queue.o lcs_openmp.c
	gcc $(CFLAGS) -fopenmp -o lcs_openmp queue.o common.o lcs_openmp.c

clean:
	rm -f common.o lcs_mpi lcs_serial lcs_pthreads lcs_openmp
