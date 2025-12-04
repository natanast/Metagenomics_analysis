

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(vegan)


# load data ---------


# Folder containing *.report files
reports_dir <- "poolA/"
files <- list.files(reports_dir, pattern = "\\.report$", full.names = TRUE)



report <- list()

for(f in files){
    
    # Read the Kraken2 report
    df <- f |> fread(sep="\t", header=FALSE, quote="", fill=TRUE)
    
    sample <- f |> 
        basename() |>  
        str_remove_all("_L001.report")

    # Store in list
    report[[sample]] <- df

}



parse_kraken <- function(dt) {
    dt[, .(
        Taxon = V6,
        Count = V2
    )]
}




parsed <- lapply(report, parse_kraken)






# # rarefaction curves -----
# 
# png("rarefaction_curves_kraken.png",
#     width = 3000, height = 2400, res = 300)
# 
# rarecurve(
#     counts_matrix_t, 
#     step = 100,
#     sample = min(rowSums(counts_matrix_t)),
#     col = "darkgreen",
#     label = TRUE,
#     cex = 0.4,
#     xlab = "Sequencing depth (reads)",
#     ylab = "Observed AMR genes"
# )
# 
# dev.off()
