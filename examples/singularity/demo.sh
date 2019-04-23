#!/bin/bash -x

# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity DEMO for CESGA - FT2
#
# -----------------------------------------------------------------------------

# Vars
REPO='library://sylabsed/examples/' # MUST end with / or be an empty string
IMAGE='lolcow' # MUST be a non empty string
TAG=':latest' # MUST start with : or be an empty string
IMG=$REPO$IMAGE$TAG
NAME='mylolcow.sif'

# Demo
cat << EOF


# * * * * * * * * * * * * * * * * * * #
#     SINGULARITY   DEMONSTRATION     #
# * * * * * * * * * * * * * * * * * * #


EOF

# Load singularity
module load singularity/3.1.1

# Delete image if already exists
rm -f $NAME

# Pull image
singularity pull $NAME library://sylabsed/examples/lolcow

# Run container
singularity run $NAME

