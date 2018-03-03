# Clean olive reference genome. Make a bedfile with the contig names, start sites, and end sites of identified contaminants. 

# Read in the file containing contig names of full contaminants, and contig names and coords of chimeric scaffolds
contam <- read.delim("post-snakemake-processing/outputs/all_contaminant_scaffolds.txt", stringsAsFactors = FALSE, sep = ":", header = T, comment.char = "#")

library(dplyr)
library(tidyr)

bed <- separate(contam, coords, into = c("start", "end"), sep = "-")
bed <- bed[order(bed$start), ]

# grab contig sizes for contigs that are complete contaminants
# file made with
# samtools faidx Oe6.scaffolds.fa
# cut -f1,2 Oe6.scaffolds.fa.fai > Oe6.scaffolds.contig.sizes.txt

lengths <- read.delim("post-snakemake-processing/outputs/Oe6.scaffolds.contig.sizes.txt", header = FALSE, stringsAsFactors = FALSE)

lengths <- filter(lengths, lengths$V1 %in% bed$contig[1:91])

colnames(lengths) <- c("contig", "end")
lengths <- full_join(bed, lengths, by = "contig")
bed[1:91, 3] <- lengths[1:91, 4]
bed[1:91, 2] <- 1

write.table(bed, "post-snakemake-processing/outputs/Oe6_all_contaminants.bed", quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")

# then in bash, run:
# bedtools maskfasta -fi Oe6.scaffolds.fa -fo Oe6.scaffolds.contam.masked.fa -bed Oe6_all_contaminants.bed