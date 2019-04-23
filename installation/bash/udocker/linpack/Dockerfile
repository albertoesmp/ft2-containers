# Author: Alberto M. Esmoris Pena

# Use centos base image
FROM centos


# Mantainer
LABEL maintainer="albertoesmp@gmail.com"


# Get what is needed for work to be done
RUN yum -y install wget tar make
RUN yum -y install gcc
RUN yum -y install blas-devel
RUN mkdir -p /linpack


# OpenMPI over Infiniband dependencies
RUN yum -y install epel-release
RUN yum -y install opensm libibverbs libibverbs-utils
RUN yum -y install librdmacm librdmacm-utils ibacm
RUN yum -y install libibumad libfabric libfabric-devel
RUN yum -y install opensm-libs swig ibutils ibutils-libs
RUN yum -y install opensm libibmad infiniband-diags
RUN yum -y install libsysfs libsysfs-devel rdma-core-devel
RUN yum -y install rsh


# OpenMPI general dependencies
RUN yum -y install gcc-c++


# OpenMPI installation
ADD install_openmpi.sh /linpack/install_openmpi.sh
RUN chmod 755 /linpack/install_openmpi.sh
WORKDIR /linpack
RUN ./install_openmpi.sh


# Create non-root user (MPI prefers to execute as non-root)
RUN useradd -ms /bin/bash user
USER user


# Configure what has to be configured
ENV PATH="${PATH}:/linpack/openmpi-2.1.5/bin"



# Create shared volume
USER root
RUN mkdir -p /linpack/shared
VOLUME /linpack/shared


# Add Make
ADD setups /linpack/setups
RUN chown -R user. /linpack
USER user


# Execute linpack benchmark
WORKDIR /linpack/shared/
CMD /linpack/shared/linpack_udocker.sh
