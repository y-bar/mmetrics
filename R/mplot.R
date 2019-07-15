#' Plot bar charts
#'
#' Plot bar charts.
#'
#' @param df data.frame
#' @param y y axis
#' @param x x axis
#'
#' @return ggplot object
#'
#' @examples
#' \dontrun{
#' df <- mmetrics::dummy_data
#' # Add metrics and plot directly
#' mmetrics::mplot_bar(mmetrics::add(df, gender), ctr, gender)
#' # You can remove x parameter. in this case first column is assumed as x parameter
#' mmetrics::mplot_bar(mmetrics::add(df, gender), ctr)
#'}
#' @export
mplot_bar <- function(df, y, x = NULL){
  x <- rlang::enquo(x)
  y <- rlang::enquo(y)

  if(rlang::quo_is_null(x)){
    # x must be first colunm!
    x <- rlang::sym(names(df)[1])
  }

  ggplot2::ggplot(df, ggplot2::aes(x = !!x, y = !!y, color = !!x, fill = !!x)) +
    ggplot2::geom_bar(stat = "identity")
}
