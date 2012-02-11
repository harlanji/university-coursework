DATADIR="/class/kabbu002/5451_data_files/assign5"
MPIRUN="mpirun --mca orte_rsh_agent \"rsh\" --hostfile cluster_hosts"
REPEAT=1
	
	
make;

for i in { 1..$REPEAT }
do

	# run everything grouped by num procs, file, impl.
	for P in 2 4 8 16
	do
		for N in 50000 100000 200000 400000
		do
			MAT_A="$DATADIR/m$N-A.ij"
			MAT_B="$DATADIR/m$N-B.ij"
			VEC="$DATADIR/m$N.vec"

			CMD="$MPIRUN -np $P hw5 $MAT_A $VEC $N";
			#echo "$CMD (x$REPEAT)";
			echo "$N $P A\n"

				$CMD;

			CMD="$MPIRUN -np $P hw5 $MAT_B $VEC $N";
			#echo "$CMD (x$REPEAT)";
			echo "$N $P B\n"

				$CMD;


		done
	done


done
