#!/bin/bash
#SBATCH -p cola-corta,thinnodes
#SBATCH -n 1
#SBATCH -t 00:05:00

# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Udocker DEMO for CESGA - FT2 using queue system
#
# -----------------------------------------------------------------------------

# Vars
REPO='' # MUST end with / or be an empty string
IMAGE='bash' # MUST be a non empty string
TAG='' # MUST start with : or be an empty string
IMG=$REPO$IMAGE$TAG
NAME='mybash'
LOG_FILE='demo_sbatch.log'
BASH_FILE='commands.sh' # Bash file to be executed inside container

# Load udocker
module load udocker

# Pull image
udocker pull $IMG

# Create container with name
udocker create --name=$NAME $IMG

# Run container
udocker run --hostenv --user=$(whoami) -v $HOME -v $STORE -v $PWD --workdir=$PWD \
    $NAME bash $BASH_FILE 2>&1> $LOG_FILE

# Remove container
udocker rm $NAME
