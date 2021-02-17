#!/bin/bash --login

###
# job name
#SBATCH --job-name=gen_report
# specify its partition
#SBATCH --partition=workq
# job stdout file
#SBATCH --output=gen_report.%J.out
# job stderr file
#SBATCH --error=gen_report.%J.err
# maximum job time in HH:MM:SS
#SBATCH --time=02:00:00
#SBATCH --nodes=3
# maximum memory
#SBATCH --mem=128G
###

module restore PrgEnv-cray
module load perftools-base
module load perftools

export LAMMPS_BINARY=/home/users/msrinivasa/develop/lammps/build/lmp+tracing
export GPCNET_BINARY=/home/users/msrinivasa/develop/GPCNET/network_load_test+pat

srun --exclusive --nodes=1 --ntasks=1 /lus/cls01053/msrinivasa/develop/lammps/perftools/genreport.sh \
     /lus/cls01053/msrinivasa/develop/lammps/slurm/E0001/data/lammps/idle/lmp+tracing+25071-1030t \
     $LAMMPS_BINARY &

srun --exclusive --nodes=1 --ntasks=1 /lus/cls01053/msrinivasa/develop/lammps/perftools/genreport.sh \
     /lus/cls01053/msrinivasa/develop/lammps/slurm/E0001/data/lammps/congested/lmp+tracing+25358-1030t \
     $LAMMPS_BINARY &

srun --exclusive --nodes=1 --ntasks=1 /lus/cls01053/msrinivasa/develop/lammps/perftools/genreport.sh \
     /lus/cls01053/msrinivasa/develop/lammps/slurm/E0001/data/gpcnet/network_load_test+pat+186364-1081t \
     $GPCNET_BINARY

# wait till all job steps complete
wait 
