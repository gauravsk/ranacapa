#' Rarefy a phyloseq object to a custom sample depth and with given number of repliactes
#' @param physeq A phyloseq class object to be rarefied
#' @param sample_size Desired depth of rarefaction
#' @param replicates Desired number of times to resample from community
#' @return phyloseq class object
#' @author Gaurav Kandlikar

custom_rarefaction <- function(physeq, sample_size = 100000, replicates = 10, ...) {
  reps  <- replicate(replicates, rarefy_even_depth(physeq, sample.size = sample_size))

  dfs <- lapply(reps, function(x) as.data.frame(x@otu_table@.Data))

  dfs <- lapply(dfs, function(x) rownames_to_column(x, var = "taxonomy"))
  dfs <- do.call(rbind.data.frame, dfs)

  otu <- dfs %>% group_by(taxonomy) %>% summarize_all(funs(mean)) %>%
    mutate_if(is.numeric, funs(round)) %>% data.frame %>%
    column_to_rownames("taxonomy") %>% as.matrix

  OTU <- otu_table(otu, taxa_are_rows = T)

  TAX <- physeq@tax_table
  physeq_to_return <- phyloseq(OTU, TAX)
  physeq_to_return <- merge_phyloseq(physeq_to_return, physeq@sam_data)

  return(physeq_to_return)
}
