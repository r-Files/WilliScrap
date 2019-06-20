send_mail <- function(to, Body, Subject = "Automatic Scrapper Report"){
  
  # read the credentials for the mail account
  config <- fromJSON("config_sec.json")
  
  # we are using Powershell-Cmdlets --> so we have to wrap text strings into 
  # single quotes 
  mailFrom <- paste0("'", config$gmail$account, "'")
  password <- paste0("'", config$gmail$password, "'")
  mailTo   <- paste0("'", to, "'")
  Subject  <- paste0("'", Subject, "'")
  Body     <- paste0("'", Body, "'")
  

  # Create a new SMTP-client and send the mail with Powershell.
  system2("powershell", args = c(c("$EmailFrom =", mailFrom) %>% paste(collapse = ""),
                                 c("$EmailTo ="  , mailTo)   %>% paste(collapse = ""),
                                 c("$Subject ="  , Subject)  %>% paste(collapse = ""),
                                 c("$Body ="     , Body)     %>% paste(collapse = ""),
                                 "$SMTPClient = New-Object Net.Mail.SmtpClient('smtp.gmail.com', 587)",
                                 "$SMTPClient.EnableSsl = $true",
                                 c("$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(", mailFrom, ",", password, ")") %>% paste(collapse = ""),
                                 "$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)") %>% paste(collapse = ";"))
}

# send_mail(to = "fabian.pribahsnik@gmx.at", Body = "Test")
