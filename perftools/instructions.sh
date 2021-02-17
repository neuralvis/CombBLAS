# Instrumenting lammps

## Set the environment

```bash
module restore PrgEnv-cray
module load perftools-base perftools
```
## Build ComBLAS

```bash
cd ComBLAS
mkdir _build
cd _build

CC=`which cc` CXX=`which CC` \
cmake .. \
-DCMAKE_INSTALL_PREFIX=../_install \
-DMPIEXEC_NUMPROC_FLAG=-n \
-DMPIEXEC_EXECUTABLE=`which srun` \
-DMPIEXEC_MAX_NUMPROCS=16

make -j16
```

## Instrument the executable `dobfs`



```bash
cd _build/Applications

# for sampling experiment
pat_build -Drtenv=PAT_RT_SUMMARY=1 -Drtenv=PAT_RT_TRACE_HOOKS=1 -u dobfs -o dobfs+sampling

# for tracing experiment
pat_build -g mpi -Drtenv=PAT_RT_SUMMARY=1 -Drtenv=PAT_RT_TRACE_HOOKS=1 -u dobfs -o dobfs+tracing

```

### Notes

* `-Drtenv=PAT_RT_TRACE_HOOKS=1` enables data from compiler hooks (i.e. `-finstrument-loops` above) to be captured in the craypat output. This one is not relevant since we are not enabling loop instrumentation
* Using `-Drtenv=PAT_RT_SUMMARY=0` - i.e. disabling runtime summarization and data aggregation will **not** print any loop data

## Run dobfs

```bash
cd build/Applications
srun -n 16 -c 8 ./dobfs 16
```
