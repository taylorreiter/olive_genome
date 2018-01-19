# rule all:
#    input: 'outputs/busco/run_wild_olive_busco'

rule download_sylv_inputs_busco:
    output: 'inputs/sylvestris/Olea_europaea_all_scaffolds.fa'
    shell:'''
	wget -O inputs/sylvestris/Olea_europaea_all_scaffolds.fa.gz https://osf.io/dzse9/download?version=2 
	gunzip inputs/sylvestris/Olea_europaea_all_scaffolds.fa.gz > {output}
	'''

rule download_emb_odb9:
    output: 
        untar='inputs/busco/embryophyta_odb9',
        tar='inputs/busco/embryophyta_odb9.tar.gz'
    conda:  "envs/busco.yml"
    shell:'''
	wget -O {output.tar} http://busco.ezlab.org/datasets/embryophyta_odb9.tar.gz
	tar xvf {output.tar}
    '''
rule run_busco:
    output: 'outputs/busco/run_wild_olive_busco'
    input: 
        genome='inputs/sylvestris/Olea_europaea_all_scaffolds.fa',
        busco_db='inputs/busco/embryophyta_odb9'
    conda:  "envs/busco.yml"
    shell:'''
	python busco/scripts/run_BUSCO.py -i {input.genome} -o wild_olive_busco -l {input.busco_d} -m geno
    '''
    