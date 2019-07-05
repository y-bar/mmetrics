allowed_operators <- list(
  quote(`+`),
  quote(`%*%`),
  quote(`%%`),
  quote(`-`),
  quote(`/`),
  quote(`*`)
)

disaggregate_ <- function(x) {
  env <- rlang::quo_get_env(x)
  x <- rlang::quo_squash(x)
  rlang::new_quosure(disaggregate_expr(x), env = env)
}

disaggregate_expr <- function(x) {
  if (length(x) == 1) {return(x)}

  call_name <- x[[1]]
  call_args <- x[-1]

  if (!any(purrr::map_lgl(allowed_operators, ~ identical(.x, call_name)))) {
    # Remove function, only first level aggregate function is removed
    x[[1]] <- NULL
    return(x[[1]])
  }

  x[-1] <- purrr::map(call_args, ~ disaggregate_expr(.x))
  x
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
    purrr::map(metrics, disaggregate_)
  } else if(rlang::is_quosure(metrics)){
    disaggregate_(metrics)
  } else{
    stop("metrics must be quosure or quores")
  }
}
