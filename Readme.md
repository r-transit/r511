[![Travis-CI Build Status](https://travis-ci.com/r-gtfs/r511.svg?branch=master)](https://travis-ci.com/r-gtfs/r511)
[![cran version](https://www.r-pkg.org/badges/version/r511)](https://cran.r-project.org/package=r511)

r511 Readme
================
Tom Buckley
7/9/2018

## Installation

Until the package is published on CRAN, you can install this package from GitHub using the devtools
package:

    if (!require(devtools)) {
        install.packages('devtools')
    }
    devtools::install_github('r-gtfs/r511')

## Usage 

-   [Set your api key as an environmental variable](#set-your-api-key-as-an-environmental-variable)
-   [Get MTC 511 Operator List](#get-mtc-511-operator-list)
-   [Get URL for GTFS Data](#get-url-for-gtfs-data)
-   [Import Data](#import-data)
-   [Example: Summarise Stops Per Route](#example-summarise-stops-per-route)

Set your api key as an environmental variable
---------------------------------------------

If you don't have a key, you can get one here:
<https://511.org/developers/list/tokens/create>

``` r
#Sys.setenv(APIKEY511="yourkeyhere")
```

Get MTC 511 Operator List
-------------------------

This function pulls a list of operator names, modes, and private codes. The latter we use to make requests for GTFS data.

``` r
operator_df <- get_511_metadata()
head(operator_df)
#> # A tibble: 6 x 3
#>   privatecode name                      primarymode
#>   <chr>       <chr>                     <chr>      
#> 1 5E          511 Emergency             other      
#> 2 5F          511 Flap Sign             other      
#> 3 5O          511 Operations            other      
#> 4 5S          511 Staff                 other      
#> 5 AC          AC Transit                bus        
#> 6 CE          Altamont Corridor Express rail
```

Get URL for GTFS Data
---------------------

You can use the get\_511\_url() function to build a URL from which you can directly download GTFS data for an operator.

``` r
bart_code <- operator_df[operator_df$name=='Bay Area Rapid Transit',]$privatecode
bart_gtfs_url <- get_511_url(bart_code)
```

Import Data
-----------

Using [trread](https://github.com/r-gtfs/trread), load BART data into R as a list of dataframes.

``` r
library(trread)
bart_gtfs_data <- import_gtfs(bart_gtfs_url)
#>  [1] "agency.txt"              "calendar_attributes.txt"
#>  [3] "calendar_dates.txt"      "calendar.txt"           
#>  [5] "directions.txt"          "fare_attributes.txt"    
#>  [7] "fare_rules.txt"          "farezone_attributes.txt"
#>  [9] "feed_info.txt"           "rider_categories.txt"   
#> [11] "routes.txt"              "shapes.txt"             
#> [13] "stop_times.txt"          "stops.txt"              
#> [15] "trips.txt"
```

Example: Summarise Stops Per Route
----------------------------------

Summarise the number of stops per route on BART.

``` r
library(dplyr)
attach(bart_gtfs_data)

routes_df %>% inner_join(trips_df, by="route_id") %>%
  inner_join(stop_times_df, by="trip_id") %>% 
    inner_join(stops_df, by="stop_id") %>% 
      group_by(route_long_name) %>%
        summarise(stop_count=n_distinct(stop_id)) %>%
  arrange(desc(stop_count))
#> # A tibble: 6 x 2
#>   route_long_name                        stop_count
#>   <chr>                                       <int>
#> 1 Antioch - SFIA/Millbrae                        28
#> 2 Richmond - Daly City/Millbrae                  23
#> 3 Warm Springs/South Fremont - Daly City         20
#> 4 Warm Springs/South Fremont - Richmond          19
#> 5 Dublin/Pleasanton - Daly City                  18
#> 6 Oakland Airport - Coliseum                      2
```
