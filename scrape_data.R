library(RSelenium)
library(rvest)
library(data.table)

baseURL <- "http://www.hockey-reference.com/players/p/priceca01/gamelog/"
years <- 2008:2017
regularSeasonURLs <- paste0(baseURL, years)
playoffURL <- paste0(baseURL, "playoffs")

rD <- rsDriver(browser = "firefox")
rD$client$navigate(playoffURL)
raw_table_playoffs <- rD$client$getPageSource()[[1]] %>%
    htmlParse() %>%
    readHTMLTable(stringsAsFactors = FALSE) %>%
    getElement("gamelog_playoffs") %>%
    as.data.table() %>%
    rbind()

raw_tables_season <- rbindlist(
    lapply(regularSeasonURLs, function(seasonURL) {
        rD$client$navigate(seasonURL)
        rD$client$getPageSource()[[1]] %>%
            htmlParse() %>%
            readHTMLTable(stringsAsFactors = FALSE) %>%
            getElement("gamelog") %>%
            as.data.table()
    })
)

rD$server$stop()

raw_tables_season[, playoffs := FALSE]
raw_table_playoffs[, playoffs := TRUE]

raw_tables <- rbind(raw_tables_season, raw_table_playoffs)
saveRDS(raw_tables, file = "raw_tables.rds")
