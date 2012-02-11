#include <math.h>
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>

void prefix_scan(int* input, int* output, int n) {

}

void counting_sort(int* input, int* output, int n, int mask) {

#define key(x) mask & x > 0 ? 1 : 0

	int C[2] = {0, 0};
	for(int i = 0; i < n; i++) {
		
		C[ key(input[i]) ]++;
	}
	
	C[1] = C[0];
	C[0] = 0;
	
	for(int i = 0; i < n; i++) {
		printf("input[%i] = %i, key=%i\n", i, input[i], key(input[i]));
		output[ C[key(input[i])] ] = input[i];
		C[ key(input[i]) ]++;
	}

	
#undef key
	
	// Prefix Scan:
	// allocate C[0..k-1] with each element set to 0
	// iterate over input 
	//   C[ key(input[i]) ]++
	// total = 0
	// iterate over keys
	//   c = C[i]
	//   C[i] = total
	//   total += c
	
	// Store:
	// iterate over input
	//   output[ C[key(input[i])] ] = input[i]
	//   C[ key(input[i]) ]++
}

void radix_counting_sort(int* input, int* output, int n) {
	// we need two buffers to alternate
	int* b0 = output;
	int* b1 = (int*)malloc(n*sizeof(int));
	
	// start off with the input
	memcpy( b0, input, n*sizeof(int) );
	
	// loop once per bit
	int d = 8*sizeof(int);
	for(int i = 0; i < d; i++) {
		int mask = pow(2,i);
		counting_sort(b0, b1, n, mask);
	
		int* t = b0;
		b0 = b1;
		b1 = t;
	}
	
	
	
	// there will always be an even number of iterations,
	// so b1 will always be the buffer we allocated.
	assert( b1 != output );
	
	memcpy(output, b1, n*sizeof(int) );
	free(b1);
}


int main(int argc, char* argv[]) {
	int input[] = {4,3,2,6,2,3,4,3};
	int output[] = {0,0,0,0,0,0,0,0};
	int n = 8;
	
	radix_counting_sort( input, output, n );
	
	for(int i = 0; i < n; i++) {
		printf("output[%i] = %i\n", i, output[i]);
	}
}
