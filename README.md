# retrieve-fts

Get data from the FTS API

The `getFlows` function returns all flows on the given boundary (currently supports year and plan). It internally places calls to the API to retrieve all paginated data until the end is reached, appends it to the resulting data frame.

## Usage
```
source('/path/to/retrieve-fts/R/retrieve-fts.R')
getFlows(<year>, <plan id>)
```

## Power BI

Same as general usage, but ensure to assign the result to a variable so that Power BI can read it, e.g. `flows <- getFlows`

🚧 The format returned is currenty only partially compatible with Power BI, primarily sources and destinations are not available. 🚧

See [Run R scripts](https://docs.microsoft.com/en-us/power-bi/connect-data/desktop-r-scripts) for more info.
