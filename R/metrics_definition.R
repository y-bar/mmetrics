#' @include mmetrics.R

# Advertisng world metrics
ad_metrics <- define(
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
