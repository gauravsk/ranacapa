if(getRversion() >= "2.15.1")  utils::globalVariables(c("sum.taxonomy", ".", "id", "taxonomy"))

#' Rarefy a phyloseq object to a custom sample depth and with given number of repliactes
#' @param physeq_object A phyloseq class object to be rarefied
#' @param sample_size Desired depth of rarefaction
#' @param replicates Desired number of times to resample from community
#' @param ... Other options for phyloseq function rarefy_even_depth
#' @return phyloseq class object
#' @examples
#' good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
#'  site_1 = c(0,1), site_2 = c(10, 20))
#' good_maps <- data.frame(site = c("site_1", "site_2"),
#'  season = c("wet", "dry"), host = c("oak", "sage"))
#' physeq_object <- convert_anacapa_to_phyloseq(good_taxon_table, good_maps)
#' custom_rarefaction(physeq_object, sample_size = 10, replicates = 1)
#' @export

custom_rarefaction <- function(physeq_object, sample_size = 10000, replicates = 10, ...) {

  reps  <- replicate(replicates,
                     phyloseq::rarefy_even_depth(physeq_object,
                                                 sample.size = sample_size))

  dfs <- lapply(reps, function(x) as.data.frame(x@otu_table@.Data))

  dfs <- lapply(dfs, function(x) tibble::rownames_to_column(x, var = "taxonomy"))
  dfs <- do.call(rbind.data.frame, dfs)

  # Calculate the average number of reads per replicate
  otu <- dfs %>% dplyr::group_by(taxonomy) %>%
    dplyr::summarize_all(dplyr::funs(sum(.) / replicates)) %>%
    dplyr::mutate_if(is.numeric, dplyr::funs(round)) %>%
    data.frame %>%
    tibble::column_to_rownames("taxonomy") %>%
    as.matrix

  OTU <- phyloseq::otu_table(otu, taxa_are_rows = T)

  TAX <- physeq_object@tax_table
  physeq_to_return <- phyloseq::phyloseq(OTU, TAX)
  physeq_to_return <- phyloseq::merge_phyloseq(physeq_to_return, physeq_object@sam_data)

  return(physeq_to_return)
}
