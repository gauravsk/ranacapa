#' Takes a site-abundance table from Anacapa, and summarizes to each unique taxon in the sum.taxonomy column
#' @param ana_out OTU table from Anacapa
#' @author Gaurav Kandlikar
group_anacapa_by_taxonomy <- function(ana_out) {
  ana_out %>% dplyr::filter(sum.taxonomy != "") %>% group_by(sum.taxonomy) %>%
    summarize_if(is.numeric,sum) %>% data.frame
}

#' Takes an site-abundance table from Anacapa, along with a qiime-style mapping file, and returns a phyloseq object
#' @param ana_out OTU table from Anacapa
#' @param mapping_file Qiime-style mapping
#' @return phyloseq class object
#' @author Gaurav Kandlikar


convert_anacapa_to_phyloseq <- function(ana_out, mapping_file) {

  # Group the anacapa ouptut by taxonomy, if it has not yet happened, and turn it into a matrix
  ana_out2 <- group_anacapa_by_taxonomy(ana_out) %>%
    column_to_rownames("sum.taxonomy") %>% as.matrix
  # Reorder the columns (sites) for ease of displaying later
  ana_out2 <- ana_out2[ , order(colnames(ana_out2))]

  # Convert the matrix into a phyloseq otu_table object, with taxa as the rows
  ana_out_physeq <- otu_table(ana_out2, taxa_are_rows = TRUE)

  # Extract the rownames of the matrix above- this has the full taxonomic path.
  # Split the taxonomic path on semicolons, and turn the resulting matrix into
  # a phyloseq tax_table object
  taxon_names <- colsplit(rownames(ana_out2), ";",
                          names = c("Phylum","Class","Order","Family","Genus","Species")) %>% as.matrix
  rownames(taxon_names) <- rownames(ana_out2)

  tax_physeq <- tax_table(taxon_names)
  colnames(tax_physeq) <- c("Phylum","Class","Order","Family","Genus","Species")

  # Make a phyloseq object out of the otu_table and the tax_table objects
  physeq <- phyloseq(ana_out_physeq, tax_physeq)

  # Make sure the mapping file (ie the site metadata) is ordered according to site name
  rownames(mapping_file) <- mapping_file[,1]
  mapping_file <- mapping_file[order(mapping_file[,1]),]

  # Convert the mapping file into a phyloseq sample_data object, and merge it with the
  # phyloseq object created above to make a phyloseq object with otu table, tax table, and sample data.
  sampledata <- sample_data(mapping_file)
  merge_phyloseq(physeq, sampledata)
}

#' Takes a phyloseq object with an otu_table object and returns a vegan style community matrix.
#' @param physeq_object phyloseq object with an otu_table object within
#' @return vegan-style community matrix
#' @author Gaurav Kandlikar
vegan_otu <- function(physeq_object) {
  OTU <- otu_table(physeq_object)
  if (taxa_are_rows(OTU)) {
    OTU <- t(OTU)
  }
  return(as(OTU, "matrix"))
}
