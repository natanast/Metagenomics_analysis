

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


# plot -----

gr2 <- ggplot(ord, aes(PC1, PC2, fill = Group)) +
    
    # geom_hline(yintercept = 0, linewidth = .3, linetype = "dashed", color = "grey60") +
    # 
    # geom_vline(xintercept = 0, linewidth = .3, linetype = "dashed", color = "grey60") +

    geom_point(shape = 21, size = 4, stroke = .25, color = "black") +
    
    geom_mark_circle(
        aes(fill = Group, color = Group, label = Group),
        alpha = .1,
        expand = unit(1.5, "mm")
    ) +
    
    # geom_text_repel(aes(label = Sample), size = 3, show.legend = FALSE) +
    
    scale_fill_manual(values = paletteer_d("ggthemes::Color_Blind")) +
    scale_color_manual(values = paletteer_d("ggthemes::Color_Blind")) +
    
    
    labs(
        x = paste0("PCoA 1 (", var_expl[1], "%)"),
        y = paste0("PCoA 2 (", var_expl[2], "%)")
    ) +
    
    theme_minimal() +
    
    theme(
        legend.position = "none",
        
        axis.text = element_text(size = 10, color = "grey30"),
        axis.title = element_text(size = 12, color = "grey25"), 
        
        panel.grid.major = element_line(linewidth = .35, color = "grey93"),
        panel.grid.minor = element_line(linewidth = .35, linetype = "dashed", color = "grey93"),
        
        plot.margin = margin(20, 20, 20, 20)
    )

gr2

ggsave(plot = gr2, filename = "beta_diversity_pcoa.png",
       width = 10, height = 10, units = "in", dpi = 600)
