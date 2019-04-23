#!/bin/bash

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script starts an udocker container, building the image if required, to
# run the Linkpack benchmark on it.
#
# ----------------------------------------------------------------------------

# ---  V A R S  --- #
# ----------------- #
LINPACK_SCRIPT='linpack_udocker.sh'
IMAGE='albertoesmp/centos-linpack'
HOST_DIR=$HOME/linpack/shared
CONTAINER_DIR=/linpack/shared


# ---  M A I N  --- #
# ----------------- #
mkdir -p $HOST_DIR
cp $LINPACK_SCRIPT $HOST_DIR/$LINPACK_SCRIPT
if [ -x "$(command -v chcon)" ];  then
    # Required to avoid selinux conflicts
    chcon -Rt svirt_sandbox_file_t $HOST_DIR
fi
udocker run --rm --volume=$HOST_DIR:$CONTAINER_DIR $IMAGE
