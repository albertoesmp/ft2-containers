#!/bin/bash

# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity DEMO for CESGA - FT2 : Auxiliar script
#
# This script compiles and executes an MPI code through a CentOS-7 Singularity
# container using CESGA FT2 native OpenMPI 2.1.1
#
# -----------------------------------------------------------------------------



# Vars
SRC='hello_mpi.c'
BIN='hello_mpi'



# Environment
module load gcc openmpi
ln -s /usr/lib64_cesga/* /usr/lib64/ 2>/dev/null
ln -s /usr/bin_cesga/*  /usr/bin/ 2>/dev/null

# Compilation
mpicc $SRC -o $BIN

# Execution
mpirun $BIN # TODO restore


