if(getRversion() >= "2.15.1")  utils::globalVariables(c("sum.taxonomy", ".", "id", "taxonomy"))

#' Rarefy a phyloseq object to a custom sample depth and with given number of repliactes
#' @param physeq A phyloseq class object to be rarefied
#' @param sample_size Desired depth of rarefaction
#' @param replicates Desired number of times to resample from community
#' @param ... Other options for phyloseq function rarefy_even_depth
#' @return phyloseq class object
#' @author Gaurav Kandlikar
#' @export

custom_rarefaction <- function(physeq, sample_size = 10000, replicates = 10, ...) {

  reps  <- replicate(replicates, phyloseq::rarefy_even_depth(physeq, sample.size = sample_size))

  dfs <- lapply(reps, function(x) as.data.frame(x@otu_table@.Data))

  dfs <- lapply(dfs, function(x) tibble::rownames_to_column(x, var = "taxonomy"))
  dfs <- do.call(rbind.data.frame, dfs)

  otu <- dfs %>% dplyr::group_by(taxonomy) %>% dplyr::summarize_all(dplyr::funs(sum(.)/replicates)) %>%
    dplyr::mutate_if(is.numeric, dplyr::funs(round)) %>%
    data.frame %>%
    tibble::column_to_rownames("taxonomy") %>% as.matrix

  OTU <- phyloseq::otu_table(otu, taxa_are_rows = T)

  TAX <- physeq@tax_table
  physeq_to_return <- phyloseq::phyloseq(OTU, TAX)
  physeq_to_return <- phyloseq::merge_phyloseq(physeq_to_return, physeq@sam_data)

  return(physeq_to_return)
}
