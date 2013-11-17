#include <stdio.h>
#include <string.h>
#include "mm_public.h"

void test_init();
void test_alloc();


int main(int argc, char* argv[]) {

	test_init();

	test_alloc();

	return 0;
}


void test_init() {
	mm_t MM;

	if( mm_init(&MM, 64, 1024) == -1 ) {
		fprintf(stderr, "Could not create memory.\n");
		exit(-1);
	}

	if( MM.size != 1024 ) {
		fprintf(stderr, "Chunk size is wrong\n");
		exit(-1);
	}

	if( MM.total_chunks != 64 ) {
		fprintf(stderr, "Number of chunks is wrong\n");
		exit(-1);
	}

	if( MM.total_chunks == 0 ) {
		fprintf(stderr, "Null pointer to memory\n");
		exit(-1);
	}

	mm_release(&MM);

	if( MM.blocks != 0 ) {
		fprintf(stderr, "Memory should have been deallocated.\n");
		exit(-1);
	}

	printf("test_init: OK\n");
}

void test_alloc() {
	mm_t MM;

	if( mm_init(&MM, 64, 1024) == -1 ) {
		fprintf(stderr, "Could not create memory.\n");
		exit(-1);
	}

	int i;
	for(i = 0; i < 64; i++) {
		void* mymem = mm_get(&MM);
		if(mymem == (void*)-1) {
			fprintf(stderr, "Couldn't get memory when there should be memory left.\n");
			exit(-1);
		}
	}

	void* mymem = mm_get(&MM);

	if(mymem != (void*)-1) {
		fprintf(stderr, "Should have gotten error because no memory left (1).\n");
		exit(-1);
	}

	for(i = 0; i < 2; i++) {
		mm_put(&MM, (void*)(MM.blocks + i * MM.size));
	}

	for(i = 0; i < 2; i++) {
		void* mymem = mm_get(&MM);
		if(mymem == (void*)-1) {
			fprintf(stderr, "Couldn't get memory when there should be memory left. After fill and empty some.\n");
			exit(-1);
		}
	}

	mymem = mm_get(&MM);

	if(mymem != (void*)-1) {
		fprintf(stderr, "Should have gotten error because no memory left (2).\n");
		exit(-1);
	}

	mm_release(&MM);

	printf("test_alloc: OK\n");
}
