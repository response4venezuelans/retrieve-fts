# retrieve-fts

Get data from the FTS API

The `getFlows` function returns all flows on the given boundary (currently supports year and plan). It internally places calls to the API to retrieve all paginated data until the end is reached, appends it to the resulting data frame.

## Usage
```
source('/path/to/retrieve-fts/R/retrieve-fts.R')
getFlows(<year>, <plan id>)
```

## Power BI

Similar to general usage, but using Windows-friendly paths, and being sure to assign the result to a variable so that Power BI can read it, e.g.
```
source("C:\\Path\\To\\retrieve-fts\\R\\retrieve-fts.R")
Flows <- getFlows(<year>, <plan id>)
```

To get Power BI-compatible tables for sources and destinations, use the ```getSources``` and ```getDestinations``` functions respectively.

*Tip* Complex data types within the returned data frame are not readable by Power BI - delete those columns to avoid error messages.

See [Run R scripts](https://docs.microsoft.com/en-us/power-bi/connect-data/desktop-r-scripts) for more info.
