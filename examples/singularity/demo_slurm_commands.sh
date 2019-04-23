#!/bin/bash

# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity DEMO for CESGA - FT2 : Auxiliar script
#
# This script compiles and executes an MPI code through a CentOS-7 Singularity
# container using CESGA FT2 native OpenMPI 2.1.1 and SLURM workload manager.
#
# -----------------------------------------------------------------------------



# Vars
SRUN='/usr/bin_cesga/srun'
SRC='hello_mpi.c'
BIN='hello_mpi'



# Environment
module load gcc openmpi
ln -s /usr/lib64_cesga/* /usr/lib64/ 2>/dev/null
ln -s /usr/bin_cesga/*  /usr/bin/ 2>/dev/null
echo 'slurm:x:567:567::/etc/slurm:/bin/false' >> /etc/passwd # Make slurm user

# Compilation
mpicc $SRC -o $BIN

# Execution
$SRUN $BIN


