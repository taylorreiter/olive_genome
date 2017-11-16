import pandas as pd
                        
suspicious_contigs_Oe6 = pd.read_table('outputs/Oe6/suspicious_contigs.txt')
suspicious_contigs_sylvestris = pd.read_table('outputs/sylvestris/suspicious_contigs.txt')

# rule all:
#    input:
#         expand("outputs/Oe6/{Oe6_suspicious_contigs}.fa",
#                 Oe6_suspicious_contigs = suspicious_contigs_Oe6[0]),
#         expand("outputs/sylvestris/{sylvestris_suspicious_contigs}.fa",
#                 sylvestris_suspicious_contigs = suspicious_contigs_sylvestris[0]),
#         expand("outputs/{genome}/blast/tab/{suspicious_contig}.tab",
#                 genome = [Oe6, sylvestris],
#                 suspicious_contig = suspicious_contigs_Oe6[0] + suspicious_contigs_sylvestris[0])

rule download_Oe6_inputs_blast:
    output: 'inputs/Oe6/Oe6.scaffolds.fa.gz'
    shell:'''
    	wget -O http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz {output}
	'''


rule download_sylv_inputs_blast:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz'  
    shell:'''
		wget -O http://olivegenome.org/genome_datasets/Olea_europaea%3E1kb_scaffolds.gz {output.genome_pruned} # scaffolds larger than 1 kb
	'''
    
rule samtools_index_Oe6:
    output: 'inputs/Oe6/Oe6.scaffolds.fa.fai'
    input: 'inputs/Oe6/Oe6.scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    	samtools faidx Oe6.scaffolds.fa
    '''
rule gunzip_sylvestris:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz'
    shell:'''
    	gunzip {input}
    '''
    
rule samtools_index_sylvestris:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.fai'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    	samtools faidx {input}
    '''
    
rule grab_low_similarity_contigs_Oe6:
    output: 'outputs/Oe6/suspicious_contigs/{Oe6_suspicious_contigs}.fa'
    input: 'inputs/Oe6/Oe6.scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    	samtools faidx {input} {Oe6_suspicious_contigs} > {output}
    '''
                
rule grab_low_similarity_contigs_sylv:
    output: 'outputs/sylvestris/suspicious_contigs/{sylvestris_suspicious_contigs}.fa'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    	samtools faidx {input} {sylvestris_suspicious_contigs} > {output}
    '''
    
rule install_blast_db:
    output: dynamic('inputs/blast_db/{nt}')
    conda: "envs/env.yml"
    shell:'''
    	wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz'
    	cat nt.*.tar.gz | tar -zxvi -f - -C .
    '''
    
rule blast_low_similarity_contigs: 
    output: 'outputs/{genome}/blast/asn/{suspicious_contig}.asn'
    input: 'outputs/{genome}/suspicious_contigs/{suspicious_contig}.fa'
    conda: "envs/env.yml"
    shell:'''
    	blastn -query {input} -db ~/nt_db/nt -outfmt 11 -out {output}
    '''

rule convert_blast_to_tab:
    output: 'outputs/{genome}/blast/tab/{suspicious_contig}.tab'
    input: 'outputs/{genome}/blast/asn/{suspicious_contig}.asn'
    conda: "envs/env.yml"
    shell:'''
    	blast_formatter -archive {input} -outfmt 6 -out {output}
    '''
