#rule all:
#    input: 'outputs/Results_*_orthofinder'

rule download_Oe6_inputs_orthofinder:
    output: 'inputs/peptides/OE6A.pep.fa'
    shell:'''
    wget -O {output} https://osf.io/c3m9a/download?version=1 
	'''

rule download_sylv_inputs_orthofinder:
    output: 
        gz='inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa.gz',
        uncmp='inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa'
    shell:'''
	wget -O {output.gz} https://osf.io/t9f4s/download?version=1 
	gunzip -c {output.gz} > {output.uncmp}
	'''
    
rule run_orthofinder:
    output: dynamic('outputs/{results_orthofinder}')
    input: 
        'inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa.gz',
        'inputs/peptides/OE6A.pep.fa'
    conda: 'envs/env.yml'
    shell:'''
    cd outputs
	orthofinder -f ../inputs/peptides -og
	'''
    