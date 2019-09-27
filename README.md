This workflow includes analyses to find contamination in the domesticated olive genome. The results are presented in [this preprint](https://www.biorxiv.org/content/10.1101/499541v1.full).

This workflow was run on a amazon aws instance (ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20171026.1 (ami-1c1d217c)). To run this workflow, you must first install and configure miniconda (or anaconda if you prefer).

Install miniconda
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh 
```

Run through the prompts.

Configure miniconda and create an environment
```
conda config --add channels r
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge


conda create -n snakemake python==3.6 snakemake=4.3.0 pysam=0.13 pandas=0.20.3 numpy=1.13.3 sourmash=2.0.0a2

conda activate snakemake
```

Then, run the workflow:
```
snakemake --use-conda -k
```

Currently, the all rule `dynamic("outputs/sylvestris/blast/tab/{contig_names_sylv}.tab")` in the `Snakefile` is commented out. This means that the pipeline will only output Oe6 relevant files. To output sylvestris files, uncomment the rule, and comment the Oe6 rule. 



