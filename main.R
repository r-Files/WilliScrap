# Install packages required for the analysis.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, rvest, dplyr, stringr, jsonlite)

source("get_links.R")
source("single_scrap.R")

test_link <- "https://www.willhaben.at/iad/immobilien/eigentumswohnung/wien/wien-1010-innere-stadt/"

all_links <- get_links(test_link)
one_ad <- single_scrap(all_links$links[[1]])

