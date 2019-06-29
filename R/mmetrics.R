#' @include disaggregate.R
NULL

# To use these operators inside this package, we have to do like this
`%>%` <- magrittr::`%>%`
`!!!` <- rlang::`!!!`
`!!` <- rlang::`!!`

#' Define metrics
#'
#' This helper is just synonum for [rlang::quos] intended to provide seamless experience for package user.
#'
#' @param ... Metrics definition.
#'
#'   These arguments are automatically [quoted][rlang::quo]
#'   and [evaluated][rlang::eval_tidy] in the context of the data frame.
#'
#' @seealso
#'   [quos][rlang::quos], [dplyr's vignettes](https://cran.r-project.org/package=dplyr/vignettes/programming.html)
#'
#' @export
define <- function(...){
  rlang::quos(...)
}

#' Add metrics to data.frame
#'
#' Add metrics to data.frame
#'
#' @param df data.frame
#' @param ... group keys
#' @param metrics metrics defined by mmetrics::define()
#' @param summarize summarize all data or not (mutate compatible behavior) when group keys (thee dots) are empty.
#'
#' @return data.frame with calculated metrics
#'
#' @examples
#' # Dummy data
#' df <- data.frame(
#'   gender = rep(c("M", "F"), 5),
#'   age = (1:10)*10,
#'   cost = c(51:60),
#'   impression = c(101:110),
#'   click = c(0:9)*3
#' )
#'
# Example metrics
#' metrics <- mmetrics::define(
#'   cost = sum(cost),
#'   ctr  = sum(click)/sum(impression)
#' )
#'
#' # Evaluate
#' mmetrics::add(df, gender, metrics = metrics)
#'
#' @export
add <- function(df, ..., metrics = ad_metrics, summarize = TRUE){
  group_vars <- rlang::enquos(...)

  if(summarize){
    tryCatch({
      gsummarize(df, !!!group_vars, metrics = metrics)
    }, error = function(e) {
      warning("
        disaggregate() called inside.
        See the result of disaggregate(metrics) to check whether output metrics is what you want.
      ")
      gmutate(df, !!!disaggregate(metrics))
    })
  } else{
    gmutate(df, metrics = metrics)
  }
}

gsummarize <- function(df, ..., metrics){
  group_vars <- rlang::enquos(...)
  df %>%
    dplyr::group_by(!!!group_vars) %>%
    dplyr::summarise(!!!metrics) %>%
    dplyr::ungroup()
}
gsummarise <- gsummarize

gmutate <- function(df, ..., metrics){
  group_vars <- rlang::enquos(...)
  df %>%
    dplyr::group_by(!!!group_vars) %>%
    dplyr::mutate(!!!metrics) %>%
    dplyr::ungroup()
}
