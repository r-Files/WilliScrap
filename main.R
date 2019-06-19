# Install packages required for the analysis.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, rvest, dplyr, stringr, jsonlite, httr)

source("get_links.R", encoding='UTF-8')
source("single_scrap.R", encoding='UTF-8')


# Configuration
scrapfile <- 'flats.csv'
test_link <- "https://www.willhaben.at/iad/immobilien/eigentumswohnung/wien/wien-1010-innere-stadt/"


# read existing scraps into results
if(file.exists(scrapfile))
{
  result <- fread(scrapfile, colClasses = 'character', header=TRUE, key='id', encoding='UTF-8')
  setkey(result,'id')
} else {
  result <- data.table()
}

# fetch all links
all_links <- get_links(test_link)

# fetch ads to all links
for(number in 1:10){#nrow(all_links)){
  # Fetch one ad and measure the time
  t0 <- Sys.time()
  cat(number,'/',nrow(all_links),all_links$links[[number]],'\n')
  one_ad <- single_scrap(all_links$links[[number]])
  t1 <- Sys.time()

  #merge add to existing ones if new or update last seen
  if(!(one_ad[["id"]] %in% result[["id"]])){
    one_ad$firstSeen <- Sys.Date()
    one_ad$lastSeen <- Sys.Date()
    result <- rbind(one_ad, result, fill=TRUE)

    # define id as key
    setkey(result,'id')
  }
  else{
    print('Not new')
    result[one_ad[["id"]]][['lastSeen']] <- Sys.Date()
  }

  # sleep 1-10 times longer than response_delay
  response_delay <- as.numeric(t1-t0)
  Sys.sleep(runif(1, min = 1, max = 10)*as.numeric(t1-t0))
}

# Save scrap to csv
write.csv(result, scrapfile, quote=TRUE, row.names=FALSE, fileEncoding ='UTF-8')
