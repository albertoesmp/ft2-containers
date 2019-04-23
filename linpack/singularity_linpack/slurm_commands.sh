#!/bin/bash

# ----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity Linpack benchmarking commands for CESGA - FT2 @ SLURM
#
# ----------------------------------------------------------------------------

# Vars
SRUN='/usr/bin_cesga/srun'
LINPACK_GEN='linpack_gen.sh'
WORKDIR='mylinpack'

# Configure environment
module load gcc openmpi wget make
ln -s /usr/lib64_cesga/* /usr/lib64/ 2>/dev/null
ln -s /usr/bin_cesga/*  /usr/bin/ 2>/dev/null
echo 'slurm:x:567:567::/etc/slurm:/bin/false' >> /etc/passwd # Make slurm user
cd $WORKDIR


# Prepare HPLinpack
chmod 755 $LINPACK_GEN
./$LINPACK_GEN


# Run HPLinpack
cd gen/hpl-2.3/bin/Linux_OMPI
echo -e '\tRunning linpack ...\n\n'
$SRUN xhpl 2>&1 > 'out.log'
echo -e '\n\n\tLinpack finished!\n'
