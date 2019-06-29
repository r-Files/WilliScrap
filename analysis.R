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


analysis <-split(result,by="district") %>% lapply(., summary)
