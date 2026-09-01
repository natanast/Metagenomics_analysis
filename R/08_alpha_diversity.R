

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


# clean data -----

d1 <-  d1[, c(1, 4:ncol(d1)), with = FALSE]


index <-  colnames(d1) |> str_detect("\\.bracken_num")
d <-  d1[, index, with = FALSE]


mat <- as.matrix(d)
colnames(d) <- colnames(d) |> str_split_i("\\_L001", 1)
rownames(mat) <- d1$name


mat <- t(d)

# alpha diversity -----

alpha <- data.table(
    Sample   = rownames(mat),
    depth    = rowSums(mat),
    observed = specnumber(mat),
    shannon  = diversity(mat, index = "shannon"),
    simpson  = diversity(mat, index = "simpson")
)


alpha[, evenness := shannon / log(observed)]

alpha <- merge(alpha, d2, by = "Sample")

alpha[, observed := as.numeric(observed)]   


# plot ------

library(ggplot2)
library(ggpubr)

alpha_long <- melt(alpha,
                   id.vars      = c("Sample", "Group"),
                   measure.vars = c("observed", "shannon", "simpson", "evenness"),
                   variable.name = "index",
                   value.name    = "value")


ggplot(alpha_long, aes(Group, value, fill = Group)) +
    geom_boxplot(alpha = 0.5, outlier.shape = NA) +
    geom_jitter(width = 0.15, size = 2.5) +
    # stat_compare_means(method = "kruskal.test", size = 2, label.y.npc = .99) +
    facet_wrap(~ index, scales = "free_y") +
    labs(x = NULL, y = NULL) +
    theme_bw() +
    theme(legend.position = "none")

