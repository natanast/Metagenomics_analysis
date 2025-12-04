

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(dplyr)


# load data ---------

coverage_dir <- "coverage_per_sample_poolB/"
coverage_files <- list.files(coverage_dir, pattern="_coverage.txt$", full.names=TRUE)

counts = "megares_counts/megares_counts_poolB.txt" |> fread()


# clean data -----

# Make a list: sample_name -> vector of genes with fraction >= 0.8
genes_pass <- list()

for(f in coverage_files){
    
    sample <- gsub("_L002_amr.sorted_coverage.txt", "", basename(f))
    df <- f |> fread()
    # df <- read.table(f, header=FALSE, stringsAsFactors=FALSE)
    colnames(df) <- c("chrom","start","end","gene_name","num_reads","bases_covered","gene_length","fraction_covered")
    
    genes_pass[[sample]] <- df$gene_name[df$fraction_covered >= 0.8]
}



# filter gene counts

counts = counts[, c(1, 7:ncol(counts)), with = FALSE]


colnames(counts) = counts |>
    colnames() |>
    str_remove_all("bwa_megares|sorted|bam|\\.|\\/|_L002_amr|")


# filter gene counts
counts_filtered <- counts  # copy
gene_col <- "Geneid" 


# Filter counts per sample
for(sample in colnames(counts_filtered)[-1]){  
    
    keep_genes <- genes_pass[[sample]]
    
    counts_filtered[[sample]][!counts_filtered[[gene_col]] %in% keep_genes] <- 0
    
}


# Remove rows where all sample counts are zero, but keep Geneid
counts_filtered <- counts_filtered[rowSums(counts_filtered[, -1, with = FALSE]) > 0, ]



writexl::write_xlsx(counts_filtered, "gene_counts_cleaned_poolB.xlsx")

