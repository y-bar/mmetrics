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

  if(length(group_vars) == 0 && !summarize){
    warning("disaggregate() called inside. See the result of disaggregate(metrics) to check wether output metrics is what you want.")
    dplyr::mutate(df, !!!disaggregate(metrics))
  } else{
    df %>%
      dplyr::group_by(!!!group_vars) %>%
      dplyr::summarise(!!!metrics) %>%
      dplyr::ungroup()
  }
}

allowed_operators <- list(
  quote(`+`),
  quote(`%*%`),
  quote(`%%`),
  quote(`-`),
  quote(`/`),
  quote(`*`)
)

disaggregate_ <- function(x, is_top) {
  if(is_top){x <- rlang::quo_squash(x)}
  if(length(x) == 1){return(x)}

  call_name <- x[[1]]
  call_args <- x[-1]

  if (!any(purrr::map_lgl(allowed_operators, ~ identical(.x, call_name)))){
    # Remove function, only first level aggregate function is removed
    x[[1]] <- NULL
    if(is_top){
      return(rlang::quo(!!x[[1]]))
    } else{
      return(x[[1]])
    }
  }

  x[-1] <- purrr::map(call_args, ~ disaggregate_(.x, FALSE))
  rlang::quo(!!x)
}

#' Disaggregate metrics defined as aggregate function
#'
#' Disaggregate metrics defined as aggregate function
#'
#' @param metrics metrics defined by mmetrics::define()
#' @return disaggregated metrics (rlang::quosure or rlang::quosures)
#'
#' @examples
#'
#' metrics <- mmetrics::define(
#'   cost = sum(cost),
#'   ctr  = sum(click)/sum(impression)
#' )
#'
#' mmetrics::disaggregate(metrics)
#'
#' @export
disaggregate <- function(metrics){
  if(rlang::is_quosures(metrics)){
    purrr::map(metrics, ~ disaggregate_(.x, TRUE))
  } else if(rlang::is_quosure(metrics)){
    disaggregate_(metrics, TRUE)
  } else{
    stop("metrics must be quosure or quores")
  }
}

