

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(vegan)


# load data ---------

d1 = "gene_counts_cleaned_poolA.xlsx" |> 
    readxl::read_excel() |> 
    setDT()

d2 = "gene_counts_cleaned_poolB.xlsx" |> 
    readxl::read_excel() |> 
    setDT()


# separate -----

counts_matrix <- d2[, -1, with = FALSE]  
counts_matrix <- as.matrix(counts_matrix)

counts_matrix_t <- t(counts_matrix)



# rarefaction curves -----

png("rarefaction_curves_poolB.png",
    width = 3000, height = 2400, res = 300)

rarecurve(
    counts_matrix_t, 
    step = 100,
    sample = min(rowSums(counts_matrix_t)),
    col = "darkgreen",
    label = TRUE,
    cex = 0.4,
    xlab = "Sequencing depth (reads)",
    ylab = "Observed AMR genes"
)

dev.off()


# all ------
d <- d1 |>
    merge(d2, by = "Geneid", all = TRUE)


# Replace NAs only in numeric columns (leave Geneid intact)
d[, (2:ncol(d)) := lapply(.SD, function(x) ifelse(is.na(x), 0, x)), .SDcols=2:ncol(d)]



counts_matrix <- d[, -1, with = FALSE]  
counts_matrix <- as.matrix(counts_matrix)

counts_matrix_t <- t(counts_matrix)



# rarefaction curves -----

png("rarefaction_curves_all_highMQ.png",
    width = 3000, height = 2400, res = 300)

rarecurve(
    counts_matrix_t, 
    step = 100,
    sample = min(rowSums(counts_matrix_t)),
    col = "darkgreen",
    label = TRUE,
    cex = 0.4,
    xlab = "Sequencing depth (reads)",
    ylab = "Observed AMR genes"
)

dev.off()

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
