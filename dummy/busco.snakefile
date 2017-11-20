# rule all:
#    input: 'outputs/busco/run_wild_olive_busco'

rule download_sylv_inputs_busco:
    output: 'inputs/sylvestris/Olea_europaea_all_scaffolds.fa'
    shell:'''
	wget -O https://osf.io/dzse9/download?version=1 | gunzip > {output}
	'''

rule run_busco:
    output: 'outputs/busco/run_wild_olive_busco'
    input: 'inputs/sylvestris/Olea_europaea_all_scaffolds.fa'
    conda:  "envs/busco.yml"
    shell:'''
	wget http://busco.ezlab.org/datasets/embryophyta_odb9.tar.gz
	tar xvf embryophyta_odb9.tar.gz
	python busco/scripts/run_BUSCO.py -i {input} -o wild_olive_busco -l embryophyta_odb9 -m geno
    '''
    