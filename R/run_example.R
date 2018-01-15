#' @export
runExample <- function() {
  appDir <- system.file("shiny-examples", "explore-anacapa-output", package = "ranacapa")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `ranacapa`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}

