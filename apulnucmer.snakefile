# rule all:
#     input:
#         'outputs/aur-pul-nucmer/Oe6-APvarSan_filter_coords.txt',
#         'outputs/aur-pul-nucmer/Oe6-APvarEx_filter_coords.txt'
        
rule download_Oe6_genome_apul:
    output: 
        gz='inputs/Oe6/Oe6.scaffolds_apul.fa.gz',
        uncmp='inputs/Oe6/Oe6.scaffolds_apul.fa'
    shell:'''
    wget -O {output.gz} http://denovo.cnag.cat/genomes/olive/download/Oe6/Oe6.scaffolds.fa.gz
    gunzip -c {output.gz} > {output.uncmp}
	'''

rule download_Apul_genomes:
    output:
        sangz='inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna.gz',
        sanuncmp='inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna',
	    ex150gz='inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna.gz',
	    ex150uncmp='inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna'
	shell:'''
	wget -O {output.sangz} ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/678/115/GCA_001678115.1_ASM167811v1/GCA_001678115.1_ASM167811v1_genomic.fna.gz 
	gunzip -c {output.sangz} > {output.sanuncmp}
	wget -O {output.ex150gz} ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/721/785/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna.gz
	gunzip -c {output.ex150gz} > {output.ex150uncmp}
	'''

rule apul_san_nucmer:
    output: 'outputs/aur-pul-nucmer/Oe6-APvarSan.delta' 
    input: 
        san='inputs/aur-pul/GCA_001678115.1_ASM167811v1_genomic.fna',
        Oe6='inputs/Oe6/Oe6.scaffolds_apul.fa'
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
        ex150='inputs/aur-pul/GCA_000721785.1_Aureobasidium_pullulans_var._pullulans_EXF-150_assembly_version_1.0_genomic.fna',
        Oe6='inputs/Oe6/Oe6.scaffolds_apul.fa'
    conda: "envs/env.yml"
    shell:'''
    nucmer --mum {input.Oe6} {input.ex150} -p outputs/aur-pul-nucmer/Oe6-APvarEx
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