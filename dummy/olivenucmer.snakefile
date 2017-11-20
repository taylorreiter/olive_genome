# rule all: 
#    input: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt'
    
rule download_Oe6_inputs_olive_nucmer:
    output: 'inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa.gz'
    shell:'''
    wget -O {output} https://osf.io/3mkv8/download?version=1 
	'''

rule download_sylv_inputs_olive_nucmer:
    output: 'inputs/sylvestris/Olea_europaea_chromosome+unchromosome.gz'
    shell:'''
	wget -O {output} https://osf.io/dzse9/download?version=2
	'''

rule olive_genomes_nucmer:
    output: 'outputs/olive_genomes_nucmer/sylvester_santander_nucmer.delta'
    input:
        sylv='inputs/sylvestris/Olea_europaea_chromosome+unchromosome.gz',
        Oe6='inputs/Oe6/Oe6.scaffolds_olive_nucmer.fa.gz'
    conda: "envs/env.yml"
    shell:'''
    nucmer --mum {input.sylv} {input.Oe6} -p sylvester_santander_nucmer
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
