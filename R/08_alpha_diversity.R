

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

# Within-sample diversity: how many taxa are present and how evenly
# they are distributed.
#   observed = number of species
#   shannon  = richness combined with evenness
#   simpson  = probability that two random reads belong to different species
#   evenness = evenness independent of richness (Pielou's J)

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


# statistical testing -----

# Kruskal-Wallis (non-parametric): do the groups differ?
# Used instead of ANOVA because with n = 4 per group normality
# cannot be assessed.

kruskal.test(shannon  ~ factor(Group), data = alpha)
kruskal.test(observed ~ factor(Group), data = alpha)


# sequencing depth control -----

# Richness depends on the number of reads per sample. The correlation
# is checked first, then the analysis is repeated after rarefying all
# samples to a common depth, to rule out a technical artefact.

cor.test(alpha$depth, alpha$observed, method = "spearman")


mat_rare <- rrarefy(mat, min(rowSums(mat)))

alpha_rare <- data.table(
    Sample   = rownames(mat_rare),
    observed = specnumber(mat_rare),
    shannon  = diversity(mat_rare, index = "shannon")
)
alpha_rare <- merge(alpha_rare, d2, by = "Sample")

kruskal.test(shannon  ~ factor(Group), data = alpha_rare)
kruskal.test(observed ~ factor(Group), data = alpha_rare)


fwrite(alpha, "alpha_diversity.csv")

# plot ------

library(ggplot2)
library(ggpubr)

alpha_long <- melt(alpha,
                   id.vars      = c("Sample", "Group"),
                   measure.vars = c("observed", "shannon", "simpson", "evenness"),
                   variable.name = "index",
                   value.name    = "value")


gr <- ggplot(alpha_long, aes(Group, value, fill = Group)) +
    geom_boxplot(alpha = 0.5, outlier.shape = NA) +
    geom_jitter(width = 0.15, size = 2.5) +
    # stat_compare_means(method = "kruskal.test", size = 2, label.y.npc = .99) +
    facet_wrap(~ index, scales = "free_y") +
    labs(x = NULL, y = NULL) +
    theme_bw() +
    theme(legend.position = "none")

ggsave(
    plot = gr, filename = "alpha_diversity.png",
    width = 10, height = 10, units = "in", dpi = 600
)

