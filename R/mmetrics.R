`%>%` <- magrittr::`%>%`
`!!!` <- rlang::`!!!`
`!!` <- rlang::`!!`

# Advertisng world metrics
ad_metrics <- rlang::quos(
  cost = sum(cost),
  impression = sum(impression),
  click = sum(click),
  conversion = sum(conversion),
  ctr  = sum(click)/sum(impression),
  cvr  = sum(conversion)/sum(click),
  ctvr = sum(conversion)/sum(impression),
  cpa  = sum(cost)/sum(conversion),
  cpc  = sum(cost)/sum(click),
  ecpm = sum(cost)/sum(impression) * 1000
)

#' Add metrics to data.frame
#'
#' Add metrics to data.frame
#'
#' @param df data.frame
#' @param ... group keys
#' @param metrics metrics
#' @param summarize summarize all data or not (mutate compatible behavior) when group keys(thee dots) are empty
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
#' metrics <- rlang::quos(
#'   cost = sum(cost),
#'   ctr  = sum(click)/sum(impression)
#' )
#'
#' # Evaluate
#' mmetrics::add(df, gender, metrics = metrics)
#'
#' @export
add <- function(df, ..., metrics = ad_metrics, summarize = FALSE){
  group_vars <- rlang::enquos(...)
  if(length(group_vars) == 0 && !summarize){
    variable_names <- unique(purrr::reduce(purrr::map(ad_metrics, extract_variable_name), c))
    colnames <- names(df)
    keys <- colnames[!(colnames %in% variable_names)]
    group_vars <- rlang::syms(keys)
  }
  df %>%
    dplyr::group_by(!!!group_vars) %>%
    dplyr::summarise(!!!metrics) %>%
    dplyr::ungroup()
}

extract_variable_name <- function(quosure)
{
  stringr::str_extract_all(rlang::quo_text(quosure), "\\w+")[[1]]
}

