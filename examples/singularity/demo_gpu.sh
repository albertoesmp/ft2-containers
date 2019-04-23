#!/bin/bash
#SBATCH -p gpu-shared
#SBATCH --gres=gpu
#SBATCH -t 00:30:00

# REFERENCE: https://singularity.lbl.gov/docs-exec#a-gpu-example

# ---  V A R S  --- #
# ----------------- #
GIT_URL='https://github.com/tensorflow/models.git'
MODELS_DIR='models'
CONTAINER_URI='docker://tensorflow/tensorflow:latest-gpu'


# ---  EXECUTION --- #
# ------------------ #
# Get models
if [ -d $MODELS_DIR ]; then
    echo '"'$GIT_URL'" will not be cloned since it already exists at:'
    echo -e '\t"'$MODELS_DIR'"'
else
    git clone $GIT_URL
fi

# Load modules
module load singularity/3.1.1

# Perform convolutional calculus through singularity
singularity exec --nv $CONTAINER_URI \
        python ./models/tutorials/image/mnist/convolutional.py

