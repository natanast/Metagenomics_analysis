

rm(list = ls())
gc()


# libraries ---------

library(data.table)
library(stringr)
library(dplyr)


# load data ---------

resfinder_files <- list.files("Resfinder/", pattern=".txt", full.names=TRUE)


# clean data -----

d <- list()

for(f in resfinder_files){
    
    sample <- f |> basename() |>  str_remove("_L\\d{3}\\.txt$")
    
    d1 <- f |> fread()
    
    d1 <- d1[, .(`Resistance gene`, Identity, sample)]
    
    # Store results if no error
    d[[f]] <- d1
}

d = d |> rbindlist(use.names = TRUE, fill = TRUE)


d_wide <- dcast(
    d,
    `Resistance gene` ~ sample,
    value.var = "Identity",
    fun.aggregate = function(x) if(all(is.na(x))) 0 else max(x, na.rm = TRUE)
)



d_wide[is.na(d_wide)] <- 0


writexl::write_xlsx(d_wide, "resfinder_merged.xlsx")

