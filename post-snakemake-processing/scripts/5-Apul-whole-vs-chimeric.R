# This script ascertains whether the nucmer matches detected between Oe6 and A. pul genomes account for entire assembled contigs in Oe6, or whether these contigs could be chimeric.

# Whole contig ------------------------------------------------------------

# For the Santander variant, contigs where 99 percent of the olive scaffold aligned to the A. pul genome with at least 99 percent similarity were considered whole contig contaminants. These specifications were relaxed for the EXF150 genome, as this strain was not the strain that was sequenced. 

# Santander 

    # load mummer coords as a data.frame
    san <- read.delim(file = "outputs/aur-pul-nucmer/Oe6-APvarSan_filter_coords.txt", skip = 4, header = FALSE, col.names = c("s1", "e1", "s2", "e2", "len1", "len2", "p-idy", "lenr", "lenq", "covr", "covq", "ref", "quer"))
    dim(san)
    # select mummer coords where p.idy > 99 and covr > 99
    san_whole_contigs <- san[(san$covr > 99) & (san$p.idy > 99), ]
    write.csv(san_whole_contigs, "post-snakemake-processing/outputs/Oe6-APvarSan-whole-contigs.csv", row.names = FALSE, quote = FALSE) 


# EXF-150

    exf <- read.delim(file = "outputs/aur-pul-nucmer/Oe6-APvarEx_filter_coords.txt", skip = 4, header = FALSE, col.names = c("s1", "e1", "s2", "e2", "len1", "len2", "p-idy", "lenr", "lenq", "covr", "covq", "ref", "quer"))
    dim(exf)
    # select mummer coords where p.idy >99 100 and covr > 94 (strain variation)
    exf_whole_contigs <- exf[(exf$covr > 99) & (exf$p.idy > 94), ]
    write.csv(exf_whole_contigs, "post-snakemake-processing/outputs/Oe6-APvarEx-whole-contigs.csv", row.names = FALSE, quote = FALSE) 
    
    setdiff(exf_whole_contigs$ref, san_whole_contigs$ref)
    setdiff(san_whole_contigs$ref, exf_whole_contigs$ref)
    all_whole_contigs <- union(san_whole_contigs$ref, exf_whole_contigs$ref)
    length(all_whole_contigs)
    write.table(all_whole_contigs, file = "post-snakemake-processing/outputs/all_whole_contigs.txt", row.names = FALSE, quote = FALSE, col.names = FALSE)


# Containment across mulitple alignments ----------------------------------

# Check for containment of entire olive scaffold across multiple alignment with the A. pul genome. 

# Santander
    san_containment <- by(san[ , c(5, 10)], san$ref, FUN=colSums)
    san_containment_pidy <- by(san[ , 7], san$ref, FUN = mean)
    
    san_containment_contigs <- vector()
    for(i in seq(length(san_containment))){
      san_containment_contigs[i] <- san_containment[[i]][2]
    }
    
    san_containment_names <- vector()
    for(i in seq(length(san_containment))){
      san_containment_names[i] <- names(san_containment[i])
    }
    
    san_containment_pidy2 <- vector()
    for(i in seq(length(san_containment))){
      san_containment_pidy2[i] <- san_containment_pidy[[i]][1]
    }
    
    
    san_containment <- as.data.frame(cbind(san_containment_names, san_containment_contigs, san_containment_pidy2))
    san_containment$san_containment_contigs <- as.numeric(as.character(san_containment$san_containment_contigs))
    san_containment$san_containment_pidy2 <- as.numeric(as.character(san_containment$san_containment_pidy2))
    san_containment <- san_containment[(san_containment$san_containment_contigs >= 99) & (san_containment$san_containment_pidy2 >= 99), ]
    write.csv(san_containment, "post-snakemake-processing/outputs/Oe6-APvarSan-containment-contigs.csv", row.names = FALSE, quote = FALSE)


# EXF 
    exf_containment <- by(exf[ , c(5, 10)], exf$ref, FUN=colSums)
    exf_containment_pidy <- by(exf[ , 7], exf$ref, FUN = mean)
    
    exf_containment_contigs <- vector()
    for(i in seq(length(exf_containment))){
      exf_containment_contigs[i] <- exf_containment[[i]][2]
    }
    
    exf_containment_names <- vector()
    for(i in seq(length(exf_containment))){
      exf_containment_names[i] <- names(exf_containment[i])
    }
    
    exf_containment_pidy2 <- vector()
    for(i in seq(length(exf_containment))){
      exf_containment_pidy2[i] <- exf_containment_pidy[[i]][1]
    }
    
    
    exf_containment <- as.data.frame(cbind(exf_containment_names, exf_containment_contigs, exf_containment_pidy2))
    exf_containment$exf_containment_contigs <- as.numeric(as.character(exf_containment$exf_containment_contigs))
    exf_containment$exf_containment_pidy2 <- as.numeric(as.character(exf_containment$exf_containment_pidy2))
    exf_containment <- exf_containment[(exf_containment$exf_containment_contigs >= 99) & (exf_containment$exf_containment_pidy2 >= 94), ]
    write.csv(exf_containment, "post-snakemake-processing/outputs/Oe6-APvarEx-containment-contigs.csv", row.names = FALSE, quote = FALSE)

    

    all_containment_contigs <- union(san_containment$san_containment_names, exf_containment$exf_containment_names)
    write.table(all_containment_contigs, file = "post-snakemake-processing/outputs/all_containment_contigs.txt", row.names = FALSE, quote = FALSE, col.names = FALSE)    

    setdiff(all_containment_contigs, all_whole_contigs)
    setdiff(all_whole_contigs, all_containment_contigs)
    
# Chimeric contigs --------------------------------------------------------

# Unlike in the above cases, I did not want to remove the entire scaffold for chimeric contigs, as some of the scaffold might still contain important olive genome sequence information. The script below removes the contigs that were accounted for above, and then filters out matches that have a low percent identity. This dataframe is then written to a csv file which I manipulated by hand to determine which bps should be removed from the reference genome and which should not.

# Santander  
  # First, subtract all contigs that were accounted for above
    accounted_for <- union(all_containment_contigs, all_whole_contigs)
    san_unaccounted <- san[ !grepl(paste(accounted_for, collapse="|"), san$ref), ]
    
    san_chimeric <- san_unaccounted[(san_unaccounted$p.idy > 98), ]
    write.csv(san_chimeric, file = "post-snakemake-processing/outputs/Oe6-APvarSan-chimeric.csv", row.names = FALSE, quote = FALSE)

# EXF-150    
    exf_unaccounted <- exf[ !grepl(paste(accounted_for, collapse="|"), exf$ref), ]
    
    exf_chimeric <- exf_unaccounted[(exf_unaccounted$p.idy > 94), ]
    write.csv(exf_chimeric, file = "post-snakemake-processing/outputs/Oe6-APvarEx-chimeric.csv", row.names = FALSE, quote = FALSE)

    
# To determine what pieces of chimeric contigs to remove, I combined the two csv documents output above and sorted by olive contig and olive contig start bp. In many cases, when both var. Santander and var. EXF-150 were combined, almost the entire scaffold was contained, and thus it was removed (e.g. Oe6_s00957). In other cases, it appeared as though fungal sequence was assembled with olive sequence, creating a true chimeric contig (e.g. Oe6_s00135). In such instances, the first basepair match with A. pul to the last basepair match with A. pul. was removed in entirety. In other cases still, a section of A. pul sequence was found in the middle of a scaffold. In such cases, the scaffold was broken and this sequence was removed. 
    
    # create file to remove mostly-contained scaffold
    Oe6_s00957 <- c("Oe6_s00957")
    write.table(Oe6_s00957, file = "post-snakemake-processing/outputs/chimeric_contig_contained.txt", quote = FALSE, row.names = FALSE)

# I created a file names "data_out/chimeric_contig_coordinates.txt" that recorded the scaffold and coordinates of the chimeric contaminants. The file is formatted for use with samtools faidx. 
    
# From this file, I need to create a new file that records the coordinates of the scaffolds that should be retained. These coordinates will be 1-(first coordinate recorded in file) and (second coordinate recorded in file)-(length of reference). 
    chimeric <- read.table("data_out/chimeric_contig_coordinates.txt", sep = ":")
    chimeric$V1 <- gsub(pattern = ">", replacement = "", x = chimeric$V1)
    library(reshape)
    chimeric <- transform(chimeric, contam = colsplit(V2, split = "-", names = c('start', 'end')))
    
    # Add start of olive sequence
    olive_start1 <- rep(1, nrow(chimeric))
    olive_end1 <- chimeric$contam.start - 1  
    
    olive_start2 <- chimeric$contam.end + 1
    
    library(dplyr)
    colnames(chimeric) <- c("ref", "coords", "contam_start", "contam_end")
    len_tmp <- cbind(as.character(san$ref), san$lenr)
    len_tmp2 <- cbind(as.character(exf$ref), exf$lenr)
    len_tmp <- rbind(len_tmp, len_tmp2)
    len_tmp <- unique(len_tmp)
    colnames(len_tmp) <- c("ref", "lenr")
    chimeric <- merge(chimeric, len_tmp)
    olive_end2 <- as.numeric(as.character(chimeric$lenr))
    
    olive_seq <- as.data.frame(cbind(chimeric$ref, olive_start1, olive_end1, olive_start2, olive_end2))
    #olive_seq <- gsub("Oe6", ">Oe6", olive_seq)
    
    # make a coords file that includes each start and finish.
    part1 <- paste(olive_seq$V1, olive_seq$olive_start1, sep = ":")
    part2 <- paste(part1, olive_seq$olive_end1, sep ="-")
 
    part3 <- paste(olive_seq$V1, olive_seq$olive_start2, sep =":")
    part4 <- paste(part3, olive_seq$olive_end2, sep = "-")
    
    part2 <- gsub("Oe6", ">Oe6", part2)
    part4 <- gsub("Oe6", ">Oe6", part4)
    
   # remove invalid ranges
   part2 <- part2[!grepl(":1-0", part2)]   
  
   olive_seqs <- c(part2, part4)  
      
    
write.table(olive_seqs, file = "post-snakemake-processing/outputs/anti_chimeric_contig_coordinates.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)


# Summary
# Across both A pul nucmer alignments, 49 scaffolds were identified as entirely *A. pullulans* sequence ("Oe6_s01156, Oe6_s01603, Oe6_s01606, Oe6_s01757, Oe6_s01796, Oe6_s01852, Oe6_s03435, Oe6_s03563, Oe6_s0358, Oe6_s03605, Oe6_s03646, Oe6_s03764, Oe6_s03799, Oe6_s04984, Oe6_s05234, Oe6_s05275, Oe6_s05383, Oe6_s05511"Oe6_s07049, Oe6_s07268, Oe6_s07419, Oe6_s08822, Oe6_s09328, Oe6_s09451, Oe6_s10948, Oe6_s10961, Oe6_s11137"
"Oe6_s11170, Oe6_s11203, Oe6_s11237, Oe6_s11267, Oe6_s11303, Oe6_s11411, Oe6_s11498, Oe6_s01299, Oe6_s01722, Oe6_s03228, Oe6_s03596, Oe6_s03739, Oe6_s05341, Oe6_s05371, Oe6_s05504, Oe6_s05662, Oe6_s07137, Oe6_s07311"
"Oe6_s08815, Oe6_s09163, Oe6_s10924, Oe6_s11384). Conversely, 59 scaffolsd were chimeric. 