
rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(vegan)

# load data ---------

d = "amr-counts.txt" |> fread()


d = d[, c(1, 7:ncol(d)), with = FALSE]


colnames(d) = d |>
    colnames() |>
    str_remove_all("bwa_amr_output|sorted|bam|\\.|\\/|_L001_amr|")




# keep only numeric counts (remove Geneid column)
counts_matrix <- d[, -1, with = FALSE]  # all columns except first

# convert to matrix
counts_matrix <- as.matrix(counts_matrix)

# transpose so rows = samples, columns = genes
counts_matrix_t <- t(counts_matrix)


# rarefaction curves -----
rarecurve(
    counts_matrix_t, 
    step = 100,          # increment of sample size
    sample = min(rowSums(counts_matrix_t)), # rarefy to the smallest sample depth
    col = "darkgreen",
    label = TRUE
    # xlab = "Sequencing depth (reads)", 
    # ylab = "Observed genes"
)



# 
# library(ggplot2)
# # keep only numeric counts
# counts_matrix <- as.matrix(d[, -1, with = FALSE])
# 
# # calculate total abundance per sample
# total_abundance <- colSums(counts_matrix)
# 
# # create a simple plot
# df <- data.frame(
#     Sample = colnames(counts_matrix),
#     TotalCounts = total_abundance
# )
# 
# ggplot(df, aes(x = Sample, y = TotalCounts)) +
#     geom_bar(stat = "identity") +
#     theme_bw() +
#     ylab("Total abundance") +
#     xlab("Sample")
