import pandas as pd
import numpy as np
from sourmash_lib import signature

#rule all:
#    input:
#        'outputs/Oe6/Oe6.scaffolds-k4.comp.matrix.png',
#        'outputs/Oe6/suspicious_contigs.txt',
#        'outputs/sylvestris/suspicious_contigs.txt'

rule download_Oe6_genome_k4:
    output: 'inputs/Oe6/Oe6.scaffolds_k4.fa.gz'
    shell:'''
    wget -O {output} https://osf.io/3mkv8/download?version=1
	'''

rule compute_sourmash_signature_k4_Oe6:
   output: 'outputs/Oe6/Oe6.scaffolds-k4.fa.sig'
   input: 'inputs/Oe6/Oe6.scaffolds_k4.fa.gz'
   conda: "envs/env.yml"
   shell:'''
   # compute tetranucleotide frequency of scaffolds
   sourmash compute -k 4 --scaled 5 --track-abundance --singleton --name-from-first -o {output} {input}
   '''
   
rule run_sourmash_compare_Oe6:
	output: 'outputs/Oe6/Oe6.scaffolds-k4.comp'
	input: 'outputs/Oe6/Oe6.scaffolds-k4.fa.sig'
	conda: "envs/env.yml"
	shell:'''
	sourmash compare -o {output} {input}
	'''
	
rule plot_compare_Oe6:
    output: 'outputs/Oe6/Oe6.scaffolds-k4.comp.matrix.png'
    input: 'outputs/Oe6/Oe6.scaffolds-k4.comp'
    conda: "envs/env.yml"
    shell:'''
    sourmash plot --subsample 400 --subsample-seed 1 {input}
    '''

rule suspicious_contigs_Oe6:
    output: 'outputs/Oe6/suspicious_contigs.txt'
    input: 'outputs/Oe6/Oe6.scaffolds-k4.comp'
    run:
        # load numpy array into python
        comp = np.load('outputs/Oe6/Oe6.scaffolds-k4.comp')
        # convert to a pandas dataframe
        df = pd.DataFrame(comp)
    
        # read labels into python
        f = open('outputs/Oe6/Oe6.scaffolds-k4.comp.labels.txt', 'r')
        labels = f.readlines()
	
        # set column names to labels
        df.columns = labels
	
        # grab suspicious columns
        suspicious_columns = df.loc[:, df.mean() > .4]
	
        # write column names to list
        suspicious_column_names = suspicious_columns.columns.tolist()
    
        # write suspicious labels to a file
        with open({output}, 'w') as file_handler:
            for item in suspicious_column_names:
                file_handler.write("{}\n".format(item))

rule download_sylv_genome_k4:
    output: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    shell:'''
	wget -O inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz https://osf.io/dzse9/download?version=2
	gunzip inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa.gz > {output}
	'''

rule split_sylvester:
    output: 
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.0.fa',
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.1.fa',
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.2.fa',
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.3.fa'
    input: 'inputs/sylvestris/Olea_europaea_1kb_scaffolds.fa'
    conda: "envs/env.yml"
    shell:'''
    pyfasta split -n 4 --overlap 0 {input}
    '''

rule compute_sourmash_signature_k4_sylv:
    output: 
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.*.sig',
#         'outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.sig',
#         'outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.sig',
#         'outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.sig'
    input:
        'inputs/sylvestris/Olea_europaea_1kb_scaffolds.*.fa',
#         'inputs/sylvestris/Olea_europaea_1kb_scaffolds.1.fa',
#         'inputs/sylvestris/Olea_europaea_1kb_scaffolds.2.fa',
#         'inputs/sylvestris/Olea_europaea_1kb_scaffolds.3.fa'
    conda: "envs/env.yml"
    shell:'''
    # compute tetranucleotide frequency of scaffolds
    sourmash compute -k 4 --scaled 5 --track-abundance --singleton --name-from-first -o {output} {input}
    '''

rule run_sourmash_compare_sylv_1kb:
    output: 
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp.labels.txt',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp.labels.txt',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp.labels.txt',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp.labels.txt'
    input: 
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.sig',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.sig',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.sig',
        'outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.sig'
    conda: "envs/env.yml"
    shell:'''
    sourmash compare -k 4 -o {output} {input} 
    '''

rule suspicious_contigs_sylv:
    output: 'outputs/sylvestris/suspicious_contigs.txt'
    input: 
        comp0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp',
        lab0='outputs/sylvestris/Olea_europaea_1kb_scaffolds.0.comp.labels.txt',
        comp1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp',
        lab1='outputs/sylvestris/Olea_europaea_1kb_scaffolds.1.comp.labels.txt',
        comp2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp',
        lab2='outputs/sylvestris/Olea_europaea_1kb_scaffolds.2.comp.labels.txt',
        comp3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp',
        lab3='outputs/sylvestris/Olea_europaea_1kb_scaffolds.3.comp.labels.txt'
        
    run:
        # load numpy array into python
        comp0 = np.load({input.comp0})
        comp1 = np.load({input.comp1})
        comp2 = np.load({input.comp2})
        comp3 = np.load({input.comp3})
        
        # convert to a pandas dataframe
        df0 = pd.DataFrame(comp0)
        df1 = pd.DataFrame(comp1)
        df2 = pd.DataFrame(comp2)
        df3 = pd.DataFrame(comp3)
        
        # read labels into python
        f0 = open({input.lab0}, 'r')
        labels0 = f0.readlines()
	
        f1 = open({input.lab1}, 'r')
        labels1 = f1.readlines()
        
        f2 = open({input.lab2}, 'r')
        labels2 = f2.readlines()
        
        f3 = open({input.lab3}, 'r')
        labels3 = f3.readlines()
        
        # set column names to labels
        df0.columns = labels0
        df1.columns = labels1
        df2.columns = labels2
        df3.columns = labels3
	    
        # grab suspicious columns
        suspicious_columns0 = df0.loc[:, df0.mean() < .4]
        suspicious_columns1 = df1.loc[:, df1.mean() < .4]
        suspicious_columns2 = df2.loc[:, df2.mean() < .4]
        suspicious_columns3 = df3.loc[:, df3.mean() < .4]
	    
        # write column names to list
        suspicious_column_names0 = suspicious_columns0.columns.tolist()
        suspicious_column_names1 = suspicious_columns1.columns.tolist()
        suspicious_column_names2 = suspicious_columns2.columns.tolist()
        suspicious_column_names3 = suspicious_columns3.columns.tolist()
        
        suspicious_column_names = suspicious_column_names0 + suspicious_column_names1 + suspicious_column_names2 + suspicious_column_names3
        
        # write suspicious labels to a file
        with open({output}, 'w') as file_handler:
            for item in suspicious_column_names:
                file_handler.write("{}\n".format(item))
