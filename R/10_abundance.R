

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

d <- "sample_metadata.csv" |> fread()
x <- fread("abundance_table_genus.tsv")

# Bracken output is read and reshaped into a matrix with samples as rows
# and taxa as columns, as expected by vegan. Only the read count columns
# are kept: the relative abundance columns are redundant, and the
# annotation columns would coerce the matrix to character.


x <- x[, c(1, 4:ncol(x)), with = FALSE]

idx <- colnames(x) |> str_detect("\\.bracken_num")

mat_g <- as.matrix(x[, idx, with = FALSE])
rownames(mat_g) <- x$name
colnames(mat_g) <- colnames(mat_g) |> str_split_i("\\_L001", 1)
mat_g <- t(mat_g)


# The same data at three taxonomic levels: species for diversity metrics,
# genus for composition plots, phylum for a high-level overview.

# mat_s <- load_bracken("abundance_table_species.tsv")
# mat_g <- load_bracken("abundance_table_genus.tsv")
mat_p <- load_bracken("abundance_table_phylum.tsv")

dim(mat_g)
# dim(mat_p)


# taxonomic composition -----
# Alpha and beta diversity show whether the groups differ; this shows
# in what. Counts are converted to relative abundances so that samples
# sequenced at different depth are comparable.
rel_g <- decostand(mat_g, method = "total")

# Only a limited number of taxa can be distinguished by colour, so the
# most abundant genera across all samples are selected and everything
# else is aggregated into "Other" below.
top   <- names(sort(colMeans(rel_g), decreasing = TRUE))[1:12]


# proportion of the total composition covered by the selected genera
sum(colMeans(rel_g)[top])


# The matrix is reshaped into long format, one row per sample-taxon
# pair, as required by ggplot. as.vector() unwinds the matrix column by
# column, so the labels are repeated to match: the sample list as a
# whole ("times"), each taxon name consecutively ("each").
comp <- data.table(
    Sample    = rep(rownames(rel_g), times = length(top)),
    taxon     = rep(top, each = nrow(rel_g)),
    abundance = as.vector(rel_g[, top])
)

comp <- merge(comp, d, by = "Sample")

# The selected genera do not account for the full composition of a
# sample. The remainder is added as a single "Other" category, so that
# every bar sums to 100% and no abundance is silently dropped.

comp <- rbind(
    comp,
    comp[, .(taxon = "Other", abundance = 1 - sum(abundance)),
         by = .(Sample, Group)]
)


# plot -----

gr3 <- ggplot(comp, aes(Sample, abundance, fill = taxon)) +
    
    geom_col(width = .75) +
    
    facet_grid(~ Group, scales = "free_x", space = "free_x") +
    
    scale_fill_manual(values = paletteer_d("ggthemes::Tableau_20")) +
    scale_y_continuous(labels = scales::percent, expand = c(0, 0)) +
    
    labs(x = NULL, y = "Relative abundance", fill = NULL) +
    
    theme_minimal() +
    
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.text = element_text(size = 8, face = "italic"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        plot.margin = margin(20, 20, 20, 20)
    )


ggsave(plot = gr3, filename = "abudance_plot.png",
       width = 12, height = 7, units = "in", dpi = 600)