#' Default theme for plots
theme_ranacapa <- function() {
  theme_bw() + theme(panel.grid.minor.y=element_blank(),panel.grid.minor.x=element_blank(),
        panel.grid.major.y=element_blank(),panel.grid.major.x=element_blank())
}
