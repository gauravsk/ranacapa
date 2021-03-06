% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/anacapa_utils.R
\name{vegan_otu}
\alias{vegan_otu}
\title{Takes a phyloseq object with an otu_table object and returns a vegan style community matrix.}
\usage{
vegan_otu(physeq_object)
}
\arguments{
\item{physeq_object}{phyloseq object with an otu_table object within}
}
\value{
vegan-style community matrix
}
\description{
Takes a phyloseq object with an otu_table object and returns a vegan style community matrix.
}
\examples{
good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
site_1 = c(0,1), site_2 = c(10, 20))
good_maps <- data.frame(site = c("site_1", "site_2"), season = c("wet", "dry"),
host = c("oak", "sage"))
physeq_object <- convert_anacapa_to_phyloseq(good_taxon_table, good_maps)
vegan_otu(physeq_object)
}
