not_allowed_operators <- lapply(getGroupMembers("Summary"), as.symbol)

disaggregate_ <- function(x, is_top) {
  if(is_top){x <- rlang::quo_squash(x)}
  if(length(x) == 1){return(x)}

  call_name <- x[[1]]
  call_args <- x[-1]

  if (any(purrr::map_lgl(not_allowed_operators, ~ identical(.x, call_name)))){
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

disaggregate__ <- function(x){
  result <- disaggregate_(x, TRUE)
  rlang::quo_set_expr(result, rlang::quo_squash(result))
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
    purrr::map(metrics, disaggregate__)
  } else if(rlang::is_quosure(metrics)){
    disaggregate__(metrics)
  } else{
    stop("metrics must be quosure or quores")
  }
}
