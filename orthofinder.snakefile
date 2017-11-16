#rule all:
#    input: 'outputs/Results_*_orthofinder'

rule download_Oe6_inputs_orthofinder:
    output: 'inputs/peptides/OE6A.pep.fa'
    shell:'''
    wget -O http://denovo.cnag.cat/genomes/olive/download/Oe6/OE6A.pep.fa {output}
	'''

rule download_sylv_inputs_orthofinder:
    output: 'inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa.gz'
    shell:'''
	wget -O http://olivegenome.org/genome_datasets/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.gz {output}
	'''
    
rule run_orthofinder:
    output: 'outputs/Results_*_orthofinder'
    input: 'inputs/peptides/'
    conda: 'envs/env.yml'
    shell:'''
    cd outputs
	orthofinder -f {input} -og
	'''
    