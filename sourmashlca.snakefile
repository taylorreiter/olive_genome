# rule all:
#     include:
#         'outputs/sourmash_lca/Oe6.scaffolds-k31.fa.lca.txt',
#         'outputs/sourmash_lca/Olea_europaea_1kb_scaffolds-k31.lca.txt'

# rule download_Oe6_inputs_lca:
#     output: 'inputs/Oe6/Oe6.scaffolds.fa.gz'
#     shell:'''
#     	wget -O http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz {output}
	'''
	
rule download_sylv_inputs_lca:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz'  
    shell:'''
		wget -O http://olivegenome.org/genome_datasets/Olea_europaea%3E1kb_scaffolds.gz {output} # scaffolds larger than 1 kb
	'''

rule compute_sourmash_signature_Oe6_k31:
   output: 'outputs/Oe6/Oe6.scaffolds-k31.fa.sig'
   input: 'inputs/Oe6/Oe6.scaffolds.fa.gz'
   conda:  "envs/env.yml"
   shell:'''
   # compute tetranucleotide frequency of scaffolds
   	sourmash compute -k 31 --scaled 10000 -o {output} {input}
   '''
   
rule compute_sourmash_signature_sylv_k31:
   output: 'outputs/sylvestris/Olea_europaea_1kb_scaffolds-k31.fa.sig'
   input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz'
   conda: "envs/env.yml"
   shell:'''
   # compute tetranucleotide frequency of scaffolds
   	sourmash compute -k 31 --scaled 10000 -o {output} {input}
   '''

rule setup_sourmash_lca:
    output: 'inputs/genbank_lca/genbank.lca.json'
    shell:'''
    	curl -L https://osf.io/2vjkm/download?version=1 -o inputs/genbank_lca/genbank-k31.lca.json.gz
    	tar xzf inputs/genbank_lca/genbank-k31.lca.json.gz
    '''
    
rule run_sourmash_LCA_Oe6:
    output: 'outputs/sourmash_lca/Oe6.scaffolds-k31.fa.lca.txt'
    input:
        genbank='inputs/genbank_lca/genbank-k31.lca.json',
        sig='outputs/Oe6/Oe6.scaffolds-k31.fa.sig'
    conda: "envs/sourmash-lca.yml"
    shell:'''
    	sourmash lca classify -k 31 {input.genbank} {input.sig} > {output}
    '''

rule run_sourmash_LCA_sylv:
    output: 'outputs/sourmash_lca/Olea_europaea_1kb_scaffolds-k31.lca.txt'
    input:
        genbank='inputs/genbank_lca/genbank.lca.json',
        sig='outputs/sylvestris/Olea_europaea_1kb_scaffolds-k31.fa.sig'
    conda: "envs/sourmash-lca.yml"
    shell:'''
    sourmash lca classify -k 31 {input.genbank} {input.sig} > {output}
    '''