#!/bin/bash 
C_NONE="\033[0m"
C_CYAN="\033[36m"
C_RED="\033[31m"
C_GREEN="\033[32m"
C_ORANGE="\033[33m"
C_BLUE="\033[34m"
C_PURPLE="\033[35m"
C_CYAN="\033[36m"
C_LIGHT_GRAY="\033[37m"

print_misc() {
    echo -e "${C_PURPLE} $1 ${C_NONE}"
}

print_info() {
    echo -e "${C_BLUE} $1 ${C_NONE}"
}

print_error() {
    echo -e "${C_RED} $1 ${C_NONE}"
}

print_warning() {
    echo -e "${C_ORANGE} $1 ${C_NONE}"
}

print_misc "Bash version ${BASH_VERSION}."

if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]]
then
	print_error "Usage: ./demo-npb.sh name class num_processes"
	exit -1
fi

NAME=$1
CLASS=$2
NUM_PROCESSES=$3  
~/benchmark/tools/ssh_copy_id_to_all.sh ${NUM_PROCESSES}
~/benchmark/tools/genhosts.sh ${NUM_PROCESSES}
parallel-ssh -h hosts.txt "make -C ~/benchmark/mpi/NPB3.3-MPI ${NAME} CLASS=${CLASS} NPROCS=${NUM_PROCESSES}"
if [[ ! -f benchmark/mpi/NPB3.3-MPI/bin/${NAME}.${CLASS}.${NUM_PROCESSES} ]]
then
	print_error "Cannot find ${NAME}.${CLASS}.${NUM_PROCESSES}"
	exit -1
fi
mpirun -n ${NUM_PROCESSES} -machinefile hosts.txt benchmark/mpi/NPB3.3-MPI/bin/${NAME}.${CLASS}.${NUM_PROCESSES}




