

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(dplyr)


# load data ---------

coverage_dir <- "coverage_per_sample_poolB/"
coverage_files <- list.files(coverage_dir, pattern="_coverage.txt$", full.names=TRUE)



# clean data -----

d <- list()

for(f in coverage_files){
    
    sample <- f |> basename() |> str_remove_all("_L002_amr|sorted_coverage|txt|\\.")
        
    df <- f |> fread()
    
    colnames(df) <- c("chrom","start","end","gene_name","num_reads","bases_covered","gene_length","fraction_covered")
    
    df2 <- df[, .(gene_name, fraction_covered)]
    
    # store sample
    d[[sample]] <- df2
    
    
}


d = d |> rbindlist(use.names = TRUE, fill = TRUE, idcol = "sample")


d_wide <- dcast(
    d,
    gene_name ~ sample,
    value.var = "fraction_covered"
)



# index <- rowSums(d_wide[, 2:ncol(d_wide), with = FALSE] > 0) > 0
# 
# d_wide <- d_wide[index]



writexl::write_xlsx(d_wide, "coverage_poolB.xlsx")
