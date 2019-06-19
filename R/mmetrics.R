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
    dplyr::summarise(!!!metrics)
}

extract_variable_name <- function(quosure)
{
  stringr::str_extract_all(rlang::quo_text(quosure), "\\w+")[[1]]
}

