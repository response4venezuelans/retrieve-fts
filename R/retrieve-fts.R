pacman::p_load(httr)


getUrl <- function(year, plan, country) {
  flowsUrl <- "https://api.hpc.tools/v1/public/fts/flow"
  arguments <- as.list(match.call())
  arguments[1] <- NULL # remove first item (function name)
  queryParams <- paste(lapply(names(arguments), function(n) { paste(n, arguments[n], sep="=") } ), collapse="&")
  url <- paste(flowsUrl, queryParams, sep="?")
  url
}

getFlows <- function(year, plan, country) {
}