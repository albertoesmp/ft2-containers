#!/bin/bash
#SBATCH -p thinnodes
#SBATCH -n 16
#SBATCH -t 09:00:00


# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script can be used to execute the linpack benchmark generated by
# linpack_gen script in CESGA FinisTerrae-II.
#
# USAGE:
#   -> ./linpack_run.sh         # Local execution, for testing purposes
#   -> sbatch linpack_run.sh    # Submit to queue, for real benchmarking
#
# ----------------------------------------------------------------------------

# ---  V A R S  --- #
# ----------------- #
MPIRUN='mpirun' # MPI executor
MPINP=16 # Num procs
ROOT_DIR=$PWD
LINPACK_DIR=$ROOT_DIR'/gen/hpl-2.3/bin/Linux_OMPI'
LINPACK_BIN='xhpl'
OUT_LOG=$ROOT_DIR'/out.log'


# ---  FUNCTIONS  --- #
# ------------------- #
function prepare_environment {
    module load gcc openmpi/2.1.5
    module load openblas
}

function linpack_exec {
    cd $LINPACK_DIR
    $MPIRUN -n $MPINP $LINPACK_BIN 2>&1 > $OUT_LOG
    echo -e '\n\tLinpack benchmark executed.\n'
    echo -e '\t\tOutput generated at: "'$OUT_LOG'"\n'
}

# ---  M A I N  --- #
# ----------------- #
prepare_environment
linpack_exec
