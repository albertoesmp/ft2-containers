#!/bin/bash

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script configurates udocker.
#
# NOTICE this script should only be used after install_udocker.sh
#
# NOTICE this script should be called as follows:
#       . ./config_udocker.sh
#       source config_udocker.sh
#   Otherwise environment will not be conifgured.

# ----------------------------------------------------------------------------

# ---  FUNCTIONS  --- #
# ------------------- #
# Configures environment vars
function configure_environment {
    # udocker to path
    path=$PWD # path to udocker bin
    aux=$(echo $PATH | grep $path | wc -c)
    if [ $aux -le 1 ]; then
        if [ -d $path ]; then
            export PATH=$PATH:$path
            echo 'udocker successfully added to path!'
        else
            echo 'udocker was not added to path because it was not found at:'
            echo -e '\t"'$f'"\n'
        fi
    else
        echo 'udocker was already on path'
    fi
}


# ---  M A I N  --- #
# ----------------- #
configure_environment


