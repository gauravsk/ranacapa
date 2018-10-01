if(getRversion() >= "2.15.1")  utils::globalVariables(c("sum.taxonomy", "."))


#' Takes a site-abundance table from Anacapa, and summarizes to each unique taxon in the sum.taxonomy column
#' @param taxon_table OTU table from Anacapa
#' @author Gaurav Kandlikar
#' @export
group_anacapa_by_taxonomy <- function(taxon_table) {
  taxon_table %>%
    dplyr::filter(sum.taxonomy != "") %>%
    dplyr::group_by(sum.taxonomy) %>%
    dplyr::summarize_if(is.numeric, sum) %>%
    dplyr::mutate(sum.taxonomy = as.character(sum.taxonomy)) %>%
    data.frame
}


#' Takes a continuous vector and categorizes the vector into low, medium, and high
#' @param vec a continuous vector to categorize
#' @return a continuous vector
#' @author Gaurav Kandlikar

categorize_continuous_vector <- function(vec) {
  if (is.numeric(vec)) {
    vec <- na.omit(vec)
    if (length(unique(vec)) > 2) {
      cut(vec, breaks = c(0, stats::quantile(vec, probs = seq(from = 1/3, to = 1, by = 1/3))),
          labels = c("low", "medium", "high"), include.lowest = TRUE)
    } else if (length(unique(vec)) == 2) {
      vec[vec == min(vec)] = "low"
      vec[vec != "low"] = "high"
      as.factor(vec)
    } else if (length(unique(vec)) == 1) {
      as.character(vec)
    }
  } else {
    vec
  }
}

#' Takes a metadata file, and categorizes any continuous variable into "low, med, high"
#' @param metadata_file a well-formatted metadata file
#' @param cols_to_convert a vector, containing the names of the column that should be categorized
#' @return a metadata file with categorical column in place of the continuous one
#' @author Gaurav Kandlikar

categorize_continuous_metadata <- function(metadata_file, cols_to_convert = NULL){
  if(is.null(cols_to_convert)) {
    metadata_file
  } else {
    metadata_file %>% dplyr::mutate_at(cols_to_convert, categorize_continuous_vector)
  }
}
#' Takes an site-abundance table from Anacapa, along with a qiime-style mapping file, and returns a phyloseq object
#' @param taxon_table Taxon table in the anacapa format
#' @param metadata_file Metadata file with rows as sites, columns as variables
#' @param cols_to_categorize a vector containing the names of any columns in metadata_file that should be categorized into "high, medium, low"
#' @return phyloseq class object
#' @author Gaurav Kandlikar
#' @export

convert_anacapa_to_phyloseq <- function(taxon_table, metadata_file, cols_to_categorize = NULL) {

  # Validate the files
  validate_input_files(taxon_table, metadata_file)

  # Convert any continuous metadata variables to categorical
  metadata_file <- categorize_continuous_metadata(metadata_file, cols_to_categorize)

  # Group the anacapa ouptut by taxonomy, if it has not yet happened, and turn it into a matrix
  taxon_table2 <- group_anacapa_by_taxonomy(taxon_table) %>%
    tibble::column_to_rownames("sum.taxonomy") %>%
    as.matrix
  # Reorder the columns (sites) for ease of displaying later
  taxon_table2 <- taxon_table2[ , order(colnames(taxon_table2))]

  # Convert the matrix into a phyloseq otu_table object, with taxa as the rows
  ana_taxon_table_physeq <- phyloseq::otu_table(taxon_table2, taxa_are_rows = TRUE)

  # Extract the rownames of the matrix above- this has the full taxonomic path.
  # Split the taxonomic path on semicolons, and turn the resulting matrix into
  # a phyloseq tax_table object
  taxon_names <- reshape2::colsplit(rownames(taxon_table2), ";",
                          names = c("Phylum","Class","Order","Family","Genus","Species")) %>%
    as.matrix
  rownames(taxon_names) <- rownames(taxon_table2)

  tax_physeq <- phyloseq::tax_table(taxon_names)
  colnames(tax_physeq) <- c("Phylum","Class","Order","Family","Genus","Species")

  # Make a phyloseq object out of the otu_table and the tax_table objects
  physeq_object <- phyloseq::phyloseq(ana_taxon_table_physeq, tax_physeq)

  # Make sure the mapping file (ie the site metadata) is ordered according to site name
  rownames(metadata_file) <- metadata_file[, 1]
  metadata_file <- metadata_file[order(metadata_file[, 1]), ]

  # Convert the mapping file into a phyloseq sample_data object, and merge it with the
  # phyloseq object created above to make a phyloseq object with otu table, tax table, and sample data.
  sampledata <- phyloseq::sample_data(metadata_file)
  phyloseq::merge_phyloseq(physeq_object, sampledata)
}

#' Takes a phyloseq object with an otu_table object and returns a vegan style community matrix.
#' @param physeq_object phyloseq object with an otu_table object within
#' @return vegan-style community matrix
#' @author Gaurav Kandlikar
#' @export
vegan_otu <- function(physeq_object) {
  OTU <- phyloseq::otu_table(physeq_object)
  if (phyloseq::taxa_are_rows(OTU)) {
    OTU <- t(OTU)
  }
  return(methods::as(OTU, "matrix"))
}
