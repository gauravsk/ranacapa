#' Takes a site-abundance table from Anacapa, and summarizes to each unique taxon in the sum.taxonomy column
#' @param ana_out OTU table from Anacapa
#' @author Gaurav Kandlikar
group_anacapa_by_taxonomy <- function(ana_out) {
  ana_out %>% filter(sum.taxonomy != "") %>% group_by(sum.taxonomy) %>%
    summarize_if(is.numeric,sum) %>% data.frame
}

#' Takes an site-abundance table from Anacapa, along with a qiime-style mapping file, and returns a phyloseq object
#' @param ana_out OTU table from Anacapa
#' @param mapping_file Qiime-style mapping
#' @return phyloseq class object
#' @author Gaurav Kandlikar


convert_anacapa_to_phyloseq <- function(ana_out, mapping_file) {

  ana_out2 <- group_anacapa_by_taxonomy(ana_out) %>%
    column_to_rownames("sum.taxonomy") %>% as.matrix
  ana_out2 <- ana_out2[ , order(colnames(ana_out2))]

  ana_out_physeq <- otu_table(ana_out2, taxa_are_rows = TRUE)

  taxon_names <- colsplit(rownames(ana_out2), ";",
                          names = c("Phylum","Class","Order","Family","Genus","Species")) %>% as.matrix
  rownames(taxon_names) <- rownames(ana_out2)

  tax_physeq <- tax_table(taxon_names)
  colnames(tax_physeq) <- c("Phylum","Class","Order","Family","Genus","Species")

  physeq <- phyloseq(ana_out_physeq, tax_physeq)

  rownames(mapping_file) <- mapping_file[,1]
  mapping_file <- mapping_file[order(mapping_file[,1]),]

  sampledata <- sample_data(mapping_file)
  merge_phyloseq(physeq, sampledata)
}

vegan_otu <- function(physeq) {
  OTU <- otu_table(physeq)
  if (taxa_are_rows(OTU)) {
    OTU <- t(OTU)
  }
  return(as(OTU, "matrix"))
}
