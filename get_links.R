get_links <- function(entry_point){

  ad_list <- data.table(links = character())
  page_content <- read_html(entry_point)

  repeat
  {
    # wait
    Sys.sleep(1)
    ad_list <- page_content %>%
      html_nodes("[class='content-section isRealestate']") %>%
      html_nodes("a") %>%
      html_attr("href") %>%
      as.data.table() %>%
      setnames("links") %>%
      rbind(ad_list)

    next_page <- page_content %>%
      html_nodes("link[rel='next']") %>%
      html_attr("href")

    if(identical(next_page, character(0)))
    {
      break
    } else {
      page_content <- next_page %>% {paste0("https:",.)} %>% read_html()
    }
  }

  ad_list[, links := paste0("https://www.willhaben.at", links)]
  # extract the id from the urls and save it as a separate column
  ad_list[, ad_id := links %>%
            str_extract("-\\d{9}/$") %>% # find nine digit number at end of url
            str_replace_all("^.|.$", "")] # delete first and last character 
  
  ad_list[, district := links %>%
            # extract wien-1XX0- from url --> we don't directly search for 4
            # digits in the url to make this command more fail save
            str_extract("wien-1\\d{2}0-") %>% 
            str_extract("\\d{4}")] # extract just the four digits
    
  if (ad_list$district %>% unique() %>% length() != 1)
    stop("Differnt districts within one scrap...")
  
  return(ad_list)
}

# test <- get_links("https://www.willhaben.at/iad/immobilien/eigentumswohnung/wien/wien-1080-josefstadt/?rows=100")

