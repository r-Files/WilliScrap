# Install packages required for the analysis.
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(data.table,
               rvest,
               dplyr,
               stringr,
               jsonlite,
               httr,
               funr,
               configr,
               rstudioapi,
               styler)

# make debugging easier
verbose_flag <- FALSE

# set working dir automatically
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("get_links.R", encoding = 'UTF-8')
source("single_scrap.R", encoding = 'UTF-8')


# Read configuration
configfile <- "config.json"
if (file.exists(configfile))
{
  if (is.json.file(configfile))
  {
    configuration <- read.config(file = configfile)
  }
} else {
  print("No config file found!")
}


# read existing scraps into results
if (file.exists(configuration$config$scrapfile))
{
  result <- fread(
    configuration$config$scrapfile,
    header = TRUE,
    key = 'id',
    encoding = 'UTF-8'
  )
} else {
  result <- data.table()
}

# get all links
new_ads <- lapply(seq_along(configuration$willhaben$pages), function(i) {
  links_per_district <- get_links(configuration$willhaben$pages[i])

  if (verbose_flag){
    # add a row-count to the data.table
    links_per_district[, ad_count := .I]
    setcolorder(links_per_district, c("ad_count", "district", "ad_id", "links"))
    links_per_district %>% fwrite(paste0("Links_for_district_", links_per_district$district[1], ".txt"))
  }
    
  
  temp_data <- data.table()

  # fetch ads to all links
  for (number in 1:nrow(links_per_district)) {

    # find unique ad-number in already scraped file and return row-number
    row_index <- match(links_per_district$ad_id[[number]], result$id)

    if (!is.na(row_index))
    {
      result[row_index, lastSeen := format(Sys.Date(), format = "%Y-%m-%d")]
      message <- "old ad"
    } else {

      if (verbose_flag)
        cat(links_per_district$links[[number]])
      
      # Fetch one ad and measure the time
      t0 <- Sys.time()
      one_ad <- single_scrap(links_per_district$links[[number]])
      t1 <- Sys.time()

      one_ad$firstSeen <- format(Sys.Date(), format = "%Y-%m-%d")
      one_ad$lastSeen <- format(Sys.Date(), format = "%Y-%m-%d")

      message <- "new ad"

      temp_data <- rbind(one_ad, temp_data, fill = TRUE)

      # sleep 1-3 times longer than response_delay
      response_delay <- as.numeric(t1 - t0)
      Sys.sleep(runif(1, min = 1, max = 3) * as.numeric(t1 - t0))
    }
    cat(
      'District: ',
      links_per_district$district[number],
      ' --> ',
      ' Processed: ',
      number,
      '/',
      nrow(links_per_district),
      ' --> ',
      ' This is an ',
      message,
      '\n',
      sep = ""
    )
  }
  return(temp_data)
})

# write those ads which were scraped during an update into a separate file
# which has a date in its name: scraped_YYYY_MM_DD.csv
rbindlist(new_ads, fill = TRUE) %>% 
  write.csv(
    file = paste0("scraped_", Sys.Date(), ".csv"),
    row.names = FALSE,
    fileEncoding = 'UTF-8'
  )

# write the old and new scraped ads combined into a file
rbindlist(new_ads, fill = TRUE) %>%
  rbind(result, fill = TRUE) %>%
  write.csv(
    file = configuration$config$scrapfile,
    row.names = FALSE,
    fileEncoding = 'UTF-8'
  )
