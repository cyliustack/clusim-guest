#!/bin/bash 
~/benchmark/tools/ssh_copy_id_to_all.sh 4
~/benchmark/tools/genhosts.sh 4
mpirun -machinefile hosts.txt benchmark/mpi/gemm/gemm 1000 1000 1000
