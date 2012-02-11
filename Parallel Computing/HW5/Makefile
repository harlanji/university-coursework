CC=mpicc
CFLAGS=-DNDEBUG

DOMAIN=`domainname`
ifeq ($(DOMAIN), IoTLabs)
	MPIRUN=mpirun --mca orte_rsh_agent \"rsh\" --hostfile cluster_hosts
else
	MPIRUN=mpirun
endif


all:	hw5

hw5:	mpi_matrix.c mpi_matrix.h hw5.c util.h
	$(CC) $(CFLAGS) mpi_matrix.c hw5.c -o hw5
