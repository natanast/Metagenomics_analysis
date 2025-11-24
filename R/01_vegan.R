
rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(vegan)

# load data ---------

d = "amr-counts.txt" |> fread()

# data cleaning -------

d = d[, c(1, 7:ncol(d)), with = FALSE]

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
    label = FALSE
)
