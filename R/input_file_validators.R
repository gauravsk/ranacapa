if(getRversion() >= "2.15.1")  utils::globalVariables(c("Phylum", "Class", "Order", "Family", "Genus", "Species"))
#' Remove "xxx_seq_number" column from ana_taxon_table file if it exists
#' takes one taxon table as its input, and if it include
#' a column named "xxx_seq_number", it gets rid of that column - it's not of use to us
#' any longer
#'
#' @param taxon_table taxonomy table from Anacapa
#' @return ana_taxon_table file, with "xxx_seq_number" column removed (if it existed)
#' @examples
#' good_taxon_table <- data.frame(seq_number = c(1,2),
#' sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
#' site_1 = c(0,1), site_2 = c(10, 20))
#' scrub_seqNum_column(good_taxon_table)
#' @export
scrub_seqNum_column <- function(taxon_table) {
  to_return <- taxon_table %>% dplyr::select(-dplyr::matches("seq_number"))
  return(to_return)
}

#' Replace empty calls in Anacapa taxonomy tables with Unknown
#' (that is what they effectively are to most users)
#' @param taxon_table taxonomy table from Anacapa
#' @return ana_taxon_table with scrubbed 'sum.taxonomy' column
#' @examples
#' good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
#' site_1 = c(0,1), site_2 = c(10, 20))
#' scrub_taxon_paths(good_taxon_table)
#' @export
scrub_taxon_paths <- function(taxon_table) {
  to_return <- taxon_table
  new_sum_tax <- reshape2::colsplit(taxon_table$sum.taxonomy, ";",
                          names = c("Phylum", "Class", "Order", "Family", "Genus", "Species"))

  new_sum_tax <- new_sum_tax %>%
    dplyr::mutate(Phylum = ifelse(is.na(Phylum) | Phylum == "", "unknown", Phylum)) %>%
    dplyr::mutate(Class = ifelse(is.na(Class) | Class == "", "unknown", Class)) %>%
    dplyr::mutate(Order = ifelse(is.na(Order) | Order == "", "unknown", Order)) %>%
    dplyr::mutate(Family = ifelse(is.na(Family) | Family == "", "unknown", Family)) %>%
    dplyr::mutate(Genus = ifelse(is.na(Genus) | Genus == "", "unknown", Genus)) %>%
    dplyr::mutate(Species = ifelse(is.na(Species)| Species == "", "unknown", Species))

  new_sum_tax2 <- paste(new_sum_tax$Phylum,
                        new_sum_tax$Class,
                        new_sum_tax$Order,
                        new_sum_tax$Family,
                        new_sum_tax$Genus,
                        new_sum_tax$Species, sep = ";")
  to_return$sum.taxonomy <- new_sum_tax2
  return(to_return)
}

#' Verify that the input taxon_table file and the input mapping file meets specificationss
#' The function takes one taxon table as its input, and verfies that it meets
#' the expected standards.
#' The standards incude:
#' 1. Column names exist.
#' 2. One of the columns is named "sum.taxonomy"
#' 3. The "xxx_seq_number" column, if it ever existed, is removed
#' 4. All columns apart from sum.taxonomy should be numeric
#' 5. All columns apart from sum.taxonomy should have corresponding row in metadata file
#' @param taxon_table taxonomy table from Anacapa
#' @param metadata_file Qiime-style mapping
#' @examples
#' good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
#' site_1 = c(0,1), site_2 = c(10, 20))
#' good_maps <- data.frame(site = c("site_1", "site_2"),
#' season = c("wet", "dry"), host = c("oak", "sage"))
#' validate_input_files(good_taxon_table, good_maps)
#' @export
validate_input_files <- function(taxon_table, metadata_file) {

  # 1. Column names exist.
  if (is.null(colnames(taxon_table))) {
    stop("The input taxon table should have column names. The taxonomy column should be named 'sum.taxonomy'; the rest of the columns should be named according to their sample names.")
  }

  # 2. One of the columns is named "sum.taxonomy"
  if (!("sum.taxonomy" %in% colnames(taxon_table))) {
    stop("Please make sure that the taxonomy column in the input taxon table is named 'sum.taxonomy'!")
  }

  # 3. The "xxx_seq_number" column, if it ever existed, is removed
  if (any(stringr::str_detect(colnames(taxon_table), "seq_number"))) {
    stop("Please makes sure that you have removed the 'xxx_seq_number' column from the taxon table (note: this can be done with the function `scrub_seqNum_column`)")
  }

  # 4. All columns apart from sum.taxonomy should be numeric
  if (!(all(sapply(taxon_table %>% dplyr::select(-sum.taxonomy), is.numeric)))) {
    stop("Please make sure that all columns apart from sum.taxonomy only contain numeric data!")
  }

  # 5. All columns apart from sum.taxonomy should have corresponding row in metadata file
  if (!(all(colnames(taxon_table %>% dplyr::select(-sum.taxonomy)) %in% metadata_file[, 1]))) {
    stop("Please make sure that each sample in your taxon table has a corresponding row in the mapping file!")
  }


}
