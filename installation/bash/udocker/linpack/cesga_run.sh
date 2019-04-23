#!/bin/bash
#SBATCH -p thinnodes
#SBATCH -n 16
#SBATCH -t 09:00:00

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script starts an udocker container, building the image if required, to
# run the Linkpack benchmark on it.
#
# This version of run.sh is specially designed to be run on
# CESGA FinisTerrae-II
#
# ----------------------------------------------------------------------------

# ---  V A R S  --- #
# ----------------- #
LINPACK_SCRIPT='linpack_udocker.sh'
IMAGE='albertoesmp/centos-linpack'
CONTAINER='centos-linpack-cesga'
HOST_DIR=$HOME/linpack/shared
CONTAINER_DIR=/linpack/shared



# ---  M A I N  --- #
# ----------------- #
echo '>>> Configuring uDocker'
chmod 755 ../config_udocker.sh
init_dir=$(pwd)
cd ..
. ./config_udocker.sh
cd $init_dir
echo '>>> Making "'$HOST_DIR'"'
mkdir -p $HOST_DIR
echo -e '-------------------------------\n'
echo '>>> Moving "'$LINPACK_SCRIPT'" to "'$HOST_DIR'"'
cp $LINPACK_SCRIPT $HOST_DIR/$LINPACK_SCRIPT
echo '>>> Retrieving docker image ...'
udocker pull $IMAGE
echo -e '-------------------------------\n'
echo '>>> Removing old container (Error is not relevant) ...'
# Error is not relevant and may occurr often because the container is executed
# with --rm so it selfdestroys after execution.
# However, this step is cool because if container was not destroyed for
# any reason, it will be before creating a new one, so undesired scenarios
# are avoided.
udocker rm $CONTAINER
echo -e '-------------------------------\n'
echo '>>> Creating new container ...'
udocker create --name=$CONTAINER $IMAGE
echo -e '-------------------------------\n'
echo '>>> Configuring new container ...'
udocker setup --execmode=F2 $CONTAINER
echo -e '-------------------------------\n\n'
echo '/!\  EXECUTION BEGINS  /!\'
udocker run --hostauth --user=$(whoami) --rm --volume=$HOST_DIR:$CONTAINER_DIR --volume=/tmp:/tmp $CONTAINER
