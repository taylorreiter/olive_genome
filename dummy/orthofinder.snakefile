#rule all:
#    input: 'outputs/Results_*_orthofinder'

rule download_Oe6_inputs_orthofinder:
    output: 
        gz = 'inputs/peptides/OE6A.pep.fa.gz',
        uncmp = 'inputs/peptides/OE6A.pep.fa'
    shell:'''
    wget -O {output.gz} https://osf.io/c3m9a/download?version=1 
    gunzip -c {output.gz} > {output.uncmp}
	'''

rule download_sylv_inputs_orthofinder:
    output: 
        gz='inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa.gz',
        uncmp='inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa'
    shell:'''
	wget -O {output.gz} https://osf.io/t9f4s/download?version=1 
	gunzip -c {output.gz} > {output.uncmp}
	'''

# Orthofinder does not allow use specified output directory. 
# Automatically places a directory with the results under the directory in which the protein fasta sequences are listed. 
# Additionally, the output directory is always named Results_*, where the asterisk is the date in the United Kingdom at the moment the program is being run.
# The format for the date is Mon_Day (i.e. Jan_20). 
# Use cp to move the folder to the outputs directory under the name orthofinder. 
# This is not an ideal patch, but it works.

rule run_orthofinder:
    output: 'outputs/orthofinder/'
    input: 
        'inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa',
        'inputs/peptides/OE6A.pep.fa'
    conda: 'envs/env.yml'
    shell:'''
	orthofinder -f inputs/peptides -og
	cp -a inputs/peptides/Results*/. {output}
	'''
