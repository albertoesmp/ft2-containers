/*
 * Author: Alberto M. Esmoris Pena
 *
 * MPI Hello world used to illustrate how to run an MPI job through
 * singularity container in a high-performance fashion at CESGA - FT2
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <mpi.h>

int main (int argc, char **argv){
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    printf("P[%2d / %-2d]: Hello from P%d\n",rank,size,rank);

    MPI_Finalize();
    return EXIT_SUCCESS;
}
