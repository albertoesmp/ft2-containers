#!/bin/bash

# ---------------------------------------------------------------------------
# AUTHOR : Alberto M. Esmoris Pena
#
# Singularity Tensorflow CNN benchmarking commands for CESGA - FT2 
#
# ---------------------------------------------------------------------------

cd benchmarks/scripts/tf_cnn_benchmarks/
python tf_cnn_benchmarks.py --num_gpus=1 --batch_size=32 --model=resnet50 --variable_update=parameter_server

