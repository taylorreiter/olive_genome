# rule all:
#    input: 'outputs/busco/run_wild_olive_busco'

rule download_sylv_inputs_busco:
    output: 
        gz='inputs/sylvestris/Olea_europaea_all_scaffolds.fa.gz',
        uncmp='inputs/sylvestris/Olea_europaea_all_scaffolds.fa'
    shell:'''
	wget -O {output.gz} http://olivegenome.org/genome_datasets/Olea_europaea_all_scaffolds.fa.gz 
	gunzip -c {output.gz} > {output.uncmp}
	'''

rule download_busco_db:
    output: 
        db='inputs/busco/embryophyta_odb9/',
        tgz='inputs/busco/embryophyta_odb9.tar.gz'
    shell:'''
    wget -O {output.tgz} http://busco.ezlab.org/datasets/embryophyta_odb9.tar.gz
	mkdir -p {output.db}
    tar -xf {output.tgz} --strip-components=1 -C {output.db}
    '''
rule run_busco:
    output: 'outputs/busco/run_wild_olive_busco'
    input: 
        genome='inputs/sylvestris/Olea_europaea_all_scaffolds.fa',
        busco_db='inputs/busco/embryophyta_odb9'
    conda:  "envs/busco.yml"
    shell:'''
	run_busco -i {input.genome} -o wild_olive_busco -l {input.busco_db} -m geno
        mv run_wild_olive_busco {output}
    '''
