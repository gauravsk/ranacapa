#' Takes a biom table imported in using phyloseq::import_biom() and converts it
#' into an Anacapa-formmated taxonomy table
#' @param physeq_object phyloseq object with a OTU table and a Taxon Table embedded
#' @author Gaurav Kandlikar
#' @export
convert_biom_to_taxon_table <- function(physeq_object) {

  # Make data frames out of these objects
  community_table <- physeq_object@otu_table %>% as.data.frame() %>%
    tibble::rownames_to_column("id")
  taxon_table <- physeq_object@tax_table %>% as.data.frame()

  # Summarize the taxonomy and clean it up by removing some junk
  taxon_table$sum.taxonomy <- paste(taxon_table$Rank2,taxon_table$Rank3,
                                taxon_table$Rank4,taxon_table$Rank5,
                                taxon_table$Rank6,taxon_table$Rank7, sep = ";")
  taxon_table <- taxon_table %>% tibble::rownames_to_column("id") %>%
    select(id, sum.taxonomy)

  taxon_table$sum.taxonomy <- stringr::str_replace_all(taxon_table$sum.taxonomy, pattern = "(p|c|o|f|g|s)__", "")

  # Merge the taxonomy and the community matrix back together
  left_join(community_table, taxon_table) %>% select(-id) %>%
    select(sum.taxonomy, everything())
}
