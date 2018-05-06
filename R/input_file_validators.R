#' Remove "xxx_seq_number" column from ana_taxon_table file if it exists
#' takes one biom table as its input, and if it include
#' a column named "xxx_seq_number", it gets rid of that column - it's not of use to us
#' any longer
#'
#' @param taxon_table OTU table from Anacapa
#' @author Gaurav Kandlikar
#' @return ana_taxon_table file, with "xxx_seq_number" column removed (if it existed)
#' @export
scrub_seqNum_column <- function(taxon_table) {
  to_return <- taxon_table %>% dplyr::select(-dplyr::matches("seq_number"))
  return(to_return)
}


#' Verify that the input ana_taxon_table file and the input mapping file meets specificationss
#' validate_input_biom takes one biom table as its input, and verfies that it meets
#' the expected standards.
#' The standards incude:
#' 1. Column names exist.
#' 2. One of the columns is named "sum.taxonomy"
#' 3. The "xxx_seq_number" column, if it ever existed, is removed
#' 4. All columns apart from sum.taxonomy should be numeric
#' 5. All columns apart from sum.taxonomy should have corresponding row in metadata file
#' @param taxon_table OTU table from Anacapa
#' @param metadata_file Qiime-style mapping
#' @author Gaurav Kandlikar
#' @export
validate_input_files <- function(taxon_table, metadata_file) {

  # 1. Column names exist.
  if (is.null(colnames(taxon_table))) {
    stop("The input biom table should have column names. The taxonomy column should be named 'sum.taxonomy'; the rest of the columns should be named according to their sample names.")
  }

  # 2. One of the columns is named "sum.taxonomy"
  if (!("sum.taxonomy" %in% colnames(taxon_table))) {
    stop("Please make sure that the taxonomy column in the input biom table is called 'sum.taxonomy'!")
  }

  # 3. The "xxx_seq_number" column, if it ever existed, is removed
  if (any(stringr::str_detect(colnames(taxon_table), "seq_number"))) {
    stop("Please makes sure that you have removed the 'xxx_seq_number' column from the dataset (note: this can be done with the function `scrub_seqNum_column`)")
  }

  # 4. All columns apart from sum.taxonomy should be numeric
  if (!(all(sapply(taxon_table %>% dplyr::select(-sum.taxonomy), is.numeric)))) {
    stop("Please make sure that all columns apart from sum.taxonomy only contain numeric data!")
  }

  # 5. All columns apart from sum.taxonomy should have corresponding row in metadata file
  if (!(all(colnames(taxon_table %>% dplyr::select(-sum.taxonomy)) %in% metadata_file[, 1]))) {
    stop("Please make sure that each sample in your biom table has a corresponding row in the mapping file!")
  }


}
