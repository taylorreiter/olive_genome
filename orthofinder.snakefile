#rule all:
#    input: 'outputs/Results_*_orthofinder'

rule download_Oe6_inputs_orthofinder:
    output: 'inputs/peptides/OE6A.pep.fa'
    shell:'''
    wget -O {output} http://denovo.cnag.cat/genomes/olive/download/Oe6/OE6A.pep.fa 
	'''

rule download_sylv_inputs_orthofinder:
    output: 
        gz='inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa.gz',
        uncmp='inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa'
    shell:'''
	wget -O {output.gz} http://olivegenome.org/genome_datasets/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.gz 
	gunzip -c {output.gz} > {output.uncmp}
	'''
    
# Orthofinder does not allow use specified output directory. 
# Automatically places a directory with the results under the directory in which the protein fasta sequences are listed. 
# Additionally, the output directory is always named Results_*, where the asterisk is the date in the United Kingdom at the moment the program is being run.
# The format for the date is Mon_Day (i.e. Jan_20). 
# The correct date therefore needs to be changed each time a run is made.  
# Date is specified as a variable in the master Snakefile. 
rule run_orthofinder:
    output: 
        'inputs/peptides/Results_{date}/Orthogroups.csv',
        'inputs/peptides/Results_{date}/Orthogroups.txt',
        'inputs/peptides/Results_{date}/Orthogroups_UnassignedGenes.csv',
        'inputs/peptides/Results_{date}/Orthogroups.GeneCount.csv',
        'inputs/peptides/Results_{date}/Statistics_Overall.csv',
        'inputs/peptides/Results_{date}/Statistics_PerSpecies.csv' #,
        #'input/peptides/Results_{date}/WorkingDirectory/Blast0_0.txt',
        #'input/peptides/Results_{date}/WorkingDirectory/clusters_OrthoFinder_v1.1.10_I1.5.txt_id_pairs.txt',
        #'input/peptides/Results_{date}/WorkingDirectory/SequenceIDs.txt',
        #'input/peptides/Results_{date}/WorkingDirectory/SpeciesIDs.txt',
        #'input/peptides/Results_{date}/WorkingDirectory/clusters_OrthoFinder_v1.1.10_I1.5.txt',
        #'input/peptides/Results_{date}/WorkingDirectory/OrthoFinder_v1.1.10_graph.txt',
        #'input/peptides/Results_{date}/WorkingDirectory/Species0.fa'        
    input: 
        'inputs/peptides/Olea_europaea.gene.pep.final.chr_and_chrUn_noTE.fa',
        'inputs/peptides/OE6A.pep.fa'
    conda: 'envs/env.yml'
    shell:'''
	orthofinder -f inputs/peptides -og
	'''    