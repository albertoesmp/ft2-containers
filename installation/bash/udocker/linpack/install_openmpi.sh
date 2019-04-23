#!/bin/bash


# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script can be used to install OpenMPI
#
# OpenMPI is obtained from:
#   https://www.open-mpi.org
#
# ----------------------------------------------------------------------------

# DEPENDENCIES
# - openib
# - libibverbs
# - libibverbs-utils
# - libibverbs-devel
# - librdmacm
# - librdmacm-utils
# - ibacm
# - libnes
# - libibumad
# - libfabric, libfabric-devel
# - opensm-libs
# - swig
# - ibutils-libs, ibutils
# - opensm
# - libibmad
# - infiniband-diags
# - Infiniband driver, for instance: Mellanox -> mlx4
# - libsysfs, libsysfs-devel


# ---  V A R S  --- #
# ----------------- #
ROOT_DIR='/linpack' # Directory where installation will be operated
WORK_DIR=$ROOT_DIR'/openmpi_tmp' # Directory used to compile
MPI_VERSION='2.1.5' # Version of OpenMPI to install
MPI_PACKAGE='openmpi-'$MPI_VERSION'.tar.gz' # OpenMPI Package (MUST be tar.gz)
MPI_FOLDER=$WORK_DIR'/openmpi-'$MPI_VERSION # Extraction path, based on the tar
MPI_URL='https://download.open-mpi.org/release/open-mpi/v2.1/'$MPI_PACKAGE
MPI_INSTALL_DIR='/linpack/openmpi-'$MPI_VERSION # Directory to store final OMPI


# ---  FUNCTIONS  --- #
# ------------------- #
function get_ompi {
    echo '>>> DOWNLOAD'
    mkdir -p $WORK_DIR
    cd $WORK_DIR
    wget -c $MPI_URL -O $MPI_PACKAGE
    tar xzvf $MPI_PACKAGE
}

function compile_ompi {
    echo '>>> COMPILE'
    cd $MPI_FOLDER
    mkdir -p $MPI_INSTALL_DIR
    ./configure --with-verbs --prefix=$MPI_INSTALL_DIR
    make
    make install

}

function conf_ompi {
    echo '>>> CONFIG'
}

function clean_ompi {
    echo '>>> CLEAN'
    rm -fr $WORK_DIR
}


# ---  M A I N  --- #
# ----------------- #
get_ompi
compile_ompi
conf_ompi
clean_ompi
