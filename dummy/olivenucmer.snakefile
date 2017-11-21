# rule all: 
#    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt'
    
rule download_Oe6_inputs_olive_nucmer:
    output: 'inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa'
    shell:'''
    wget -O inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa.gz https://osf.io/3mkv8/download?version=1 
    gunzip inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa.gz
	'''

rule download_sylv_inputs_olive_nucmer:
    output: 'inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa'
    shell:'''
	wget -O inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa.gz https://osf.io/dzse9/download?version=2
	gunzip inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa.gz
	'''

rule olive_genomes_nucmer:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer.delta'
    input:
        sylv='inputs/sylvestris/Olea_europaea_chromosome+unchromosome.fa',
        Oe6='inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa'
    conda: "envs/env.yml"
    shell:'''
    nucmer --mum {input.sylv} {input.Oe6} -p outputs/olive_genomes_nucmer/sylvester_santander_nucmer
    '''
    
rule olive_genome_nucmer_filter:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter.delta'
    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer.delta'
    conda: "envs/env.yml"
    shell:'''
    delta-filter -l 500 -q {input} > {output}
    '''
    
rule olive_genome_nucmer_coords:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt'
    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter.delta'
    conda: "envs/env.yml"
    shell:'''
    show-coords -c -l -L 500 -r -T {input} > {output}
    '''
