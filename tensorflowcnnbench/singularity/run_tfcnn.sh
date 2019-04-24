#!/bin/bash
#SBATCH -p gpu-shared
#SBATCH --gres=gpu
#SBATCH -t 00:30:00

# ---------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity Tensorflow CNN benchmarking for CESGA - FT2
#
# ---------------------------------------------------------------------------


#
#                       This script may not work if it is directly launched
#                       from FT2 front-end because translating the container
#                       from docker image format to singularity container
#                       format requires some resources which are not available
#                       for default users at front-end.
# /!\ WARNING /!\
#                       A valid workaround to solve this is launching this
#                       script from "compute --gpu" session so the container
#                       is obtained.
#
#                       No workaround is required if this script is just
#                       submitted to queue system using sbatch.
#

# ---  V A R S  --- #
# ----------------- #
GIT_URL='https://github.com/tensorflow/benchmarks'
GIT_BRANCH='cnn_tf_v1.13_compatible'
BENCHMARKS_DIR='benchmarks'
CONTAINER_URI='docker://tensorflow/tensorflow:latest-gpu'
NAME="singularity_tensorflow.sif"
COMMAND_SCRIPT="tfcnn_commands.sh"

# ---  EXECUTION  --- #
# ------------------- #
# Load modules
module load curl # Used to load CA-certificates and avoid problems when cloning
module load singularity/3.1.1

# Get benchmark
if [ -d $BENCHMARKS_DIR ]; then
    echo '"'$BENCHMARKS_DIR'" already exists!'
    echo -e '\t(There is no need to download what you already have) :)'
else
    git config --global http.sslVerify false
    git clone --single-branch --branch $GIT_BRANCH $GIT_URL
fi

# Load modules

# Obtain tensorflow singularity container from docker image if not already
if [ -f $NAME ]; then
    echo '"'$NAME'" already exists!'
    echo -e '\t(Which is great because it takes quite a time to get it) :>'
else
    singularity pull $NAME $CONTAINER_URI
fi

# Run container
chmod 755 $COMMAND_SCRIPT
singularity exec --nv $NAME ./$COMMAND_SCRIPT
