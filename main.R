# Install packages required for the analysis.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, rvest, dplyr, stringr, jsonlite, httr)

source("get_links.R")
source("single_scrap.R")

result <- data.table()
test_link <- "https://www.willhaben.at/iad/immobilien/eigentumswohnung/wien/wien-1010-innere-stadt/"

all_links <- get_links(test_link)

for(number in 1:nrow(all_links)){
  # Fetch one ad and measure the time
  t0 <- Sys.time()
  print(all_links$links[[number]])
  one_ad <- single_scrap(all_links$links[[number]])
  t1 <- Sys.time()
  
  #merge add to existing ones
  result <- rbind(result,one_ad, fill=TRUE)

  # sleep 10 times longer than response_delay
  response_delay <- as.numeric(t1-t0)
  Sys.sleep(10*response_delay) 
}
one_ad <- single_scrap(all_links$links[[1]])

