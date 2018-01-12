#' Converts the OTU table in a phyloseq object into a Vegan-style community matrix
#'
#' @param physeq `phyloseq` class object
#' @return Vegan-style community matrix (species in columns; sites in rows)
#' @author Gaurav Kandlikar

physeq_to_vegan <- function(physeq) {
  OTU <- otu_table(physeq)
  if (taxa_are_rows(OTU)) {
    OTU <- t(OTU)
  }
  return(as(OTU, "matrix"))
}
