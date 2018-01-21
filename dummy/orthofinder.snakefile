#rule all:
#    input: 'outputs/Results_*_orthofinder'

rule download_Oe6_inputs_orthofinder:
    output: 
        gz = 'inputs/peptides/OE6A.pep.fa.gz',
        uncmp = 'inputs/peptides/OE6A.pep.ta'
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
rule run_orthofinder:
    output: 
        'outputs/orthofinder/Orthogroups.csv',
        'outputs/orthofinder/Orthogroups.txt',
        'outputs/orthofinder/Orthogroups_UnassignedGenes.csv',
        'outputs/orthofinder/Orthogroups.GeneCount.csv',
        'outputs/orthofinder/Statistics_Overall.csv',
        'outputs/orthofinder/Statistics_PerSpecies.csv',
        'outputs/orthofinder/WorkingDirectory/Blast0_0.txt',
        'outputs/orthofinder/WorkingDirectory/clusters_OrthoFinder_v1.1.10_I1.5.txt_id_pairs.txt',
        'outputs/orthofinder/WorkingDirectory/SequenceIDs.txt',
        'outputs/orthofinder/WorkingDirectory/SpeciesIDs.txt',
        'outputs/orthofinder/WorkingDirectory/clusters_OrthoFinder_v1.1.10_I1.5.txt',
        'outputs/orthofinder/WorkingDirectory/OrthoFinder_v1.1.10_graph.txt',
        'outputs/orthofinder/WorkingDirectory/Species0.fa'        
    input: 
        'inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa',
        'inputs/peptides/OE6A.pep.fa'
    conda: 'envs/env.yml'
    shell:'''
	orthofinder -f inputs/peptides -og
	mv inputs/peptides/Results* outputs/orthofinder/
	'''