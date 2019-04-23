#!/bin/bash


# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script uses docker (NOT udocker) to build the linpack benchmark image.
#
# NOTICE this script requires enough docker permissions to build an image so,
# depending on your docker configuration, this may require root permissions
# or not.
# ----------------------------------------------------------------------------

# Please be fair and use your own builder name, thx :)
BUILDER='albertoesmp'

docker build -t ${BUILDER}/centos-linpack .
