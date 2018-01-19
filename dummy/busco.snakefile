# rule all:
#    input: 'outputs/busco/run_wild_olive_busco'

rule download_sylv_inputs_busco:
    output: 'inputs/sylvestris/Olea_europaea_all_scaffolds.fa'
    shell:'''
	wget -O inputs/sylvestris/Olea_europaea_all_scaffolds.fa.gz https://osf.io/dzse9/download?version=2 
	gunzip inputs/sylvestris/Olea_europaea_all_scaffolds.fa.gz > {output}
	'''

rule download_busco_db:
    output: 
        db='inputs/busco/embryophyta_odb9/',
        tgz='inputs/busco/embryophyta_odb9.tar.gz'
    conda:  "envs/busco.yml"
    shell:'''
    wget -O {output.tgz} http://busco.ezlab.org/datasets/embryophyta_odb9.tar.gz
	mkdir -p {output.db}
    tar -xf {output.tgz} --strip-components=1 -C {output.db}
    '''
rule run_busco:
    output: 'outputs/busco/run_wild_olive_busco'
    input: 
        genome='inputs/sylvestris/Olea_europaea_all_scaffolds.fa',
        busco_db='inputs/busco/embryophyta_odb9/
    conda:  "envs/busco.yml"
    shell:'''
	python busco/scripts/run_BUSCO.py -i {input.genome} -o wild_olive_busco -l {input.busco_db} -m geno
    '''
    