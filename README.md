This workflow was run on a amazon aws instance (ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20171026.1 (ami-1c1d217c)).

To run this workflow, you must first install and configure miniconda (or anaconda if you prefer).

```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh 
```

Run through the prompts.

```
conda config --add channels r
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda

conda create -n snakemake snakemake=4.0 pysam=0.13 pandas=0.20.3 numpy=1.13.3 

source activate snakemake
