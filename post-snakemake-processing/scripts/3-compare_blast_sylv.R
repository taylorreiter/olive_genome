# read in files in tab format from blasting the suspicous olea contigs against nt

# make a vector of files where file size > 0
files <- vector()
for(i in seq(length(list.files(path = "outputs/sylvestris/blast/tab/", full.names = TRUE)))){
  file_paths <- list.files(path = "outputs/sylvestris/blast/tab/", full.names = TRUE)
  if(file.size(file_paths[i]) == 0) next
  files[i] <- file_paths[i]
}

# remove NAs from vector
files <- files[!is.na(files)]

# read files in
tab <- lapply(files, function(x) read.table(x, header = FALSE, stringsAsFactors = FALSE))
tab <- do.call("rbind", tab)
colnames(tab) <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", 
                   "qstart", "qend", "sstart", "send", "evalue", "bitscore")
# column name meanings of blast output
# 1.   qseqid	 query (e.g., gene) sequence id
# 2.	 sseqid	 subject (e.g., reference genome) sequence id
# 3.	 pident	 percentage of identical matches
# 4.	 length	 alignment length
# 5.	 mismatch	 number of mismatches
# 6.	 gapopen	 number of gap openings
# 7.	 qstart	 start of alignment in query
# 8.	 qend	 end of alignment in query
# 9.	 sstart	 start of alignment in subject
# 10.	 send	 end of alignment in subject
# 11.	 evalue	 expect value
# 12.	 bitscore	 bit score

library(dplyr)
# create a dataframe that contains contigs that are from olea europaea repeat sequences
olea_repeats <- filter(tab, sseqid == "AJ243943.1" |
                         sseqid == "AJ243944.1")

# filter contigs that had the repeats. If a contig matched a repetitive sequence at any point, then it is assumed by this approach that the entire contig is olive genome
olea_repeat_contigs <- unique(olea_repeats$qseqid)
non_repeats <- filter(tab, (!qseqid %in% olea_repeat_contigs))

# add a column for species name of match. First, sort by highest bitscore per contig to avoid sending over 7000 queries to NCBI; sends 125 instead. 
# select highest bitscore for each contig
# Sort by qseqid and bitscore (largest bitscore is last for each qseqid)
non_repeats <- non_repeats[order(non_repeats$qseqid, non_repeats$bitscore), ]

# Select the last row by id
non_repeats_bitscore <- non_repeats[!duplicated(non_repeats$qseqid, fromLast=TRUE), ]

write.table(non_repeats_bitscore$sseqid, file = "post-snakemake-processing/outputs/sylv_sseqids", col.names = F, quote = F, row.names = F)

# on the command line, create a mapping of accession id to taxonomic lineage
# git clone https://github.com/dib-lab/2018-ncbi-lineages.git
# cd 2018-ncbi-lineages
# mkdir -p genbank/
# cd genbank/
# curl -L -O ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdmp.zip
# unzip taxdmp.zip nodes.dmp names.dmp
# rm taxdmp.zip
# curl -L -O ftp://ftp.ncbi.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz
# cd ..
# ./make-lineage-csv.py nodes.dmp names.dmp ../post-snakemake-processing/outputs/sylv_sseqids.taxid -o ../post-snakemake-processing/outputs/sylv_sseqids-lineage.csv
# ./make-lineage-csv.py genbank/nodes.dmp genbank/names.dmp ../post-snakemake-processing/outputs/sylv_sseqids.taxid -o ../post-snakemake-processing/outputs/sylv_sseqids-lineage.csv

map <- read.csv("post-snakemake-processing/outputs/sylv_sseqids-lineage.csv", stringsAsFactors = FALSE)
map <- map[ , c(1, 9)]

# match accession id with filtered blast matches for species assignment

library(splitstackshape)
non_repeats_bitscore<- cSplit(indt = non_repeats_bitscore, splitCols = "sseqid", sep = ".")

non_repeats_bitscore <- merge(map, non_repeats_bitscore, by.x = "accession", by.y = "sseqid_1")

write.csv(non_repeats_bitscore, file = "post-snakemake-processing/outputs/sylv_highest_bitscore_suspicious_contigs.csv", quote = FALSE, row.names = FALSE)






