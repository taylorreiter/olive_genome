#!/bin/bash
#PBS -l ncpus=4
#PBS -l walltime=4:00:00
#PBS -l mem=1G
#PBS -A ged

module load anaconda
source activate snakemake

logdir=hpcc/log
mkdir -p $logdir

QSUB="qsub -l nodes=1:ppn={threads} "
QSUB="$QSUB -l walltime={cluster.time} -l mem={cluster.mem}"
QSUB="$QSUB -o $logdir -e $logdir -A ged"

snakemake --unlock

snakemake                               \
    -j 3000                             \
    --local-cores 4                     \
    --cluster-config hpcc/cluster.yaml  \
    --js hpcc/jobscript.sh              \
    --rerun-incomplete                  \
    --cluster "$QSUB"                   \
    --latency-wait 10                   \
    --use-conda                         \
    >>hpcc/log/snakemake.log 2>&1
