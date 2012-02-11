CFLAGS=

all: mg_mpi mg_pthreads mg_openmp

serial_sort.o: serial_sort.c serial_sort.h
	gcc $(CFLAGS) -o serial_sort.o -c serial_sort.c

mg_mpi: serial_sort.o mg_mpi.c
	mpicc $(CFLAGS) -o mg_mpi serial_sort.o mg_mpi.c

mg_pthreads: serial_sort.o mg_pthreads.c
	gcc $(CFLAGS) -lpthread -o mg_pthreads serial_sort.o mg_pthreads.c
	
mg_openmp: serial_sort.o mg_openmp.c
	gcc $(CFLAGS) -fopenmp -o mg_openmp serial_sort.o mg_openmp.c

clean:
	rm -f serial_sort.o mg_mpi mg_serial mg_pthreads mg_openmp
