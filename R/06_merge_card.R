

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(dplyr)


# load data ---------

card_files <- list.files("CARD/CARD_Gene_mapping/", pattern=".xlsx", full.names=TRUE)


# clean data -----

d <- list()

for(f in card_files){
    
    sample <- f |> basename() |>  str_remove("_L\\d{3}\\.xlsx$")
    
    d1 <- f |> readxl::read_xlsx() |> setDT()
    
    d1 <- d1[, .(`ARO Term`, `AMR Gene Family`, `Drug Class`, `Resistance Mechanism`, `Average Percent Coverage`, sample)]
    
    # Store results if no error
    d[[f]] <- d1
}

d = d |> rbindlist(use.names = TRUE, fill = TRUE)


d_wide <- dcast(
    d,
    `ARO Term` + `AMR Gene Family` + `Drug Class` + `Resistance Mechanism`
    ~ sample,
    value.var = "Average Percent Coverage"
)


d_wide[is.na(d_wide)] <- 0


writexl::write_xlsx(d_wide, "card_merged.xlsx")

