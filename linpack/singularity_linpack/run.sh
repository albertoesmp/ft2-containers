#!/bin/bash
#SBATCH -p cola-corta,thinnodes
#SBATCH -n 16
#SBATCH -t 06:00:00

# ----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity Linpack benchmarking run script for CESGA - FT2
#
# ----------------------------------------------------------------------------

# Vars
REPO='docker://albertoesmp/'
IMAGE='centos-linpack'
TAG=':latest'
IMG=$REPO$IMAGE$TAG
NAME='centos_linpack.sif'
COMMAND_SCRIPT='commands.sh'
WORKDIR='mylinpack'
LINPACK_GEN='light_linpack_gen.sh'
SETUPS_DIR='setups'


# Load Singularity, OpenMPI and OpenBlas
module load singularity/3.1.1


# Pull image
singularity pull $NAME $IMG


# Assure a clear workdir
rm -fr $WORKDIR
mkdir -p $WORKDIR
cp $LINPACK_GEN $WORKDIR/$LINPACK_GEN
cp -r $SETUPS_DIR $WORKDIR/$SETUPS_DIR
cp $COMMAND_SCRIPT $WORKDIR/$COMMAND_SCRIPT
chmod 755 $WORKDIR/$COMMAND_SCRIPT


# Mount make
# Mount scratch if exists (used when running at queue system)
if [ -d /scratch ]; then
    mounts=$mounts" -B /scratch"
fi
# Workdir mounts
mounts=$mounts" -B $WORKDIR:/$WORKDIR"
# Singularity!
singularity exec $mounts $NAME /$WORKDIR/$COMMAND_SCRIPT
#singularity shell $mounts -W /$WORKDIR $NAME
