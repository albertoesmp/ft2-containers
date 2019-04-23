#!/bin/bash

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script tests singularity usage
#
# Test is based on USER GUIDE:
#   https://www.sylabs.io/guides/3.0/user-guide/quick_start.html
#
# NOTICE it is recommended that this script is not launched as root since
#   singularity should be used by regular users.
# ----------------------------------------------------------------------------

singularity --debug run library://sylabsed/examples/lolcow
