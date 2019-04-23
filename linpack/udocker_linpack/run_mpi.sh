#!/bin/bash
#SBATCH -p cola-corta,thinnodes
#SBATCH -n 16
#SBATCH -t 06:00:00

# ----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity Linpack benchmarking run script for CESGA - FT2 @ SLURM
#
# ----------------------------------------------------------------------------

# Vars
REPO=''
IMAGE='centos'
TAG=':7'
IMG=$REPO$IMAGE$TAG
NAME='mylinpack-udocker'
COMMAND_SCRIPT='mpi_commands.sh'
WORKDIR='mylinpack'
LINPACK_GEN='linpack_gen.sh'
SETUPS_DIR='setups'
OPENBLAS_DIR='/opt/cesga/easybuild-cesga/software/Compiler/gcccore/6.4.0/openblas/0.3.1/lib'


# Load Singularity, OpenMPI and OpenBlas
module load udocker
module load gcc openmpi/2.1.1
module load openblas


# Pull image
udocker pull $IMG


# Assure a clear workdir
rm -fr $WORKDIR
mkdir -p $WORKDIR
cp $LINPACK_GEN $WORKDIR/$LINPACK_GEN
cp -r $SETUPS_DIR $WORKDIR/$SETUPS_DIR
cp $COMMAND_SCRIPT $WORKDIR/$COMMAND_SCRIPT


# Compile and Run code
# Base mounts
mounts="--volume /mnt --volume /opt --volume /usr"
# Infiniband support mounts
mounts=$mounts" --volume /etc/libibverbs.d --volume /sys/class/infiniband_verbs" 
# Mount working directory
mounts=$mounts" --volume $PWD/$WORKDIR:/$WORKDIR"
udocker run --hostenv --hostauth --user=$(whoami) $mounts \
    --workdir /$WORKDIR $IMG /bin/bash $COMMAND_SCRIPT
