# To avoid hammering NCBI's servers, only performing name lookup on scaffolds that survived filtering, i.e. everything that matched Olea europaea removed, all plants removed, all bit scores under 100 removed.

# read in filtered contaminants
    filt<- read.csv("post-snakemake-processing/outputs/filtered_Oe6_highest_bitscore_suspicious_contigs.csv", stringsAsFactors = FALSE)
    # remove stray columns from long names with commas
    filt <- filt[ , 1:13]
    
# read in all blast tab results
    files <- vector()
    for(i in seq(length(list.files(path = "outputs/Oe6/blast/tab/", full.names = TRUE)))){
      file_paths <- list.files(path = "outputs/Oe6/blast/tab/", full.names = TRUE)
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

library(dplyr)
filtered <- tab %>%
  filter(qseqid %in% filt$qseqid) %>% # match 50 pre-filtered contigs
  filter(bitscore >= 100) # filter out bitscore less than 100

write.table(filtered$sseqid, file = "post-snakemake-processing/outputs/qseqids", col.names = F, quote = F, row.names = F)

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
# ./make-acc-taxid-mapping.py ../outputs/qseqids genbank/nucl_gb.accession2taxid.gz 
# ./make-lineage-csv.py genbank/nodes.dmp genbank/names.dmp ../output/qseqids.taxid -o ../outputs/qseqids-lineage.csv

map <- read.csv("post-snakemake-processing/outputs/qseqids-lineage.csv", stringsAsFactors = FALSE)
# if strain info is not present, replace with species name
map <- ifelse(map$strain == "", map$strain <- map$species, map$strain)
map <- map[ , c(1, 10)]

# match accession id with filtered blast matches for species assignment
head(filtered)
library(splitstackshape)
filtered <- cSplit(indt = filtered, splitCols = "sseqid", sep = ".")

filtered_id <- merge(map, filtered, by.x = "accession", by.y = "sseqid_1")
write.csv(filtered_id, file = "post-snakemake-processing/outputs/full_contig_filtered_Oe6_highest_bitscore_suspicious_contigs.csv", row.names = FALSE, quote = FALSE)
