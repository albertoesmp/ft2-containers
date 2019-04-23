#!/bin/bash -x

# -----------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Udocker DEMO for CESGA - FT2
#
# -----------------------------------------------------------------------------

# Vars
REPO='godlovedc/' # MUST end with / or be an empty string
IMAGE='lolcow' # MUST be a non empty string
TAG=':latest' # MUST start with : or be an empty string
IMG=$REPO$IMAGE$TAG
NAME='mylolcow'

# Demo
cat << EOF


# * * * * * * * * * * * * * * * * #
#     UDOCKER   DEMONSTRATION     #
# * * * * * * * * * * * * * * * * #


EOF

# Load udocker
module load udocker/1.1.3-python-2.7.15

# Delete image if already exists
udocker rmi $IMG 2>/dev/null

# Pull image
udocker pull $IMG

# Create container with name
udocker create --name=$NAME $IMG

# List containers
udocker ps

# Run container
udocker run $NAME

# Remove container
udocker rm $NAME

# List images
udocker images
