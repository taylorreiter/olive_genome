# read in files in tab format from blasting the suspicous olea contigs against nt

# make a vector of files where file size > 0
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

    # Query NCBI nucleotide database for metadata associated with nuid
    library(rentrez)
    block <- function(i){
      nuid_species <- entrez_summary(db="nucleotide", id = i)
      Sys.sleep(2) # sleep; don't overwhelm NCBI server
      return(nuid_species)
    }
    # apply to all unique nuids
    nuid_names <- lapply(unique(non_repeats_bitscore$sseqid), block)
    # extract species names from retrieved data
    nuid_unique_names <- sapply(nuid_names, "[[", 3)
    # make a dataframe of nuid and species
    nuid_unique <- unique(non_repeats_bitscore$sseqid)
    
    names_w_nuids <- cbind(nuid_unique, nuid_unique_names)
    names_w_nuids <- as.data.frame(names_w_nuids)
    colnames(names_w_nuids) <- c("nuid", "nuid_title")
    
    # merge dataframe with nuid species
    non_repeats_bitscore <- merge(non_repeats_bitscore, names_w_nuids, by.x = "sseqid", by.y = "nuid")


  
write.csv(non_repeats_bitscore, file = "post-snakemake-processing/outputs/Oe6_highest_bitscore_suspicious_contigs.csv", quote = FALSE, row.names = FALSE)

# after observing the output CSV, check out other hits on contigs that had high bitscores to determine if the sequence is widely distributed throughout different species, or if it is specific to a specific kingdom/family/etc. 

# Oe6_s09260 matched a homo sapiens BAC
head(non_repeats)
Oe6_s09260 <- filter(non_repeats, qseqid == "Oe6_s09260")
# all return homo sapiens or pan troglodytes, except a handful. The contig is 1265 nucleotides, and the longest match to the human genome was 1245. 
# this is probably human genome. This should probably be removed. 
# UCSC genome browser blat: 1242     1  1245  1245 100.0%     1   +  125180113 125182680   2568


# Oe6_s02989 matched methylobacter sp C1 chromosome
Oe6_s02989 <- filter(non_repeats, qseqid == "Oe6_s02989")
Oe6_s02989



