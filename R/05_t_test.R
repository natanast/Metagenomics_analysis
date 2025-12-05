

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(dplyr)


# load data ---------

df1 <- "coverage_poolA.xlsx" |> readxl::read_xlsx() |> setDT()
df2 <- "coverage_poolB.xlsx" |> readxl::read_xlsx() |> setDT()



# clean data -----

df <- df1 |>
    merge(df2, by = "gene_name")


# Samples to remove
samples_to_remove <- c("LAG_PRO_S56", "LAG_TEL_S53", "D_Xorafi_S54", "DelAx_PRO_S55", "DelAx_TEL_S52")

df <- df[, !samples_to_remove, with = FALSE]



sample_cols <- colnames(df[,-1])


for (col in sample_cols) {
    
    set(df, j = col, value = ifelse(df[[col]] >= 0.8, 1, 0))
}


# groups -----

groups <- str_sub(sample_cols, 1, 1)  
samples_by_group <- split(sample_cols, groups)


groupA <- samples_by_group$A
groupB <- samples_by_group$B
groupC <- samples_by_group$C
groupD <- samples_by_group$D
groupE <- samples_by_group$E
 


df_collapsed <- copy(df)  


for(g in names(samples_by_group)){
    
    df_collapsed[, (g) := rowSums(.SD), .SDcols = samples_by_group[[g]]]
}


# Keep only gene_name and the new group columns
df_collapsed <- df_collapsed[, c("gene_name", names(samples_by_group)), with = FALSE]


# filter df -------

index <- rowSums(df_collapsed[, 2:ncol(df_collapsed), with = FALSE] > 0) > 0

df_collapsed <- df_collapsed[index, ]



# t-test -----


dt <- copy(df_collapsed)

groups <- colnames(dt)[-1]  


combos <- combn(groups, 2, simplify = FALSE)


# Store results
results <- data.table(
    group1 = character(),
    group2 = character(),
    t_stat = numeric(),
    df = numeric(),
    p_value = numeric(),
    mean1 = numeric(),
    mean2 = numeric()
)

# Run t-tests for each pair
for(c in combos){
    
    g1 <- c[1]
    g2 <- c[2]
    
    x <- dt[[g1]]
    y <- dt[[g2]]
    
    tt <- t.test(x, y, paired = FALSE)
    
    results <- rbind(results, data.table(
        group1 = g1,
        group2 = g2,
        t_stat = tt$statistic,
        df = tt$parameter,
        p_value = tt$p.value,
        mean1 = mean(x),
        mean2 = mean(y)
    ))
}


results[, p_adj := p.adjust(p_value, method = "BH")]



write.csv(results, "t_test_report.csv", row.names = FALSE)


