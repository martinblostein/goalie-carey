# goalie-carey: A statistical look at Mr. Saturday Night, Carey Price.

This is the code used to scrape, manipulate, plot and present NHL goaltender Carey Price's carreer
statistics to investigate whether he really does win more often on Saturday nights.

Data is scraped from www.hockeyreference.com using RSelenium. The R code to accomplish this is found in `scrape_data.R`.
This script pulls the data and stores it in the object `data_storage/raw_tables.rds`. For convenience, the results
of this scrape as of March 19, 2017 are already in this repo at the same file path.

Data is processed making heavy use of the `data.table` R package. The code to do this is found in `process_data.R`. 
This script begins with the file at `data_storage/raw_tables.rds` and populates many R objects into `data_storage/`.

The html presentation file and all of the plots are generated using `knitr` and `Rmarkdown`. This code can be found
in the file `writeUp.Rmd`. This script calls `process_data.R`, and uses the results to automatically generate up-to-date
graphics and analyses.

To reproduce the presentation from scratch, and ensure the data is up to date, one must just run `scrape_data.rds`
and then knit `writeUp.Rmd`/. It's probably easiest to do this using RStudio, but it can be done using R from the 
command line as well.
