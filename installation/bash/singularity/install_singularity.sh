#!/bin/bash

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script installs singularity.
#
# Installation is based on USER GUIDE:
#   https://www.sylabs.io/guides/3.0/user-guide/quick_start.html
#
# NOTICE superuser permissions are required in order for this script to work
#   as expected (also, singularity should be installed as root).
# ----------------------------------------------------------------------------


# DEPENDENCIES:
#   - Linux
#   - Go
#   - wget
#   - git
#   - tar
#   - gcc
#   - libssl | openssl-devel
#   - libuuid | libuuid-devel
#   - squashfs-tools

# ---  V A R S  --- #
# ----------------- #
# Linux vars
BASHRC=$HOME'/.bashrc'

# Go vars
GO_URL='https://dl.google.com/go/'
GO_VER='1.12.1'
GO_OS='linux'
GO_ARCH='amd64'
GO_FILE='' # TO BE filled after download_go call
GO_DEPS_URL='github.com/golang/dep/cmd/dep'

# Singularity vars
SING_GIT='https://github.com/sylabs/singularity.git'
SYLABS_PATH='' # TO BE filled after get_singularity call
SING_PATH='' # TO BE filled after compile_singularity call

# Yum vars
YUM_SOLVE_DEPS=false


# ---  FUNCTIONS  --- #
# ------------------- #
function print_help {
cat << EOF
install script for singularity USAGE:
    -h | --help : Print this help
    --yum-deps : When specified the script will try to solve some dependencies
                using yum.

EOF
}

function parse_args {
    for arg in $@; do
        if [ $arg == "-h" ] || [ $arg == '--help' ]; then
            print_help
            exit 0
        fi
        if [ $arg == '--yum-deps' ]; then
            YUM_SOLVE_DEPS=true
        fi
    done
}

function download_go {
    GO_FILE='go'$GO_VER'.'$GO_OS-$GO_ARCH.tar.gz
    if [ ! -f $GO_FILE ]; then
        wget ${GO_URL}${GO_FILE}
    fi
}

function setup_go {
    tar -C /usr/local -xzf $GO_FILE
    echo 'export GOPATH=${HOME}/go' >> $BASHRC
    echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> $BASHRC
    source $BASHRC
}

function get_singularity {
    SYLABS_PATH=$GOPATH/src/github.com/sylabs
    rm -fr $SYLABS_PATH
    mkdir -p $SYLABS_PATH
    cd $SYLABS_PATH
    git clone $SING_GIT
    cd singularity
}

function solve_dependencies {
    # Solve dependencies with yum if specified
    if [ $YUM_SOLVE_DEPS ]; then
        yum -y install wget git tar gcc openssl-devel libuuid-devel \
            squashfs-tools
    fi

    # Solve Go as dependency
    download_go
    setup_go

    # Get singularity (it is its own dependecy)
    get_singularity
    
    # Solve Go dependencies
    go get -u -v $GO_DEPS_URL
}

function compile_singularity {
    SING_PATH=$SYLABS_PATH'/singularity'
    cd $SING_PATH
    ./mconfig
    make -C builddir
    make -C builddir install
}



# ---  M A I N  --- #
# ----------------- #
parse_args $@
solve_dependencies
compile_singularity


