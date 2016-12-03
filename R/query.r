#' Submit a query and return results
#'
#' @param query query to run
#' @param uplift automatically run `drill_uplift()` on the result?
#' @param drill_server base URL of the \code{drill} server
#' @export
drill_query <- function(query, uplift=FALSE, drill_server=Sys.getenv("DRILL_URL", unset="http://localhost:8047")) {

  res <- httr::POST(sprintf("%s/query.json", drill_server),
                    encode="json",
                    body=list(queryType="SQL",
                              query=query))

  out <- jsonlite::fromJSON(httr::content(res, as="text", encoding="UTF-8"), flatten=TRUE)

  if ("errorMessage" %in% names(out)) {
    message(sprintf("Query ==> %s\n%s\n", gsub("[\r\n]", " ", query), out$errorMessage))
    invisible(out)
  } else {
    if (uplift) out <- drill_uplift(out)
    out
  }

}

#' Turn a columnar query results into a type-converted tbl
#'
#' If you know the result of `drill_query()` will be a data frame, then
#' you can pipe it to this function to pull out `rows` and automatically
#' type-convert it.
#'
#' @param query_result the result of a call to `drill_query()`
#' @export
drill_uplift <- function(query_result) {
  dplyr::tbl_df(readr::type_convert(query_result$rows))
}