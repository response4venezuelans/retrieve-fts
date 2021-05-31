pacman::p_load(httr,
               dplyr,
               tidyr)

#' getUrl
#' 
#' @year The year boundary
#' @planid The plan boundary
#' 
#' @description Construct FTS API URL
#' 
#' Could be expanded to include more parameters - parameters should be named according
#' to API spec (default values and null checks would be necessary)
#'
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

#' getFlowsRecursive
#' 
#' @param df A data frame (for recursive accumulation). When provided, the results
#' of the API calls are combined into the data frame (rbind) 
#' @param url A fully qualified URL for retrieving FTS data. If null, the data frame
#' is returned
#' 
#' @description Retrieve all flows starting from the provided URL using the "next" link returned by
#' each subsequent request, until no next URL is available
#' 
getFlowsRecursive <- function(df=NULL, url) {
  if (!is.null(url)) {
    print(sprintf('Retrieving %s', url))
    
    # get data page
    res = httr::GET(url)
    
    # stop if error
    httr::stop_for_status(res, paste("get",url))
    
    # convert json to object
    resData <- jsonlite::fromJSON(httr::content(res, "text"))
    
    # append flows to data frame
    if (is.null(df)) 
      df <- resData$data$flows
    else
      df <- rbind(df, resData$data$flows)

    # get next data page
    getFlowsRecursive(df, resData$meta$nextLink)
  }
  df
}

#' getFlows
#' @param year Required, the boundary year
#' @param planid Required, the boundary plan id
#' 
#' Returns all flows on the boundary from FTS
#' 
getFlows <- function(year, planid) {
  print(sprintf("Getting flows for year=%s, plan=%s", year, planid))
  url <- getUrl(year, planid)
  getFlowsRecursive(url=url)
}
