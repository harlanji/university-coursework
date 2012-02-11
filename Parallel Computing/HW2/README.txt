The general approach was to read the input data and distribute it to all processes. 
Each process would run a serial merge sort on its partition, and then the merging process 
was parallel in groups of two processors. Conceptually it can be thought of as
a tree with the leaf nodes merging with their neighboring sibling, with the 
results forming the new set of leaves to be merged recursively, until
only one node is left.

Note that output will be incorrect for small_test.txt with >4 processors 
because of the way splitting is done. 100/4=25, 100/8 = 12.5. And also in 
cases where p is not a power of 2. This could be handled in a number of ways, 
such as falling back to p such that p divides n and is a power of 2. I decided 
not to handle it, and simply acknowledge the shortcoming.

Note also that I used a serial merge sort implementation that was online, source
is cited in serial_sort.c.

--------------------------------------------------------------------------------

RESULTS:

The results are grouped by #procs, file, impl. See run_all.sh for details.

% ./run_all.sh 
make: Nothing to be done for `all'.
./mg_pthreads small_test.txt 1 (x3)
Total execution time: 0.000096 seconds with 1 processors.
Total execution time: 0.000088 seconds with 1 processors.
Total execution time: 0.000088 seconds with 1 processors.
./mg_openmp small_test.txt 1 (x3)
Total execution time: 0.000034 seconds with 1 processors.
Total execution time: 0.000032 seconds with 1 processors.
Total execution time: 0.000032 seconds with 1 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 1 mg_mpi small_test.txt 1 (x3)
Total execution time: 0.000060 seconds with 1 processors.
Total execution time: 0.000056 seconds with 1 processors.
Total execution time: 0.000059 seconds with 1 processors.
./mg_pthreads medium_test.txt 1 (x3)
Total execution time: 0.052179 seconds with 1 processors.
Total execution time: 0.052074 seconds with 1 processors.
Total execution time: 0.052085 seconds with 1 processors.
./mg_openmp medium_test.txt 1 (x3)
Total execution time: 0.051958 seconds with 1 processors.
Total execution time: 0.051959 seconds with 1 processors.
Total execution time: 0.051985 seconds with 1 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 1 mg_mpi medium_test.txt 1 (x3)
Total execution time: 0.052969 seconds with 1 processors.
Total execution time: 0.054150 seconds with 1 processors.
Total execution time: 0.053446 seconds with 1 processors.
./mg_pthreads large_test.txt 1 (x3)
Total execution time: 6.730664 seconds with 1 processors.
Total execution time: 6.730523 seconds with 1 processors.
Total execution time: 6.729249 seconds with 1 processors.
./mg_openmp large_test.txt 1 (x3)
Total execution time: 6.756509 seconds with 1 processors.
Total execution time: 6.739378 seconds with 1 processors.
Total execution time: 6.737472 seconds with 1 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 1 mg_mpi large_test.txt 1 (x3)
Total execution time: 6.828523 seconds with 1 processors.
Total execution time: 7.014877 seconds with 1 processors.
Total execution time: 6.855234 seconds with 1 processors.
./mg_pthreads small_test.txt 2 (x3)
Total execution time: 0.000126 seconds with 2 processors.
Total execution time: 0.000124 seconds with 2 processors.
Total execution time: 0.000124 seconds with 2 processors.
./mg_openmp small_test.txt 2 (x3)
Total execution time: 0.000095 seconds with 2 processors.
Total execution time: 0.000103 seconds with 2 processors.
Total execution time: 0.000099 seconds with 2 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 2 mg_mpi small_test.txt 2 (x3)
Total execution time: 0.000099 seconds with 2 processors.
Total execution time: 0.000097 seconds with 2 processors.
Total execution time: 0.000118 seconds with 2 processors.
./mg_pthreads medium_test.txt 2 (x3)
Total execution time: 0.026961 seconds with 2 processors.
Total execution time: 0.027145 seconds with 2 processors.
Total execution time: 0.027057 seconds with 2 processors.
./mg_openmp medium_test.txt 2 (x3)
Total execution time: 0.029289 seconds with 2 processors.
Total execution time: 0.028608 seconds with 2 processors.
Total execution time: 0.027854 seconds with 2 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 2 mg_mpi medium_test.txt 2 (x3)
Total execution time: 0.027975 seconds with 2 processors.
Total execution time: 0.027205 seconds with 2 processors.
Total execution time: 0.028117 seconds with 2 processors.
./mg_pthreads large_test.txt 2 (x3)
Total execution time: 3.392332 seconds with 2 processors.
Total execution time: 3.396871 seconds with 2 processors.
Total execution time: 3.393193 seconds with 2 processors.
./mg_openmp large_test.txt 2 (x3)
Total execution time: 3.450833 seconds with 2 processors.
Total execution time: 3.455594 seconds with 2 processors.
Total execution time: 3.398221 seconds with 2 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 2 mg_mpi large_test.txt 2 (x3)
Total execution time: 3.501221 seconds with 2 processors.
Total execution time: 3.501795 seconds with 2 processors.
Total execution time: 3.501485 seconds with 2 processors.
./mg_pthreads small_test.txt 4 (x3)
Total execution time: 0.000213 seconds with 4 processors.
Total execution time: 0.000199 seconds with 4 processors.
Total execution time: 0.000211 seconds with 4 processors.
./mg_openmp small_test.txt 4 (x3)
Total execution time: 0.000199 seconds with 4 processors.
Total execution time: 0.000196 seconds with 4 processors.
Total execution time: 0.000194 seconds with 4 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 4 mg_mpi small_test.txt 4 (x3)
Total execution time: 0.000771 seconds with 4 processors.
Total execution time: 0.000791 seconds with 4 processors.
Total execution time: 0.005091 seconds with 4 processors.
./mg_pthreads medium_test.txt 4 (x3)
Total execution time: 0.015772 seconds with 4 processors.
Total execution time: 0.015883 seconds with 4 processors.
Total execution time: 0.015905 seconds with 4 processors.
./mg_openmp medium_test.txt 4 (x3)
Total execution time: 0.022214 seconds with 4 processors.
Total execution time: 0.018674 seconds with 4 processors.
Total execution time: 0.019644 seconds with 4 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 4 mg_mpi medium_test.txt 4 (x3)
Total execution time: 0.019440 seconds with 4 processors.
Total execution time: 0.019272 seconds with 4 processors.
Total execution time: 0.019287 seconds with 4 processors.
./mg_pthreads large_test.txt 4 (x3)
Total execution time: 1.797806 seconds with 4 processors.
Total execution time: 1.797259 seconds with 4 processors.
Total execution time: 1.799259 seconds with 4 processors.
./mg_openmp large_test.txt 4 (x3)
Total execution time: 1.795130 seconds with 4 processors.
Total execution time: 1.820232 seconds with 4 processors.
Total execution time: 1.799417 seconds with 4 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 4 mg_mpi large_test.txt 4 (x3)
Total execution time: 2.192223 seconds with 4 processors.
Total execution time: 2.184272 seconds with 4 processors.
Total execution time: 2.186563 seconds with 4 processors.
./mg_pthreads small_test.txt 8 (x3)
Total execution time: 0.000426 seconds with 8 processors.
Total execution time: 0.000440 seconds with 8 processors.
Total execution time: 0.000446 seconds with 8 processors.
./mg_openmp small_test.txt 8 (x3)
Total execution time: 0.000437 seconds with 8 processors.
Total execution time: 0.000472 seconds with 8 processors.
Total execution time: 0.000421 seconds with 8 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 8 mg_mpi small_test.txt 8 (x3)
Total execution time: 0.008560 seconds with 8 processors.
Total execution time: 0.005254 seconds with 8 processors.
Total execution time: 0.001700 seconds with 8 processors.
./mg_pthreads medium_test.txt 8 (x3)
Total execution time: 0.010329 seconds with 8 processors.
Total execution time: 0.010344 seconds with 8 processors.
Total execution time: 0.010257 seconds with 8 processors.
./mg_openmp medium_test.txt 8 (x3)
Total execution time: 0.014839 seconds with 8 processors.
Total execution time: 0.015613 seconds with 8 processors.
Total execution time: 0.018547 seconds with 8 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 8 mg_mpi medium_test.txt 8 (x3)
Total execution time: 0.015691 seconds with 8 processors.
Total execution time: 0.015678 seconds with 8 processors.
Total execution time: 0.015727 seconds with 8 processors.
./mg_pthreads large_test.txt 8 (x3)
Total execution time: 1.050070 seconds with 8 processors.
Total execution time: 1.048710 seconds with 8 processors.
Total execution time: 1.050200 seconds with 8 processors.
./mg_openmp large_test.txt 8 (x3)
Total execution time: 1.046152 seconds with 8 processors.
Total execution time: 1.062784 seconds with 8 processors.
Total execution time: 1.062936 seconds with 8 processors.
mpirun --mca orte_rsh_agent "rsh" --hostfile cluster_hosts -np 8 mg_mpi large_test.txt 8 (x3)
Total execution time: 1.557982 seconds with 8 processors.
Total execution time: 1.560112 seconds with 8 processors.
Total execution time: 1.557991 seconds with 8 processors.
