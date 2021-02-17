#!/bin/bash --login

###
# job name
#SBATCH --job-name=CombBLAS_0001
# specify its partition
#SBATCH --partition=workq
# job stdout file
#SBATCH --output=CombBLAS_0001.%J.out
# job stderr file
#SBATCH --error=CombBLAS_0001.%J.err
# maximum job time in HH:MM:SS
#SBATCH --time=01:00:00
#SBATCH --ntasks=16
#SBATCH --cpus-per-task=8
# maximum memory
#SBATCH --mem-per-cpu=512M
###

# module restore PrgEnv-gnu
module load perftools-base
module load perftools

# Define experiment name
export EXPERIMENT_NAME=$SLURM_JOB_NAME

# Define allocations
export TOTAL_NC=$SLURM_JOB_NUM_NODES
export COMBBLAS_NC=$TOTAL_NC
export COMBBLAS_PPN=2

# Define directories and files
export COMBBLAS_BASE_DIR=/lus/cls01075/msrinivasa/develop/CombBLAS
export DATA_DIR=./data
export EXPERIMENT_METAFILE=$EXPERIMENT_NAME.README.txt
export EXPERIMENT_JOBFILE=$EXPERIMENT_NAME.JOBFILE.csv
mkdir -p $DATA_DIR

# Write metadata into a README file for the experiment
echo $EXPERIMENT_NAME>$EXPERIMENT_METAFILE
echo "Total Allocation: "$TOTAL_NC>>$EXPERIMENT_METAFILE
echo "CombBLAS Allocation: "$COMBBLAS_NC>>$EXPERIMENT_METAFILE
echo "Nodelist: "$SLURM_JOB_NODELIST>>$EXPERIMENT_METAFILE
# Define a few craypat related environment variables for this jobstep
export PAT_RT_EXPDIR_BASE=$DATA_DIR
# export PAT_RT_EXPFILE_MAX=$LAMMPS_PE_COUNT
mkdir -p $PAT_RT_EXPDIR_BASE

# Record the job start time
export COMBBLAS_START=`date -uI'seconds'`
# Run combblas 
srun $COMBBLAS_BASE_DIR/build/Applications/dobfs 16 \
    > $PAT_RT_EXPDIR_BASE/combblas.dobfs.out
# Record the job end time
export COMBBLAS_END=`date -uI'seconds'`

# record all jobsteps
echo "start_time,end_time,job_id,job_name,user">$EXPERIMENT_JOBFILE
echo $COMBBLAS_START,$COMBBLAS_END,$EXPERIMENT_NAME,$EXPERIMENT_NAME,$USER>>$EXPERIMENT_JOBFILE
