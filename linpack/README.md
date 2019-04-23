# Linpack for FT2
> Script for generating High Performance Linpack ready to use at CESGA FinisTerrae-II
* **base** - Linpack scripts for direct execution on CESGA FT2
* **singularity\_linpack** Linpack scripts for execution on CESGA FT2 through singularity CentOS container
* **udocker\_linpack** Linpack scripts for execution on CESGA FT2 through udocker CentOS container
* **linpack\_analyzer** Python script for plotting linpack results comparisson through bar chart

### Base usage

> Just go to script directory and invoke it as follows

```shell
./linpack_gen.sh
```

Notice you can build as many setups as you want.
Just remember to change the LINPACK\_ARCH variable inside the script to specify
your new setup.

> For instance, considering you have made a Make.MySetup
```shell
LINPACK_ARCH=MySetup
```

> To run the benchmark the linpack\_run.sh script can be used in two different ways:

Running locally without submitting to job queue, for testing purposes:
```shell
./linpack_run.sh
```

Submit to job queue, for real benchmarking:
```shell
sbatch linpack_run.sh
```

### Singularity usage
> To run linpack benchmark through singularity at CESGA FT2
```shell
sbatch run_mpi.sh
```

### Udocker usage
> To run linpack benchmark through udocker at CESGA FT2
```shell
sbatch run_mpi.sh
```

### Linpack analyzer usage
> To run analysis
```shell
python3 main.py config_CPU16_full.cfg
```

> Config file syntax is as follows
```
<Number of test to compare>
<Test 1 name>
<Test 1 benchmark output path>
...
<Test N name>
<Test N benchmark output path>
<Output dir where plots will be exported>
```
