pacman::p_load(httr,
               tidyr)


getUrl <- function(year, planid) {
  flowsUrl <- "https://api.hpc.tools/v1/public/fts/flow"
  arguments <- as.list(environment())[-1] # get function call and remove first item (function name)
  arguments["format"] = "json"
  queryParams <- paste(lapply(names(arguments), function(n) { 
    val <- arguments[n]
    paste(n, val, sep="=") 
  } ), collapse="&")
  url <- paste(flowsUrl, queryParams, sep="?")
  url
}

getFlowsRecursive <- function(df, url) {
  if (!is.null(url)) {
    # get data page
    res = httr::GET(url)
    
    # stop if error
    httr::stop_for_status(res, paste("get",url))
    
    # convert json to object
    resData <- jsonlite::fromJSON(httr::content(res, "text"))
    
    # append flows to data frame
    rbind(df, resData$flows)
    
    # get next data page
    getFlowsRecursive(df, resData$meta$nextLink)
  }
}

getFlows <- function(df, year, planid) {
  print(sprintf("Getting flows for year=%s, plan=%s", year, planid))
  url <- getUrl(year, planid)
  getFlowsRecursive(df, url)
  df
}