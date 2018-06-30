#!/bin/bash

C_NONE="\033[0;00m"
C_GREEN="\033[1;32m"
C_RED_BK="\033[1;41m"

# Detect OS distribution
# Try source all the release files
for file in /etc/*-release; do
    source $file 
done

if [[ "$NAME" != ""  ]]; then
    OS="$NAME"
    VERSION="$VERSION_ID"
elif [[ -f /etc/debian_version ]]; then
    # Older Debian/Ubuntu/etc.
    OS="Debian"
    VERSION="$(cat /etc/debian_version)"
else
    OS="$(lsb_release -si)"
    VERSION="$(lsb_release -sr)"
fi

function inform_sudo()
{
    [[ ! -z "$1" ]] && echo "$1"
    # Exit without printing messages if password is still in the cache.
    sudo -n true 2> /dev/null
    [[ $? == 0 ]] && return 0;
    sudo >&2 echo -e "\033[1;33mRunning with root privilege now...\033[0;00m";
    [[ $? != 0 ]] && >&2 echo -e "\033[1;31mAbort\033[0m" && exit 1;
}

function prepare_demo()
{
	cd ~
	git clone https://github.com/cyliustack/benchmark
	cp ~/benchmark/mpi/tools/demo.sh .
	cp ~/benchmark/mpi/tools/demo-npb.sh .
}

function install_benchmarks()
{
	# Install Python packages
	echo -e "${C_GREEN}Installing benchmarks...${C_NONE}"
	mpich_version=3.2
	mpich_package=mpich-$mpich_version
	mpich_tar=$mpich_package.tar.gz
	#openmpi_version=openmpi-3.1.0
	#openmpi_tar=$openmpi_version.tar.gz
	if [[ ! -f $mpich_tar ]] ; then
		#wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.0.tar.gz
		wget http://www.mpich.org/static/downloads/$mpich_version/$mpich_tar
		echo "mpich is downloaded" 
	fi
	tar xvf $mpich_tar
	pushd $mpich_package && ./configure --prefix=/opt/mpich && make -j && sudo make install && popd 
 	if [[ $(which mpirun) ]]; then	
		echo export PATH=/opt/mpich/bin:$PATH >> ~/.bashrc
 		echo export LD_LIBRARY_PATH=/opt/mpich/lib:$LD_LIBRARY_PATH >> ~/.bashrc
	fi	
	[[ $? != 0 ]] && echo -e "${C_RED_BK}Failed... :(${C_NONE}" && exit 1
}


function install_python_packages()
{
    # Install Python packages
    echo -e "${C_GREEN}Installing python packages...${C_NONE}"
    python3 -m pip install --upgrade pip
    python3 -m pip install --user numpy  
    python3 -m pip install --user tensorflow==1.5.0 
    [[ $? != 0 ]] && echo -e "${C_RED_BK}Failed... :(${C_NONE}" && exit 1
}

function install_packages()
{
    echo -e "${C_GREEN}Installing other packages...${C_NONE}"

    #inform_sudo "Running sudo for installing packages"
    if [[ $(which apt) ]] ; then
        sudo apt-get update
        sudo apt-get update --fix-missing
	sudo apt-get install -y gcc g++ curl wget python3 python3-pip gfortran sshpass
	[[ $? != 0 ]] && echo -e "${C_RED_BK}Failed... :(${C_NONE}" && exit 1
    elif [[ $(which yum) ]]  ; then
        sudo yum install -y epel-release 
        sudo yum install -y centos-release-scl devtoolset-4-gcc* python3 python-pip sshpass
        [[ $? != 0 ]] && echo -e "${C_RED_BK}Failed... :(${C_NONE}" && exit 1
    else
        echo -e "${C_RED_BK}This script does not support your OS distribution, '$OS'. Please install the required packages by yourself. :(${C_NONE}"
    fi
}

# main
echo -e "${C_GREEN}OS Distribution:${C_NONE} '$OS'"
echo -e "${C_GREEN}Version:${C_NONE} '$VERSION'"
printf "\n\n"

install_packages
install_python_packages
install_benchmarks
prepare_demo
echo -e "${C_GREEN}Complete!!${C_NONE}"
