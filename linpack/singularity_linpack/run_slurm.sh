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
REPO='library://library/default/'
IMAGE='centos'
TAG=':7'
IMG=$REPO$IMAGE$TAG
NAME='mylinpack.sif'
COMMAND_SCRIPT='slurm_commands.sh'
WORKDIR='mylinpack'
LINPACK_GEN='linpack_gen.sh'
SETUPS_DIR='setups'
OPENBLAS_DIR='/opt/cesga/easybuild-cesga/software/Compiler/gcccore/6.4.0/openblas/0.3.1/lib'


# Load Singularity, OpenMPI and OpenBlas
module load singularity/3.1.1
module load gcc openmpi/2.1.1
module load openblas


# Pull image
singularity pull $NAME $IMG


# Assure a clear workdir
rm -fr $WORKDIR
mkdir -p $WORKDIR
cp $LINPACK_GEN $WORKDIR/$LINPACK_GEN
cp -r $SETUPS_DIR $WORKDIR/$SETUPS_DIR
cp $COMMAND_SCRIPT $WORKDIR/$COMMAND_SCRIPT
chmod 755 $WORKDIR/$COMMAND_SCRIPT


# FT2 slurm, gcc and openmpi mounts
mounts="-B /mnt -B /opt/cesga"
mounts=$mounts" -B /usr/lib64:/usr/lib64_cesga"
mounts=$mounts" -B /usr/bin:/usr/bin_cesga"
# Slurm mounts (/usr/bin is also required for slurm but it was done for mpi)
mounts=$mounts" -B /etc/slurm"
mounts=$mounts" -B /var/run/munge/"
# FT2 infiniband mounts
mounts=$mounts" -B /etc/libibverbs.d"
# Mount scratch if exists (used when running at queue system)
if [ -d /scratch ]; then
    mounts=$mounts" -B /scratch"
fi
# Workdir mounts
mounts=$mounts" -B $WORKDIR"
# Singularity!
singularity exec $mounts $NAME $WORKDIR/$COMMAND_SCRIPT
#singularity shell $mounts -W /$WORKDIR $NAME
