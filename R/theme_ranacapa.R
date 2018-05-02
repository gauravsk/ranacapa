#' Default theme for plots
#' @export
theme_ranacapa <- function() {
  ggplot2::theme_bw() +
    ggplot2::theme(panel.grid.minor.y = ggplot2::element_blank(),
                   panel.grid.minor.x = ggplot2::element_blank(),
                   panel.grid.major.y = ggplot2::element_blank(),
                   panel.grid.major.x = ggplot2::element_blank())
}
