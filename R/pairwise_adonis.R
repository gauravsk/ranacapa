#' Pairwise multilevel comparison using adonis
#'
#'@description This is a wrapper function for multilevel pairwise comparison
#' using adonis() from package 'vegan'. The function returns adjusted p-values using p.adjust().
#'
#'@param x Data frame (the community table).
#'@param factors Vector (a column or vector with the levels to be compared pairwise).
#'@param sim_method Similarity method from vegdist, default is 'bray'
#'@param p_adjust_m The p.value correction method, one of the methods supported by p.adjust(),
#' default is 'bonferroni'.
#'@param reduce String. Restrict comparison to pairs including these factors. If more than one factor, separate by pipes like:  reduce = 'setosa|versicolor'
#'@return Table with the pairwise factors, F-values, R^2, p.value and adjusted p.value.
#'@author Pedro Martinez Arbizu
#'@examples
#' data(iris)
#' pairwise_adonis(iris[, 1:4], iris$Species)
#'
#' pairwise_adonis(iris[, 1:4], iris$Species, reduce = 'setosa')
#'
#'# similarity euclidean from vegdist and holm correction
#' pairwise_adonis(x = iris[, 1:4], factors = iris$Species,
#' sim_method = 'euclidian', p_adjust_m = 'holm')
#'
#'#similarity manhattan from daisy and bonferroni correction
#' pairwise_adonis(x = iris[, 1:4], factors = iris$Species,
#' sim_method = 'manhattan', p_adjust_m = 'bonferroni')
#'@export pairwise_adonis
#'@importFrom stats p.adjust
#'@importFrom utils combn
#'@importFrom vegan adonis vegdist



pairwise_adonis <- function(x, factors, sim_method = "bray",
                            p_adjust_m = "bonferroni", reduce = NULL) {

  co <- utils::combn(unique(as.character(factors)), 2)
  pairs <- c()
  F.Model <- c()
  R2 <- c()
  p.value <- c()


  for (elem in 1:ncol(co)) {
    x1 <- vegan::vegdist(x[factors %in% c(co[1, elem], co[2, elem]), ],
                  method = sim_method)

    ad <- vegan::adonis(x1 ~ factors[factors %in% c(co[1, elem], co[2, elem])])
    pairs <- c(pairs, paste(co[1, elem], "vs", co[2, elem]))
    F.Model <- c(F.Model, ad$aov.tab[1, 4])
    R2 <- c(R2, ad$aov.tab[1, 5])
    p.value <- c(p.value, ad$aov.tab[1, 6])
  }
  p.adjusted <- stats::p.adjust(p.value, method = p_adjust_m)

  sig <- c(rep("", length(p.adjusted)))
  sig[p.adjusted <= 0.05] <- "."
  sig[p.adjusted <= 0.01] <- "*"
  sig[p.adjusted <= 0.001] <- "**"
  sig[p.adjusted <= 1e-04] <- "***"
  pairw.res <- data.frame(pairs, F.Model, R2, p.value, p.adjusted, sig)

  if (!is.null(reduce)) {
    pairw.res <- subset(pairw.res, grepl(reduce, pairs))
    pairw.res$p.adjusted <- stats::p.adjust(pairw.res$p.value, method = p_adjust_m)

    sig <- c(rep("", length(pairw.res$p.adjusted)))
    sig[pairw.res$p.adjusted <= 0.05] <- "."
    sig[pairw.res$p.adjusted <= 0.01] <- "*"
    sig[pairw.res$p.adjusted <= 0.001] <- "**"
    sig[pairw.res$p.adjusted <= 1e-04] <- "***"
    pairw.res <- data.frame(pairw.res[, 1:5], sig)
  }
  class(pairw.res) <- c("pwadonis", "data.frame")
  return(pairw.res)
}
