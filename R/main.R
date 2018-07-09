#' Boilerplate API check function
#'
#' @importFrom assertthat is.error
#' @keywords internal
apikey_511 <- function() {
  key511 <- Sys.getenv('APIKEY511')
  if (identical(key511, "")) {
    stop("Please set env var APIKEY511 to your MTC 511 API KEY",
      call. = FALSE)
  }

  key511
}

#' parse 511 xml into a table for each operator
#'
#' @return a tibble of operator names, privatecodes, and primary modes
#' @importFrom tibble tibble
#' @keywords internal
xml511_to_tibble <- function(oneop){
  tb1 <- tibble::tibble("privatecode" = oneop$PrivateCode[[1]],
                "name" = oneop$Name[[1]],
                "primarymode" = oneop$PrimaryMode[[1]])
  return(tb1)
}

#' Get metadata about MTC 511 operators
#' @return a tibble of operator names, privatecodes, and primary modes
#' @export
#' @importFrom xml2 read_xml as_list
#' @importFrom httr GET
#' @examples \dontrun{
#' #set your api key as an environmental variable
#' Sys.setenv(APIKEY511="yourkeyhere")
#' #if you don't have a key, you can get one here:
#' #https://511.org/developers/list/tokens/create
#' operator_df <- get_511_metadata()
#' head(operator_df)
#' }
get_511_metadata <- function() {
  operator_url = paste0("http://api.511.org/transit/operators?api_key=",
                        {apikey_511()},
                        "&Format=XML")
  r <- httr::GET(operator_url)
  x <- xml2::read_xml(r)
  l1 <- xml2::as_list(x)

  operator_metadata_list <- l1$Siri$ServiceDelivery$DataObjectDelivery$dataObjects$ResourceFrame$organisations

  l1 <- lapply(operator_metadata_list,xml511_to_tibble)
  df1 <- do.call("rbind",l1)
  return(df1)
}

#' Use the trread import_gtfs function to import an MTC 511 GTFS zip file into a list of R dataframes
#' @param privatecode this is the shortcode used by 511 to refer to operators. you can find these on the tibble returned from get_511_metadata
#' @return a list of GTFS dataframes
#' @export
#' @examples \dontrun{
#' #set your api key as an environmental variable
#' Sys.setenv(APIKEY511="yourkeyhere")
#' #if you don't have a key, you can get one here:
#' #https://511.org/developers/list/tokens/create
#' operator_df <- xml511_to_tibble()
#' bart_code <- df1[df1$name=='Bay Area Rapid Transit',]$privatecode
#' bart_gtfs_data <- get_mtc_511_gtfs(bart_code)
#' }
get_511_url <- function(privatecode) {
  zip_request_url = paste0('https://api.511.org/transit/datafeeds?api_key=',
                           apikey_511(),
                           '&operator_id=',
                           privatecode)
  return(zip_request_url)
}
