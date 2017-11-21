# rule all:
#     input:
#         'outputs/aur-pul-nucmer/Oe6-APvarSan_filter_coords.txt',
#         'outputs/aur-pul-nucmer/Oe6-APvarEx_filter_coords.txt'
        
rule download_Oe6_genome_apul:
    output: 'inputs/Oe6/Oe6.scaffolds_apul.fa'
    shell:'''
    wget -O inputs/Oe6/Oe6.scaffolds_apul.fa.gz http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz
    gunzip inputs/Oe6/Oe6.scaffolds_apul.fa.gz
	'''

rule download_Apul_genomes:
    output:
        san='inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna.gz',
	    ex150='inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna.gz'
	shell:'''
	wget -O inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/678/115/GCA_001678115.1_ASM167811v1/GCA_001678115.1_ASM167811v1_genomic.fna.gz 
	gunzip inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna.gz
	wget -O inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna.gz ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/721/785/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna.gz
	gunzip inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna.gz 
	'''

rule apul_san_nucmer:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarSan.delta' 
    input: 
        san = 'inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna',
        Oe6 = 'inputs/Oe6/Oe6.scaffolds_apul.fa'
    conda: "envs/env.yml"
    shell:'''
    nucmer --mum {input.Oe6} {input.san} -p outputs/aur-pul-nucmer/Oe6-APvarSan
    '''

rule apul_san_nucmer_filter:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarSan_filter.delta'
    input: 'outputs/aur-pul-nucmer/Oe6-APvarSan.delta'
    conda: "envs/env.yml"
    shell:'''
    delta-filter -l 500 -q {input} > {output} 
    '''
    
rule apul_san_nucmer_coords:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarSan_filter_coords.txt'
    input: 'outputs/aur-pul-nucmer/Oe6-APvarSan_filter.delta'
    conda: "envs/env.yml"
    shell:'''
    show-coords -c -l -L 500 -r -T {input} > {output}
    '''
    
rule apul_exf150_nucmer:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarEx.delta'
    input:
        ex150 = 'inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna',
        Oe6 = 'inputs/Oe6/Oe6.scaffolds_apul.fa'
    conda: "envs/env.yml"
    shell:'''
    nucmer --mum {input.Oe6} {input.ex150} -p utputs/aur-pul-nucmer/Oe6-APvarEx
    '''

rule apul_exf150_nucmer_filter:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarEx_filter.delta'
    input: 'outputs/aur-pul-nucmer/Oe6-APvarEx.delta'
    conda: "envs/env.yml"
    shell:'''
    delta-filter -l 500 -q {input} > {output}
    '''

rule apul_exf150_nucmer_coords:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarEx_filter_coords.txt'
    input: 'outputs/aur-pul-nucmer/Oe6-APvarEx_filter.delta'
    conda: "envs/env.yml"
    shell:'''
    show-coords -c -l -L 500 -r -T {input} > {output}
    '''