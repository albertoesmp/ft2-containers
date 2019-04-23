#!/bin/bash

# ----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity Linpack benchmarking commands for CESGA - FT2 @ SLURM
#
# ----------------------------------------------------------------------------

# Vars
SRUN='/bin/srun'
MPI_BIN_DIR='/opt/cesga/easybuild-cesga/software/Compiler/gcc/6.4.0/openmpi/2.1.1/bin'
LINPACK_GEN='linpack_gen.sh'
WORKDIR='/mylinpack'

# Configure environment
export PATH=$PATH:$MPI_BIN_DIR
cd $WORKDIR


# Prepare HPLinpack
chmod 755 $LINPACK_GEN
./$LINPACK_GEN


# Run HPLinpack
cd gen/hpl-2.3/bin/Linux_OMPI
echo -e '\tRunning linpack ...\n\n'
mpirun -n 16 xhpl > 'out.log'
echo -e '\n\n\tLinpack finished!\n'
