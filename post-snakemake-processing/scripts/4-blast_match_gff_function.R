# pull gff3 ranges that align to BLAST scaffolds deemed contaminants. 
  download.file("http://denovo.cnag.cat/genomes/olive/download/Oe6/OE6A.gff3", destfile = "OE6A.gff3")
  gff <- read.table(file = "OE6A.gff3", header = F, stringsAsFactors = F)
  blasts <- read.csv(file = "post-snakemake-processing/outputs/filtered2_Oe6_highest_bitscore_suspicious_contigs.csv", stringsAsFactors = F)
  blasts <- blasts[, 1:13] # clean up excess columns from commas in names
  
  # grab the unique scaffold names id'd as contams in Oe6
  scaffolds <- unique(blasts$qseqid)
  # subset gff3 based on scaffold names
  gff_contaminants <- subset(gff, V1 %in% scaffolds)
  
  # grep for "product", which is the annotation for a protein
  products <- grepl(pattern = "product", x = gff_contaminants$V9)
  gff_contaminants <- gff_contaminants[products, ]
  # count products
  dim(gff_contaminants)
  # check unique scaffolds
  unique(gff_contaminants$V1)
  write.csv(gff_contaminants, "post-snakemake-processing/outputs/gff3_contaminant_products.csv", quote = F, row.names = F)
