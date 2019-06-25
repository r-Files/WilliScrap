# Install packages required for the analysis.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(data.table, rvest, dplyr, stringr, jsonlite, httr, funr, configr)

# set working dir automatically
setwd(get_script_path())
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
if(file.exists(configuration[["config"]][["scrapfile"]]))
{
  result <- fread(configuration[["config"]][["scrapfile"]], header=TRUE, key='id', encoding='UTF-8')
  setkey(result,'id')
} else {
  result <- data.table()
}

# fetch all links
all_links <- data.table()
for(number in 1:length(configuration[["willhaben"]][["pages"]])){
  dummy <- get_links(configuration[["willhaben"]][["pages"]][[number]])
  all_links <- rbind(all_links,dummy)
}


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
