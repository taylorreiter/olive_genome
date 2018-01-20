include: "olivenucmer.snakefile"
include: "apulnucmer.snakefile"
include: "orthofinder.snakefile"
include: "busco.snakefile"
include: "blast.snakefile"
include: 'sourmashlca.snakefile'

rule all:
    input:
        dynamic("outputs/Oe6/blast/tab/{contig_names}.tab"),
        #dynamic("outputs/sylvestris/blast/tab/{contig_names_sylv}.tab"),
        'outputs/sourmash_lca/Oe6.scaffolds-k31.fa.lca.txt',
        'outputs/sourmash_lca/Olea_europaea_1kb_scaffolds-k31.lca.txt',
        'outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt',
        'outputs/aur-pul-nucmer/Oe6-APvarSan_filter_coords.txt',
        'outputs/aur-pul-nucmer/Oe6-APvarEx_filter_coords.txt',
        'outputs/busco/run_wild_olive_busco',
        'outputs/orthofinder/'