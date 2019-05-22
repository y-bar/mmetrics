default_metrics <- dplyr::vars(
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

#' @export
add_metrics <- function(df, ..., metrics = default_metrics){
  group_vars <- rlang::enquos(...)
  df %>%
    group_by(!!!group_vars) %>%
    summarise(!!!metrics)
}
