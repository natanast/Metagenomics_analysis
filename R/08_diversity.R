

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(vegan)


# load data ---------

library(data.table)
library(stringr)
library(vegan)


# load data ------

d1 = "abundance_table_species.tsv" |> fread()

d2 = "sample_metadata.csv" |> fread()
