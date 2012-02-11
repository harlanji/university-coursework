CFLAGS=-lm

all: lcs_serial lcs_cuda calc

lcs_serial: lcs_serial.cu
	nvcc $(CFLAGS) -o lcs_serial lcs_serial.cu

lcs_cuda: lcs_cuda.cu
	nvcc $(CFLAGS) -o lcs_cuda lcs_cuda.cu

calc: calc.c
	gcc $(CFLAGS) -o calc calc.c

clean:
	rm -f lcs_serial lcs_cuda calc
