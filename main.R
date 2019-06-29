# Install packages required for the analysis.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, rvest, dplyr, stringr, jsonlite, httr, funr, configr,
               rstudioapi)

# set working dir automatically
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("get_links.R", encoding='UTF-8')
source("single_scrap.R", encoding='UTF-8')


# Read configuration
configfile <- "config.json"
if(file.exists(configfile))
{
  if(is.json.file(configfile))
  {
    configuration <- read.config(file = configfile)
  }
} else {
  print("No config file found!")
}


# read existing scraps into results
if(file.exists(configuration$config$scrapfile))
{
  result <- fread(configuration$config$scrapfile,
                  header = TRUE,
                  key = 'id',
                  encoding = 'UTF-8')
} else {
  result <- data.table()
}


all_links <- lapply(configuration$willhaben$pages, function(x) {
  get_links(x)
}) %>% rbindlist()

# fetch ads to all links
for(number in 1:nrow(all_links)){
  # Fetch one ad and measure the time
  t0 <- Sys.time()
  cat(number,'/',nrow(all_links),all_links$links[[number]],'\n')
  one_ad <- single_scrap(all_links$links[[number]])
  t1 <- Sys.time()

  #merge add to existing ones if new or update last seen
  if(!(one_ad[["id"]] %in% result[["id"]])){
    one_ad$firstSeen <- format(Sys.Date(), format="%Y-%m-%d")
    one_ad$lastSeen <- format(Sys.Date(), format="%Y-%m-%d")
    result <- rbind(one_ad, result, fill=TRUE)

    # define id as key
    setkey(result,'id')
  }
  else{
    print('Not new')
    result[one_ad[["id"]]][['lastSeen']] <- format(Sys.Date(), format="%Y-%m-%d")
  }

  # sleep 1-10 times longer than response_delay
  response_delay <- as.numeric(t1-t0)
  Sys.sleep(runif(1, min = 1, max = 3)*as.numeric(t1-t0))
}

# Save scrap to csv
write.csv(result, configuration[["config"]][["scrapfile"]], row.names=FALSE, fileEncoding ='UTF-8')
