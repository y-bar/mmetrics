#' @include disaggregate.R
NULL

# To use these operators inside this package, we have to do like this
`%>%` <- magrittr::`%>%`
`!!!` <- rlang::`!!!`
`!!` <- rlang::`!!`

#' Define metrics
#'
#' This helper is just synonym of [rlang::quos] intended to provide seamless experience for package user.
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
define <- function(...) rlang::quos(...)

#' Aggregate metrics
#'
#' `add()` is wrapper function of `gmutate()` and `gsummarize()`.
#' `gmutate()` adds aggregated metrics as variables to the given data frame.
#' `gsummarize()` aggregates metrics from the given data frame.
#' `gsummarize()` and `gsummarise()` are synonyms.
#'
#' @param df Data frame.
#' @param ... Variables to group by.
#' @param metrics Metrics defined by [mmetrics::define()].
#' @param summarize Summarization flag. If it is `TRUE`, `add()` works as `gsummarize()`.
#'   Otherwise, `add()` works as `gmutate()`.
#'
#' @return Data frame with calculated metrics
#'
#' @examples
#' # Prepare data frame
#' df <- data.frame(
#'   gender = rep(c("M", "F"), 5),
#'   age = (1:10)*10,
#'   cost = (51:60),
#'   impression = (101:110),
#'   click = (0:9)*3
#' )
#'
#' # Define metrics
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

  if (summarize) {
    gsummarize(df, !!!group_vars, metrics = metrics)
  } else {
    gmutate(df, !!!group_vars, metrics = metrics)
  }
}

#' @rdname add
#' @export
gsummarize <- function(df, ..., metrics) gprocess(dplyr::summarise, df, ..., metrics = metrics)

#' @rdname add
#' @export
gsummarise <- gsummarize

#' @rdname add
#' @export
gmutate <- function(df, ..., metrics) gprocess(dplyr::mutate, df, ..., metrics = metrics)

#' Pick evaluable metrics in the given data frame
#'
#' @param df Data frame
#' @param metrics Metrics
#'
#' @return Evaluable metrics
#'
#' @export
mfilter <- function(df, metrics) {
  is_evaluatable <- function(metrics, df) {
    # Adhoc code
    out <- tryCatch(dplyr::mutate(df[1, ], !!rlang::quo_squash(metrics)), error = function(e) e, silent = TRUE)
    !(any(class(out) == "error"))
  }
  is_effective <- unlist(purrr::map(metrics, ~ is_evaluatable(.x, df)))
  metrics[is_effective]
}

# Internal function for data process with group
gprocess <- function(fun, df, ..., metrics) {
  group_vars <- rlang::enquos(...)
  metrics <- mfilter(df, metrics)
  df %>%
    dplyr::group_by(!!!group_vars) %>%
    fun(!!!metrics) %>%
    dplyr::ungroup()
}
