#' Return listMarketBook data
#'
#' \code{listMarketBook} returns pricing data for the selected market.
#'
#' \code{listMarketBook} returns pricing data for the selected market. It is
#' also possible to filter price returns based on either those currently
#' available or the volume currently available in the Starting Price (SP)
#' market.
#'
#' @seealso \code{\link{loginBF}}, which must be executed first. Do NOT use the
#'   DELAY application key. The DELAY application key does not support price
#'   data.
#'
#' @param marketIds String. The market identification number of the required
#'   event. IDs can be obtained via \code{\link{listMarketCatalogue}}. Required.
#'   No default.
#'
#' @param priceData String. Supports five price data types, one of which must be
#'   specified. Valid price data types are SP_AVAILABLE, SP_TRADED,
#'   EX_BEST_OFFERS, EX_ALL_OFFERS and EX_TRADED. Must be upper case. See note
#'   below explaining each of these options. Required. no default.
#'
#' @param orderProjection string. Restricts the results to the specified order
#'   status. Possible values are: "EXECUTABLE" (An order that has a remaining
#'   unmatched portion); "EXECUTION_COMPLETE" (An order that does not have any
#'   remaining unmatched portion); "ALL" (EXECUTABLE and EXECUTION_COMPLETE
#'   orders). Default value is NULL, which Betfair interprets as "ALL".
#'   Optional.
#'
#' @param matchProjection string. If orders are requested (see orderProjection),
#'   this specifies the representation of the matches. The three options are:
#'   "NO_ROLLUP" (no rollup, return raw fragments), "ROLLUP_BY_PRICE" (rollup
#'   matched amounts by distinct matched prices per side) and
#'   "ROLLED_UP_BY_AVG_PRICE" (rollup matched amounts by average matched price
#'   per side). Optional. Default is NULL.
#'
#' @param virtualise boolean. Indicates if the returned prices should include
#'   virtual prices. This is only applicable to EX_BEST_OFFERS and EX_ALL_OFFERS
#'   priceData selections. Default value is FALSE. Note that prices on website
#'   include virtual bets, so setting this parameter to FALSE may produce
#'   different results to manually checking the website. More information on
#'   virtual bets can be found here:
#'   \url{https://api.developer.betfair.com/services/webapps/docs/display/1smk3cen4v3lu3yomq5qye0ni/Virtual+Bets}
#'
#' @param rolloverStakes boolean. Indicates if the volume returned at each price
#'   point should be the absolute value or a cumulative sum of volumes available
#'   at the price and all better prices. It is only applicable to EX_BEST_OFFERS
#'   and EX_ALL_OFFERS price projections. Optional. Default is FALSE. According
#'   to Betfair online documentation, this paramter is not supported as yet.
#'
#' @param bestPricesDepth integer. The maximum number of prices to return on
#'   each side for each runner. The default value is 3.
#'
#' @param rollupModel string. Determines the model to use when rolling up
#'   available sizes. The viable paramter values are "STAKE" (the volumes will
#'   be rolled up to the minimum value, which is >= rollupLimit); "PAYOUT" (the
#'   volumes will be rolled up to the minimum value, where the payout( price *
#'   volume ) is >= rollupLimit); "MANAGED_LIABILITY" (the volumes will be
#'   rolled up to the minimum value which is >= rollupLimit, until a lay price
#'   threshold. There after, the volumes will be rolled up to the minimum value
#'   such that the liability >= a minimum liability. Not supported as yet);
#'   "NONE" (No rollup will be applied. However the volumes will be filtered by
#'   currency specific minimum stake unless overridden specifically for the
#'   channel). The default value is NULL, which Betfair interprets as "STAKE".
#'
#' @param rollupLimit integer. The volume limit to use when rolling up returned
#'   sizes. The exact definition of the limit depends on the rollupModel.
#'   Ignored if no rollup model is specified. Optional. Default is NULL, which
#'   means it will use minimum stake as the default value.
#'
#' @param suppress Boolean. By default, this parameter is set to FALSE, meaning
#'   that a warning is posted when the listMarketBook call throws an error.
#'   Changing this parameter to TRUE will suppress this warning.
#'
#' @param sslVerify Boolean. This argument defaults to TRUE and is optional. In
#'   some cases, where users have a self signed SSL Certificate, for example
#'   they may be behind a proxy server, Betfair will fail login with "SSL
#'   certificate problem: self signed certificate in certificate chain". If this
#'   error occurs you may set sslVerify to FALSE. This does open a small
#'   security risk of a man-in-the-middle intercepting your login credentials.
#'
#' @return Response from Betfair is stored in listMarketBook variable, which is
#'   then parsed from JSON as a list. Only the first item of this list contains
#'   the required event type identification details. The runners column includes
#'   various lists of price information, which may need to be reformatted (e.g.
#'   converted to data frames) depending on the user's circumstances. If the
#'   listMarketBook call throws an error, a data frame containing error
#'   information is returned.
#'
#' @section Notes on \code{priceData} options: There are three options for this
#'   argument and one of them must be specified. All upper case letters must be
#'   used. \describe{ \item{SP_AVAILABLE}{Amount available for the Betfair
#'   Starting Price (BSP) auction.} \item{SP_TRADED}{Amount traded in the
#'   Betfair Starting Price (BSP) auction. Zero returns if the event has not yet
#'   started.} \item{EX_BEST_OFFERS}{Only the best prices available for each
#'   runner.} \item{EX_ALL_OFFERS}{EX_ALL_OFFERS trumps EX_BEST_OFFERS if both
#'   settings are present} \item{EX_TRADED}{Amount traded in this market on the
#'   Betfair exchange.}}
#'
#' @section Note on \code{listMarketBookOps} variable: The
#'   \code{listMarketBookOps} variable is used to firstly build an R data frame
#'   containing all the data to be passed to Betfair, in order for the function
#'   to execute successfully. The data frame is then converted to JSON and
#'   included in the HTTP POST request.
#'
#' @examples
#' \dontrun{
#' # Return all prices for the requested market. This actual market ID is
#' unlikely to work and is just for demonstration purposes.
#' listMarketBook(marketIds = "1.116700328", priceData = "EX_ALL_OFFERS")
#' }
#'

listMarketBook <- function(marketIds, priceData , orderProjection = NULL,
                           matchProjection = NULL, virtualise = FALSE,
                           rolloverStakes = FALSE, bestPricesDepth = 3,
                           rollupModel = NULL, rollupLimit = NULL,
                           suppress = FALSE, sslVerify = TRUE) {
  options(stringsAsFactors = FALSE)

  listMarketBookOps <-
    data.frame(jsonrpc = "2.0", method = "SportsAPING/v1.0/listMarketBook", id = "1")

  listMarketBookOps$params <-
    data.frame(
      marketIds = c("")
    )
  listMarketBookOps$params$marketIds = list(marketIds)
  listMarketBookOps$params$priceProjection <-
    data.frame(
      virtualise = virtualise, rolloverStakes = rolloverStakes
    )
  if (!is.null(priceData)) {
    listMarketBookOps$params$priceProjection$priceData <-
      list(priceData)
  }

  listMarketBookOps$params$priceProjection$exBestOfferOverRides <-
    data.frame(
      bestPricesDepth = bestPricesDepth
    )
  if (!is.null(rollupModel)) {
    listMarketBookOps$params$priceProjection$exBestOfferOverRides$rollupModel <- rollupModel
  }
  if (!is.null(orderProjection)) {
    listMarketBookOps$params$OrderProjection <- list(orderProjection)
  }
  if (!is.null(matchProjection)) {
    listMarketBookOps$params$MatchProjection <- list(matchProjection)
  }
  listMarketBookOps <-
    listMarketBookOps[c("jsonrpc", "method", "params", "id")]

  listMarketBookOps <-
    jsonlite::toJSON(listMarketBookOps, pretty = TRUE)

  # Read Environment variables for authorisation details
  product <- Sys.getenv('product')
  token <- Sys.getenv('token')

  headers <- list(
    'Accept' = 'application/json', 'X-Application' = product, 'X-Authentication' = token, 'Content-Type' = 'application/json',
      'Expect' = ''
  )

  listMarketBook <-
    as.list(jsonlite::fromJSON(
      RCurl::postForm(
        "https://api.betfair.com/exchange/betting/json-rpc/v1", .opts = list(
          postfields = listMarketBookOps, httpheader = headers, ssl.verifypeer = sslVerify
        )
      )
    ))

  if(is.null(listMarketBook$error))
    as.data.frame(listMarketBook$result)
  else({
    if(!suppress)
      warning("Error- See output for details")
    as.data.frame(listMarketBook$error)})
}
