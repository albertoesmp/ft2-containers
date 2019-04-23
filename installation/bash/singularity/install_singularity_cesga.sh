#!/bin/bash

# ----------------------------------------------------------------------------
# Author: Alberto M. Esmoris Pena
# 
# This script installs singularity in CESGA Finisterrae II
#
# Installation is based on USER GUIDE:
#   https://www.sylabs.io/guides/3.0/user-guide/quick_start.html
#
# NOTICE installation may faill if stack size is too high:
#   Singularity installation uses multiple pthreads which, despite the
#   amount of memory they really use, require to have available
#   as much memory as specified soft stack limit (ulimit -Ss)
#
#   To prevent problems derived from this sceneario, stack soft limit
#   should be checked because if it is too high and virtual memory limit
#   too low, installation will fail.
#
#   Solving this problem can be done specifying a soft stack size of 8MiB:
#       ulimit -Ss 8192
#       (ulimit stack size is specified in KiB so 8192KiB -> 8MiB)
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
#   - zlib
#   - squashfs-tools


# ---  V A R S  --- #
# ----------------- #
START_DIR=$PWD # Dir where script call started (MUST be the script folder)

# Go vars
GO_URL='https://dl.google.com/go/'
GO_VER='1.12.1'
GO_OS='linux'
GO_ARCH='amd64'
GO_FILE='' # TO BE filled after download_go call
GO_DEPS_URL='github.com/golang/dep/cmd/dep'
GO_INSTALL_DIR='/tmp/go/install'

# Singularity vars
SING_VERSION='3.1.0' # /!\ WARNING: Verison must match the downloaded one
SING_GIT='https://github.com/sylabs/singularity.git' # REMEMBER to check version match
SYLABS_PATH='' # TO BE filled after get_singularity call
SING_PATH='' # TO BE filled after compile_singularity call
# Path where singularity'll be installed
#SING_INSTALL_PATH=$HOME'/singularity-'$SING_VERSION
SING_INSTALL_PATH='/opt/cesga/singularity/'$SING_VERSION
SING_CONF_PATH=$SING_INSTALL_PATH'/etc/singularity/singularity.conf'
SING_BIN_FOLDER=$SING_INSTALL_PATH'/bin' # Singularity binary files folder

# Squashfs vars
SQFS_TAR=$START_DIR'/squashfs4.3.tar.gz' # squashfs-tools tar path
SQFS_DIR=$START_DIR'/squashfs4.3' # squashfs-tools untar path
# Path where squashfs-tools binaries will be placed
SQFS_INSTALL_PATH=$SING_INSTALL_PATH'/squashfs-tools'

# LMOD vars
LMOD_SING_DST_DIR='/opt/cesga/modulefiles/Core/singularity'
LMOD_SIGN_SRC_DIR=$START_DIR'/lmod'


# ---  FUNCTIONS  --- #
# ------------------- #
function print_help {
cat << EOF
install script for singularity USAGE:
    -h | --help : Print this help

EOF
}

function parse_args {
    for arg in $@; do
        if [ $arg == "-h" ] || [ $arg == '--help' ]; then
            print_help
            exit 0
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
    rm -fr $GO_INSTALL_DIR
    mkdir -p $GO_INSTALL_DIR
    tar -C $GO_INSTALL_DIR -xzf $GO_FILE
    export GOPATH=$HOME/go
    export PATH=${PATH}:${GO_INSTALL_DIR}/go/bin
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
    # Load required modules
    module load gcc
    module load libuuid
    module load wget
    module load gnutls # libssl dependency

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
    mkdir -p $SING_INSTALL_PATH
    chmod 755 mconfig
    ./mconfig --without-suid --localstatedir=/tmp --prefix=$SING_INSTALL_PATH
    make -C builddir
    make -C builddir install
}

function compile_squashfs_tools {
    module load zlib
    cd $START_DIR
    rm -fr $SQFS_DIR 
    tar xzvf $SQFS_TAR # Extracting tar generates SQFS_DIR
    cd $SQFS_DIR'/squashfs-tools'
    
    # Include sysmacros is required to avoid compilation problems at FT2
    mksquashfs_src='mksquashfs.c'
    unsquashfs_src='unsquashfs.c'
    sed '30i #include <sys/sysmacros.h>' $mksquashfs_src > $mksquashfs_src'.new'
    sed '26i #include <sys/sysmacros.h>' $unsquashfs_src > $unsquashfs_src'.new'
    mv $mksquashfs_src'.new' $mksquashfs_src
    mv $unsquashfs_src'.new' $unsquashfs_src

    make
    if [ $? -eq 0 ]; then
        mkdir -p $SQFS_INSTALL_PATH
        mv mksquashfs $SQFS_INSTALL_PATH
        mv unsquashfs $SQFS_INSTALL_PATH
    else
        echo 'ERROR compiling squashfs-tools'
        echo -e '\tSingularity images may not be usable'
    fi
}

function config_singularity {
    # Singularity conf file
    aux=$(sed 's/\//\\\//g' <<< $SQFS_INSTALL_PATH'/mksquashfs')
    sed 's/# mksquashfs path =/mksquashfs path = '$aux'/g' \
        $SING_CONF_PATH > $SING_CONF_PATH'.new'
    mv $SING_CONF_PATH'.new' $SING_CONF_PATH
    
    # Script to wrap singularity so it is invoked with an adequate stack
    # soft limit (ulimit -Ss)
    aux=$SING_BIN_FOLDER'/singularity' # Old singularity bin path
    sing_bin=$SING_BIN_FOLDER'/_singularity' # New singularity bin path
    mv $aux $sing_bin
    sing_sh=$SING_BIN_FOLDER'/singularity' # bash wrapper path
cat << EOF > $sing_sh
#!/bin/bash                                                                                                                                                                                                                                                                          
# Author: Alberto M. Esmoris Pena
# Wrapper for singularity which configures stack size before invoking binary

# Path to real singularity binary
SINGULARITY_BIN=$sing_bin

# Stack size in KB
STACK_SIZE=8192 

ulimit -Ss \$STACK_SIZE
\$SINGULARITY_BIN \$@

EOF
    chmod 755 $sing_sh
}


# ---  M A I N  --- #
# ----------------- #
parse_args $@
solve_dependencies
compile_singularity
compile_squashfs_tools
config_singularity
