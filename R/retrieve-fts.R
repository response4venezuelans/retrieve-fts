pacman::p_load(httr,
               dplyr,
               tidyr)

#' (Internal) Returns the FTS API URL for the flows on the specified boundary.
#' At least one of the boundary parameters is required.
#' 
#' @year The year boundary
#' @planid The plan boundary
#' 
#' @description Construct FTS API URL
#' 
#' Could be expanded to include more parameters - parameters should be named according
#' to API spec (default values and null checks would be necessary)
#'
getUrl <- function(year=NULL, planid=NULL) {
  arguments <- as.list(environment())
  arguments[["format"]] = "json"
  flowsUrl <- httr::modify_url("https://api.hpc.tools/v1/public/fts/flow", query = arguments)
  return(flowsUrl)
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
    df <- bind_rows(df, resData$data$flows)
  
  if (is.null(resData$meta$nextLink)) {
    return(df)
  }
  else {
    getFlowsRecursive(df, resData$meta$nextLink)
  }
}

#'
#' @param flows A data frame containing the flows API response
#' @param varName The variable to format (sourceObjects or destinationObjects)
#' @return A data frame containing the source or destination data pivoted across
#' the flows
formatSrcDest <- function(flows, varName) {
  srcDest <-
    flows %>% 
    select(flowid  = id, varName) %>% 
    unnest(cols = c(varName)) %>% 
    mutate(across(c(organizationTypes, organizationSubTypes), as.character))
  srcDest <- merge(y = srcDest, x = flows, by.y = "flowid",by.x = "id")
  return(srcDest)
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
  flows <- getFlowsRecursive(url=url)
}

#' Return sources data pivoted against flows data
#' 
#' @param flows (Optional) A data frame containing the flows API response. If not
#' provided, the flows are retrieved on the specified year and plan boundary.
#' @param year (Optional) The boundary year (if ```flows``` not provided)
#' @param planid (Optional) The boundary plan (if ```flows``` not provided)
#' 
getSources <- function(flows=NULL, year=NULL, planid=NULL) {
  if (is.null(flows)) {
    flows <- getFlows(year, planid)
  }
  sources <- formatSrcDest(flows, "sourceObjects")
}

#' Return destination data pivoted against flows data
#' 
#' @param flows (Optional) A data frame containing the flows API response. If not
#' provided, the flows are retrieved on the specified year and plan boundary.
#' @param year (Optional) The boundary year (if ```flows``` not provided)
#' @param planid (Optional) The boundary plan (if ```flows``` not provided)
#' 
getDestinations <- function(flows=NULL, year=NULL, planid=NULL) {
  if (is.null(flows)) {
    flows <- getFlows(year, planid)
  }
  destinations <- formatSrcDest(flows, "destinationObjects")
}
