

rm(list = ls())
gc()


# libraries ------

library(data.table)
library(stringr)
library(vegan)

library(ggplot2)
library(paletteer)
library(ggrepel)
library(ggforce)


# load data ------

load_bracken <- function(path) {
    x <- fread(path)
    x <- x[, c(1, 4:ncol(x)), with = FALSE]
    idx <- colnames(x) |> str_detect("\\.bracken_num")
    m <- as.matrix(x[, idx, with = FALSE])
    rownames(m) <- x$name
    colnames(m) <- colnames(m) |> str_split_i("\\_L001", 1)
    t(m)
}

mat_s <- load_bracken("abundance_table_species.tsv")
mat_g <- load_bracken("abundance_table_genus.tsv")
mat_p <- load_bracken("abundance_table_phylum.tsv")

d2 = "sample_metadata.csv" |> fread()


# clean data -----

rel_g <- decostand(mat_g, method = "total")
top   <- names(sort(colMeans(rel_g), decreasing = TRUE))[1:12]

comp <- data.table(
    Sample    = rep(rownames(rel_g), times = length(top)),
    taxon     = rep(top, each = nrow(rel_g)),
    abundance = as.vector(rel_g[, top])
)

comp <- merge(comp, d2, by = "Sample")

# ό,τι δεν είναι στα top 12
comp <- rbind(comp, comp[, .(taxon = "Other",
                             abundance = 1 - sum(abundance)),
                         by = .(Sample, Group)])


# plot -----

