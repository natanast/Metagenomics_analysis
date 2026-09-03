

rm(list = ls())
gc()


# libraries ------

library(data.table)
library(stringr)
library(vegan)


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




