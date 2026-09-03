

rm(list = ls())
gc()


# libraries ------

library(data.table)
library(stringr)
library(vegan)

library(ggplot2)
# library(ggpubr)
# library(ggforce)
library(paletteer)


# load data ------

d1 = "abundance_table_species.tsv" |> fread()

d2 = "sample_metadata.csv" |> fread()


# clean data -----

d1 <-  d1[, c(1, 4:ncol(d1)), with = FALSE]


index <-  colnames(d1) |> str_detect("\\.bracken_num")
d <-  d1[, index, with = FALSE]


mat <- as.matrix(d)
rownames(mat) <- d1$name
colnames(mat) <- colnames(mat) |> str_split_i("\\_L001", 1)
mat <- t(mat)



# beta diversity -----

# Between-sample diversity: how different the community composition is
# between samples. 
# 
# Counts are converted to relative abundances first, so
# that differences in sequencing depth do not drive the distances.
# 
# Bray-Curtis accounts for both which taxa are present and their relative
# abundances, ranging from 0 (identical) to 1 (no taxa in common). 

rel <- decostand(mat, method = "total")
bc  <- vegdist(rel, method = "bray")

# The distance matrix is projected into two dimensions so that samples
# with similar composition appear close to each other.
# PCoA is used

pcoa <- cmdscale(bc, k = 2, eig = TRUE)

# percentage of the total variation captured by each axis
var_expl <- round(100 * pcoa$eig[1:2] / sum(pcoa$eig[pcoa$eig > 0]), 1)

ord <- data.table(
    Sample = rownames(mat),
    PC1    = pcoa$points[, 1],
    PC2    = pcoa$points[, 2]
)

ord <- merge(ord, d2, by = "Sample")


