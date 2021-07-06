import pandas as pd
import pysam
                        
# rule all:
#    input:
#        dynamic("outputs/Oe6/blast/tab/{contig_names}.tab"),
#        dynamic("outputs/sylvestris/blast/tab/{contig_names}.tab")

rule download_Oe6_inputs_blast:
    output: 
        gz='inputs/Oe6/Oe6.scaffolds.fa.gz',
        uncmp='inputs/Oe6/Oe6.scaffolds.fa'
    shell:'''
    	wget -O {output.gz} http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz 
    	gunzip -c {output.gz} > {output.uncmp}
	'''
	
rule download_sylv_inputs_blast:
    output: 
        gz='inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz',  
        uncmp='inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    shell:'''
		wget -O {output.gz} http://olivegenome.org/genome_datasets/Olea_europaea%3E1kb_scaffolds.gz
		gunzip -c {output.gz} > {output.uncmp}
    '''

subworkflow tetramernucleotide_clustering:
    workdir: "tetramernucleotide"
    snakefile: "tetramernucleotide/tetramernucleotide.snakefile"

rule grab_suspicious_contigs_Oe6:
    output: 'outputs/Oe6/suspicious_contigs/Oe6_suspicious_contigs.fa'
    input: 
        contigs=tetramernucleotide_clustering('outputs/Oe6/suspicious_contigs.txt'),
        genome = 'inputs/Oe6/Oe6.scaffolds.fa',
    shell:'''
    ./extract-matches.py {input.contigs} {input.genome} > {output}   
    ''' 

rule grab_suspicious_contigs_sylv:
    output: 'outputs/sylvestris/suspicious_contigs/sylv_suspicious_contigs.fa'
    input: 
        contigs = tetramernucleotide_clustering('outputs/sylvestris/suspicious_contigs.txt'),
        genome = 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa',
    shell:'''
    ./extract-matches.py {input.contigs} {input.genome} > {output}   
    ''' 

num = ['00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51']

rule install_blast_db:
    output: expand('inputs/blast_db/nt.{n}.tar.gz', n = num)
    shell:'''
        cd inputs/blast_db
    	wget 'ftp://ftp.ncbi.nlm.nih.gov/blast/db/nt.*.tar.gz'
    	cat nt.*.tar.gz | tar -zxvi -f - -C .
    '''
   
rule blast_low_similarity_contigs_Oe6: 
    output: 'outputs/Oe6/blast/asn/Oe6_suspicious_contigs.asn'
    input: 
        contig='outputs/Oe6/suspicious_contigs/Oe6_suspicious_contigs.fa',
        db=expand('inputs/blast_db/nt.{n}.tar.gz', n = num)
    conda: "envs/env.yml"
    shell:'''
    	blastn -query {input.contig} -db inputs/blast_db/nt -outfmt 11 -out {output}
    '''

rule blast_low_similarity_contigs_sylv: 
    output: 'outputs/sylvestris/blast/asn/sylv_suspicious_contigs.asn'
    input: 
        contig='outputs/sylvestris/suspicious_contigs/sylv_suspicious_contigs.fa',
        db=expand('inputs/blast_db/nt.{n}.tar.gz', n = num)
    conda: "envs/env.yml"
    shell:'''
    	blastn -query {input.contig} -db inputs/blast_db/nt -outfmt 11 -out {output}
    '''

rule convert_blast_to_tab:
    output: 'outputs/Oe6/blast/tab/Oe6_suspicious_contigs.tab'
    input: 'outputs/Oe6/blast/asn/Oe6_suspicious_contigs.asn'
    conda: "envs/env.yml"
    shell:'''
    	blast_formatter -archive {input} -outfmt 6 -out {output}
    '''

rule convert_blast_to_tab_sylv:
    output: 'outputs/sylvestris/blast/tab/sylv_suspicious_contigs.tab'
    input: 'outputs/sylvestris/blast/asn/sylv_suspicious_contigs.asn'
    conda: "envs/env.yml"
    shell:'''
    	blast_formatter -archive {input} -outfmt 6 -out {output}
    '''
