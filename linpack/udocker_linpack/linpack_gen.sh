#!/bin/bash


# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script downloads, compile and configure the linpack benchmark.
#
# Linpack is obtained from:
#   http://www.netlib.org/benchmark/hpl/
#
# ----------------------------------------------------------------------------


# ---  V A R S  --- #
# ----------------- #
# General vars
ROOT_DIR=$PWD
GEN_DIR=$ROOT_DIR'/gen'
SETUPS_DIR=$ROOT_DIR'/setups'

# Linpack vars
LINPACK_PACKAGE='hpl-2.3'
LINPACK_URL='http://www.netlib.org/benchmark/hpl/'$LINPACK_PACKAGE'.tar.gz'
LINPACK_FILE=$GEN_DIR'/'$LINPACK_PACKAGE'.tar.gz'
LINPACK_DIR=$GEN_DIR'/'$LINPACK_PACKAGE
LINPACK_ARCH='Linux_OMPI'
LINPACK_MAKE='' # TO BE filled by compile_linpack
LINPACK_BIN_DIR='' # TO BE filled by compile_linpack
LINPACK_BIN_FILE='' # TO BE filled by compile_linpack
LINPACK_CONF_FILE='' # TO BE filled by tune_linpack


# ---  FUNCTIONS  --- #
# ------------------- #
function prepare_environment {
    module load gcc openmpi/2.1.5
    module load openblas
}

function get_linpack {
    mkdir -p $GEN_DIR
    if [ ! -f $LINPACK_FILE ]; then
        echo 'Downloading to: '$LINPACK_FILE
        wget -c $LINPACK_URL -O $LINPACK_FILE
        echo 'Downloaded!'
    else
        echo 'There is no need to download from  "'$LINPACK_URL'" as '
        echo 'it is already available as "'$LINPACK_FILE'"'
    fi
    
    rm -fr $LINPACK_DIR
    cd $GEN_DIR
    tar xzvf $LINPACK_FILE
}

function solve_dependencies {
    # BLAS
    wget -c $BLAS_URL -O $BLAS_FILE
    tar xzvf $BLAS_FILE
    cd $BLAS_DIR
    make

    # CBLAS
    cd $GEN_DIR
    wget -c $CBLAS_URL -O $CBLAS_FILE
    tar xzvf $CBLAS_FILE
    cd $CBLAS_DIR
    aux=$(sed 's/\//\\\//g' <<< ${BLAS_LINUX_A})
    sed 's/BLLIB =.*/BLLIB = '$aux'/g' $CBLAS_MAKE_IN > $CBLAS_MAKE_MY
    mv $CBLAS_MAKE_MY $CBLAS_MAKE_IN
    make
}

function compile_linpack {
    cd $LINPACK_DIR
    LINPACK_MAKE=Make.${LINPACK_ARCH}
    aux=$(sed 's/\//\\\//g' <<< $(pwd))
    sed 's/$(HOME)\/hpl/'$aux'/g' $SETUPS_DIR'/Make.'${LINPACK_ARCH} > ${LINPACK_MAKE}
    make arch=${LINPACK_ARCH}
    LINPACK_BIN_DIR=${LINPACK_DIR}/bin/${LINPACK_ARCH}
    LINPACK_BIN_FILE=${LINPACK_BIN_DIR}/xhpl
}

function tune_linpack {
    echo -e '\nTunning linpack ...\n'
    LINPACK_CONF_FILE=$LINPACK_BIN_DIR'/HPL.dat'
    LINPACK_OUT_DIR='' # TO BE filled by exec_linpack
cat << EOF > $LINPACK_CONF_FILE
Computational expensive configuration
by Alberto M. Esmoris Pena 
$LINPACK_RESULT             output file name (if any)
6                           device out (6=stdout,7=stderr,file)
5                           # of problems sizes (N) 
100 500 1000 3000 10000     Ns  
9                           # of NBs 
1 2 4 8 16 32 64 128 256    NBs 
0                           PMAP process mapping (0=Row-,1=Column-major)
5                           # of process grids (P x Q)
2 8 4 1 16                  Ps  
8 2 4 16 1                  Qs  
16.0                        threshold
3                           # of panel fact
0 1 2                       PFACTs (0=left, 1=Crout, 2=Right)
2                           # of recursive stopping criterium
2 4                         NBMINs (>= 1)
1                           # of panels in recursion
2                           NDIVs
3                           # of recursive panel fact.
0 1 2                       RFACTs (0=left, 1=Crout, 2=Right)
1                           # of broadcast
0                           BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1                           # of lookahead depth
0                           DEPTHs (>=0)
2                           SWAP (0=bin-exch,1=long,2=mix)
64                          swapping threshold
0                           L1 in (0=transposed,1=no-transposed) form
0                           U  in (0=transposed,1=no-transposed) form
1                           Equilibration (0=no,1=yes)
8                           memory alignment in double (> 0)
EOF
    echo -e '\nLinpack tunned!\n'
}


# ---  M A I N  --- #
# ----------------- #
prepare_environment
get_linpack
compile_linpack
tune_linpack
