get_links <- function(entry_point){

  pages <- data.table(link = entry_point)

  ad_list <- data.table(links = character())

  page_content <- read_html(entry_point)

  repeat
  {
    # wait
    Sys.sleep(3)
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
  return(ad_list)

}

# aaa <- get_links(test_entry)
