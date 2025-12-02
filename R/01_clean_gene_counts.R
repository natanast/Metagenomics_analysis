

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)


# load data ---------

d = "coverage_per_sample/A_A1-20_S2_L001_clean_amr.sorted_coverage.txt" |> fread()


# clean data -----

colnames(d) <- c(
    "chrom",           # 1: chromosome / contig / gene ID
    "start",           # 2: start of gene (0-based, from bed)
    "end",             # 3: end of gene
    "gene_name",       # 4: gene name / gene ID
    "num_reads",       # 5: number of reads overlapping the gene anywhere
    "bases_covered",   # 6: number of bases covered at least once
    "gene_length",     # 7: length of the gene
    "fraction_covered" # 8: bases_covered / gene_length
)


d_80 <- d[fraction_covered >= 0.8]



# filter counts --------

library(dplyr)

coverage_dir <- "coverage_per_sample/"
coverage_files <- list.files(coverage_dir, pattern="_coverage.txt$", full.names=TRUE)

# Make a list: sample_name -> vector of genes with fraction >= 0.8
genes_pass <- list()

for(f in coverage_files){
    
    sample <- gsub("_coverage.txt", "", basename(f))
    df <- f |> fread()
      # df <- read.table(f, header=FALSE, stringsAsFactors=FALSE)
    colnames(df) <- c("chrom","start","end","gene_name","num_reads","bases_covered","gene_length","fraction_covered")
    
    genes_pass[[sample]] <- df$gene_name[df$fraction_covered >= 0.8]
}


# counts <- read.table("amr-counts_highMQ.txt", header=TRUE, row.names=1, check.names=FALSE)


counts = "amr-counts.txt" |> fread()


counts = counts[, c(1, 7:ncol(counts)), with = FALSE]


colnames(counts) = counts |>
    colnames() |>
    str_remove_all("bwa_amr_output|sorted|bam|\\.|\\/|_L001_amr|")


counts_filtered <- counts  # copy

for(sample in colnames(counts)){
    # get genes passing for this sample
    keep_genes <- genes_pass[[sample]]
    
    # set counts to 0 if gene not in keep_genes
    counts_filtered[!rownames(counts_filtered) %in% keep_genes, sample] <- 0
}


counts_filtered$Geneid <- NULL


# remove rows with all zeros
counts_filtered <- counts_filtered[rowSums(counts_filtered) > 0, ]

