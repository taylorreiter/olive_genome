# This script determines whether there are overlaps between the contaminants identified in the santander reference genome and the sylvester reference genome. If there is, then one would expect that these are not contaminants, and instead represent horizontal gene transfer.

# set working directory to contamination folder
setwd("/Users/taylorreiter/github/olive_public_seq/ref_genome/")

# import lists of contaminant scaffolds. 

# A pul
  
  # Chimeric coordinates
  chimeric_contained <- read.table("santander/AurPul-nucmer/data_out/chimeric_contig_contained.txt", skip = 1)
  
  chimeric_full <- read.table("santander/AurPul-nucmer/data_out/chimeric_contig_coordinates.txt", stringsAsFactors = FALSE)
  chimeric <- chimeric_full$V1
  chimeric <- str_extract(string = chimeric, pattern = "(Oe6_s[0-9]{4,5})")
  
  # complete
  complete <- read.table("santander/AurPul-nucmer/data_out/all_whole_contigs.txt")
  
  # contained
  contained <- read.table("santander/AurPul-nucmer/data_out/all_containment_contigs.txt")

# contaminants identified by tetranucleotide frequency clustering.
  tetra_contam_full <- read.csv("post-snakemake-processing/outputs/filtered2_Oe6_highest_bitscore_suspicious_contigs.csv")
  tetra_contam <- tetra_contam_full[1:13]

# import the nucmer object created by aligned sylvester and santander olive genomes.
  olive_nucmer <- read.table("outputs/olive_genomes_nucmer/sylvester_santander_nucmer_filter_coords.txt", skip = 4, head = FALSE, col.names =c("s1", "e1", "s2", "e2", "len1", "len2", "p-idy", "lenr", "lenq", "covr", "covq", "ref", "quer"))
  

# search each contaminant list
  tetra_contam_in <- olive_nucmer$quer %in% tetra_contam
  tetra_contam_in <- unique(olive_nucmer$quer[tetra_contam_in])

  complete_in <- olive_nucmer$quer %in% complete 
  complete_in  <- unique(olive_nucmer$quer[complete_in])
  
  contained_in <- olive_nucmer$quer %in% contained
  contained_in  <- unique(olive_nucmer$quer[contained_in])
  
  chimeric_contained_in <- olive_nucmer$quer %in% chimeric_contained
  chimeric_contained_in  <- unique(olive_nucmer$quer[chimeric_contained_in])
  
# search for the chimeric scaffolds -- do the easy search first, where the entire scaffold is searched for. Then, do fancy ranges things on only the ones that are found. 
  chimeric_in <- olive_nucmer$quer %in% chimeric
  chimeric_in  <- unique(olive_nucmer$quer[chimeric_in])
  chimeric_in

  # RANGES
  
  chimeric_in_nucmer  <- olive_nucmer[olive_nucmer$quer %in% chimeric_in, ]
  chimeric_in_nucmer[order(chimeric_in_nucmer$quer),]
  chimeric_full
  # Use iRanges/gRanges to find overlaps between A. Pul chimeric nucmer object, and the domesticated/wild olive nucmer object
  library(rutilstimflutre)
  olive_mummer <- loadMummer("genome_comparison/nucmer/sylvester_santander_nucmer_filter_coords_flipped.txt") # note that the olive mummer was reversed by had so that the domestic olive was the reference to facilitate findOverlaps
  apul_mummer <- loadMummer("santander/AurPul-nucmer/data_out/Oe6-AP-chimeric-all-nucmer.txt") # note that the apul mummer was hand created by merging "santander/AurPul-nucmer/data_out/Oe6-AP*-chimeric.csv documents"
  

  library(IRanges)
  library(GenomicRanges)
  
  countOverlaps(apul_mummer, olive_mummer)
 
  apul_subset  <- subsetByOverlaps(query = apul_mummer, subject = olive_mummer)
  write.csv(apul_subset, "apul_ranges_overlap.csv")
  apul_subset  <- subsetByOverlaps(query = apul_mummer, subject = olive_mummer, type = "within")
  write.csv(apul_subset, "apul_ranges_overlap_within.csv")
  
  olive_subset <- subsetByOverlaps(query = olive_mummer, subject = apul_mummer)
  write.csv(olive_subset, "olive_ranges_overlap.csv")
  
  olive_subset <- subsetByOverlaps(query = olive_mummer, subject = apul_mummer, type = "within")
  write.csv(olive_subset, "olive_ranges_overlap_within.csv")
  
  
# Summary
# This script analyzed whether scaffolds identified as contaminants in the domesticated olive reference genome aligned to the wild olive reference genome. No sequences that were identified as contaminants in the domesticated olive genome aligned to the wild olive genome.
  
  # The contained, complete, and complete chimeric contaminant scaffolds identified using alignments between *A. pullulans* and the domesticated olive genome did not align to the wild olive genome. 
  
  # Forty-six of 59 true chimeric contaminant scaffolds identified using alignments between *A. pullulans* and the domesticated olive genome did align to the wild olive genome. However, only four chimeric alignment ranges identified between *A. pullulans* and the domestic olive genome were contained within alignment ranges between the domestic olive reference genome and the wild olive reference genome. 
  # seqnames	start	end	width
  # Oe6_s00066	400935	403099	2165
  # Oe6_s03962	413254	414074	821
  # Oe6_s06058	180730	181653	924
  # Oe6_s06683	6398	  9017	  2620
# Addtionally, five alignment ranges identified between the domestic olive reference genome and the wild olive reference genome were contained within chimeric alignment ranges identified between *A. pullulans* and hte domestic olive reference genome. 
  # seqnames	start	end	width
  # Oe6_s03923	538311	539063	753
  # Oe6_s04485	26225	  27060	  836
  # Oe6_s06058	180730	181653	924
  # Oe6_s09611	17262	  18880	  1619
  # Oe6_s09871	169096	169344	249

# These ranges were extracted from the domesticated olive genome using samtools faidx. I had planned to BLAST them against the NCBI nr/nt database, however no more than five bp were contained in any -- the rest were made of of "N". However, the nucmer tool within mummer does not explicitly match "Ns"; I believe if they are contained within a sequence, they reduce identity of an alignment. Therefore, no *A. pullulans* sequence identified in the domestic olive reference genome was identified in the wild olive reference genome. 