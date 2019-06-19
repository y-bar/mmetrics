`%>%` <- magrittr::`%>%`
`!!!` <- rlang::`!!!`
`!!` <- rlang::`!!`

ad_metrics <- dplyr::vars(
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
#' @param ... dots
#' @param metrics metrics
#'
#' @export
add_metrics <- function(df, ..., metrics = ad_metrics){
  group_vars <- rlang::enquos(...)
  df %>%
    dplyr::group_by(!!!group_vars) %>%
    dplyr::summarise(!!!metrics)
}
