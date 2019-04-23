#!/bin/bash
#SBATCH -p cola-corta,thinnodes
#SBATCH -n 2
#SBATCH -t 00:05:00

# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity DEMO for CESGA - FT2 using queue system
#
# -----------------------------------------------------------------------------

# Vars
REPO='shub://michael-tn/' # MUST end with / or be an empty string
IMAGE='mpi-hello-world' # MUST be a non empty string
TAG=':latest' # MUST start with : or be an empty string
IMG=$REPO$IMAGE$TAG
NAME='mpihello.sif'

# Load singularity
module load singularity/3.1.1

# Delete image if already exists
rm -f $NAME

# Pull image
singularity pull $NAME $IMG

# Run container
singularity exec -B /tmp:/scratch $NAME mpirun -n 2 mpi_hello_world
