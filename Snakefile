import pandas as pd

include: "olivenucmer.snakefile"
include: "apulnucmer.snakefile"         
include: "orthofinder.snakefile"            
include: "busco.snakefile"
include: "blast.snakefile"

rule all:
    input:
        dynamic("outputs/Oe6/blast/tab/{contig_names}.tab"),
        dynamic("outputs/sylvestris/blast/tab/{contig_names}.tab"),
        'outputs/sourmash_lca/Oe6.scaffolds-k31.fa.lca.txt',
        'outputs/sourmash_lca/Olea_europaea_1kb_scaffolds-k31.lca.txt',
        'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt',
        'outputs/aur-pul-nucmer/Oe6-APvarSan_filter_coords.txt',
        'outputs/aur-pul-nucmer/Oe6-APvarEx_filter_coords.txt',
        'outputs/busco/run_wild_olive_busco',
        'outputs/Results_*_orthofinder'

# OrthoFinder code
# ```
# mkdir olive-genomes
# cd olive-genomes
# wget http://olivegenome.org/genome_datasets/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.gz
# wget http://denovo.cnag.cat/genomes/olive/download/Oe6/OE6A.pep.fa
# gunzip *gz
# mv Olea_europaea.gene.pep.final.chr_and_chrUn_noTE Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fasta
# cd ..
# 
# sudo apt-get install ncbi-blast+
# sudo apt-get install mcl
# wget https://github.com/davidemms/OrthoFinder/releases/download/2.0.0-beta/OrthoFinder-2.0.0.tar.gz
# tar xvf OrthoFinder-2.0.0.tar.gz 
# OrthoFinder-2.0.0/orthofinder -f olive-genomes -og
# 
# ```
# 
# BUSCO completeness code
# ```
# install busco dependencies, augustus, ncbi-blast+, and hmmer, as well as their dependencies.
# sudo apt-get install zlib1g-dev libboost-iostreams-dev g++ ncbi-blast+ hmmer python3
# wget http://bioinf.uni-greifswald.de/augustus/binaries/augustus-3.3.tar.gz
# tar xvf augustus-3.3.tar.gz 
# cd augustus
# make
# sudo make install
# cd ..
# export AUGUSTUS_CONFIG_PATH=~/augustus/config/
# source .bashrc
# 
# Install busco
# git clone https://gitlab.com/ezlab/busco
# cd busco
# sudo python3 setup.py install
#   
# cp busco/config/config.ini.default busco/config/config.ini
# 
# fill in path information in the busco/config/config.ini file. To determine paths, use `which augustus`; `which etraining`, etc.
# 
# download files for busco run
# 
# wget http://olivegenome.org/genome_datasets/Olea_europaea_all_scaffolds.fa.gz
# gunzip Olea_europaea_all_scaffolds.fa.gz 
# wget http://busco.ezlab.org/datasets/embryophyta_odb9.tar.gz
# tar xvf embryophyta_odb9.tar.gz
# python busco/scripts/run_BUSCO.py -i Olea_europaea_all_scaffolds.fa  -o wild_olive -l embryophyta_odb9 -m geno
# 
# * to get around miniconda in the Snakefile, post a config.ini file to import into the environment. 
# ```
