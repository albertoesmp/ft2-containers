#!/bin/bash

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script installs udocker in CESGA Finisterrae II
#
# Installation is based on INSTALLATION MANUAL:
#   https://github.com/indigo-dc/udocker/blob/master/doc/installation_manual.md
#
# ----------------------------------------------------------------------------

# DEPENDENCIES:
#   - Linux
#   - python
#   - pycurl
#   - curl


# ---  FUNCTIONS  --- #
# ------------------- #
function download_udocker {
    curl https://raw.githubusercontent.com/indigo-dc/udocker/master/udocker.py > udocker
}

function install_udocker {
    chmod u+rx ./udocker
    ./udocker install
}


# ---  M A I N  --- #
# ----------------- #
download_udocker
install_udocker
