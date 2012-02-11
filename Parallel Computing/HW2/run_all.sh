REPEAT=3

make;

# run everything grouped by num procs, file, impl.
for NPROC in 1 2 4 8
do
	for FILE in small_test.txt medium_test.txt large_test.txt
	do
		for IMPL in "./zmg_pthreads" "./mg_openmp" "mpirun --mca orte_rsh_agent \"rsh\" --hostfile cluster_hosts -np $NPROC mg_mpi"
		do
			CMD="$IMPL $FILE $NPROC";
			echo "$CMD (x$REPEAT)";
			for i in { 1..$REPEAT }
			do
				$CMD;
			done
		done
	done
done
