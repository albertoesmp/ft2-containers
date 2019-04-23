#!/bin/bash -x
#SBATCH -p cola-corta,thinnodes
#SBATCH -n 2
#SBATCH -t 00:05:00


# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity DEMO for CESGA - FT2 using queue system in a fine MPI
#                               performance fashion using OpenMPI 2.1.1
#                               and SLURM as workload manager
#
# Container is a CentOS 7 based one.
#
# -----------------------------------------------------------------------------

# Vars
REPO='library://library/default/'
IMAGE='centos'
TAG=':7'
IMG=$REPO$IMAGE$TAG
NAME='singularity_centos_hello.sif'
WORKDIR='sch_workdir'
SRC='hello_mpi.c'
COMMAND_SCRIPT='demo_slurm_commands.sh'


# Load Singularity and OpenMPI
module load singularity/3.1.1
module load gcc openmpi/2.1.1


# Make a clean workdir
rm -fr $WORKDIR
mkdir -p $WORKDIR
cp $SRC $WORKDIR
cp $COMMAND_SCRIPT $WORKDIR
cd $WORKDIR
chmod 755 $COMMAND_SCRIPT


# Pull image
singularity pull $NAME $IMG


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
mounts=$mounts" -B ../$WORKDIR:/$WORKDIR"
# Singularity!
#singularity shell $mounts -W $WORKDIR $NAME
singularity exec $mounts -W $WORKDIR $NAME ./$COMMAND_SCRIPT


