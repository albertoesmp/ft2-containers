#!/bin/bash
#SBATCH -p gpu-shared
#SBATCH --gres=gpu
#SBATCH -t 00:30:00

# ---------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Tensorflow CNN benchmarking for CESGA - FT2
#
# ---------------------------------------------------------------------------


# ---  V A R S  --- #
# ----------------- #
GIT_URL='https://github.com/tensorflow/benchmarks'
GIT_BRANCH='cnn_tf_v1.5_compatible'
BENCHMARKS_DIR='benchmarks'
CONTAINER_URI='docker://tensorflow/tensorflow:latest-gpu'
NAME="singularity_tensorflow.sif"
COMMAND_SCRIPT="tfcnn_commands.sh"

# ---  EXECUTION  --- #
# ------------------- #
# Load modules
module load curl # Used to load CA-certificates and avoid problems when cloning
module load gcc/6.4.0
module load tensorflow/1.7.0-python-2.7.15-cuda-9.1.85

# Get benchmark
if [ -d $BENCHMARKS_DIR ]; then
    echo '"'$BENCHMARKS_DIR'" already exists!'
    echo -e '\t(There is no need to download what you already have) :)'
else
    git config --global http.sslVerify false
    git clone --single-branch --branch $GIT_BRANCH $GIT_URL
fi

# Run benchmark
cd benchmarks/scripts/tf_cnn_benchmarks/
python tf_cnn_benchmarks.py --num_gpus=1 --batch_size=32 --model=resnet50 --variable_update=parameter_server
