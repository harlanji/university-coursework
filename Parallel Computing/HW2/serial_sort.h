#ifndef __SERIAL_SORT_H__
#define __SERIAL_SORT_H__


#define LOG_NONE 0
#define LOG_DEBUG 1
#define LOG_INFO 2
#define LOG_BENCH 4
#define LOG_TRACE 8

#define LOG_LEVEL LOG_NONE

#define log(level, s, rest...) if((LOG_LEVEL) & level) { printf(s, ## rest); }

#define TIME_OUTPUT "Total execution time: %f seconds with %d processors.\n"

double get_timeofday();
void merge(const int* a, const int* b, const unsigned long n, int* out);


int mergesort(int *input, unsigned long size);
void merge_helper(int *input, unsigned long left, unsigned long right, int *scratch);

int read_data(char* filename, int** input_values, unsigned long* input_len);

#endif // __SERIAL_SORT_H__
