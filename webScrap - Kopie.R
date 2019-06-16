# Install packages required for the analysis.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, rvest, dplyr)

single_flat <- read_html(
  "https://www.willhaben.at/iad/immobilien/d/eigentumswohnung/wien/wien-1010-innere-stadt/prachtvolle-altbauwohnung-mit-blick-auf-das-naturhistorische-museum-in-1010-wien-zu-kaufen-314009082/?counterId=112"
)


single_flat %>% html_nodes(".box-block ") %>% html_nodes(".box-heading") %>% html_nodes("h2") %>% html_text()
# euqivalent --> single_flat %>% html_nodes(".box-block .box-heading h2")
# get only those boxes: single_flat %>% html_nodes("[class='box-block ']")

test <- single_flat %>% html_nodes(".box-block ")


single_flat %>% html_nodes(".box-block ") %>% html_nodes(".box-body") %>% html_nodes(".description") %>% html_text()




single_flat %>% html_nodes(".box-block .box-heading")


test <- single_flat %>% html_nodes("[class='box-block ']") %>% html_nodes(".box-heading h2") %>% html_text()


all_boxes <- single_flat %>% html_nodes("[class='box-block ']")


all_boxes %>% html_nodes(".col-2-desc") %>% html_text()
all_boxes %>% html_nodes(".col-2-body") %>% html_text()

