logdir=farm/log
mkdir -p $logdir

source modules.farm

SUB="sbatch -N 1 -n {threads} "
SUB="$SUB -t {cluster.time} --mem={cluster.mem}"
QSUB="$SUB -o $logdir/o-%j -e $logdir/e-%j"

snakemake                               \
    -j 100                              \
    --cluster-config farm/cluster.yaml  \
    --js farm/jobscript.sh              \
    --rerun-incomplete                  \
    --keep-going                        \
    --latency-wait 10                   \
    --max-jobs-per-second 1             \
    --use-conda                         \
    --cluster "$SUB" $@
