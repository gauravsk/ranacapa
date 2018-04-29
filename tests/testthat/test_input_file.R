context("check that bad input files break the validator function and good ones don't")

## the test data ------
# make a set of "good" input files
good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                        site_1 = c(0,1),
                        site_2 = c(10, 20))

good_maps <- data.frame(site = c("site_1", "site_2"),
                        season = c("wet", "dry"),
                        host = c("oak", "sage"))

# "break" the input files
# Get rid of column names
taxon_table_no_colNames <- good_taxon_table
colnames(taxon_table_no_colNames) <- NULL

# Replace the column name 'sum.taxonomy' with just 'taxonomy'
taxon_table_no_sum.tax  <- good_taxon_table
colnames(taxon_table_no_sum.tax)[1] <- "taxonomy"

# Retain "xxx_seq_number" column
taxon_table_seq_numberCol <- good_taxon_table
taxon_table_seq_numberCol <- taxon_table_seq_numberCol %>% mutate(A23_seq_number = rep(NA, nrow(taxon_table_seq_numberCol)))

# Make one column non-numeric
taxon_table_non_numeric_columns <- good_taxon_table
taxon_table_non_numeric_columns$site_1 <- as.character(taxon_table_non_numeric_columns$site_1) ##########should I test other things besides as.character? and what if there is a column that is not called site_x that is non-numeric?

# Have column that does not correspond to good_maps
taxon_table_extra_site <- good_taxon_table
taxon_table_extra_site <- taxon_table_extra_site %>% mutate(site_3 = rep(1, nrow(taxon_table_extra_site)))

# Having extra sites in the *metadata* doesn't break the validator
maps_extra_site <- data.frame(site = c("site_1", "site_2", "site_3"),
                        season = c("wet", "dry", "wet"),
                        host = c("oak", "sage", "maple"))

## the tests ------
testthat::test_that("various broken versions of input files break the validator", {
  # taxon files with no column names shouldn't work
  expect_error(validate_input_files(taxon_table_no_colNames, good_maps),
               "The input biom table should have column names. The taxonomy column should be named 'sum.taxonomy'; the rest of the columns should be named according to their sample names.")

  # taxon files without a column named "sum.taxonomy" sholdn't work
  expect_error(validate_input_files(taxon_table_no_sum.tax, good_maps),
               "Please make sure that the taxonomy column in the input biom table is called 'sum.taxonomy'!")

  # taxon files with a "xxx_seq_number" column shouldn't work
  expect_error(validate_input_files(taxon_table_seq_numberCol, good_maps),
               "Please makes sure that you have removed the 'xxx_seq_number' column from the dataset (note: this can be done with the function `scrub_seqNum_column`)", fixed = TRUE)

  # taxon files that contain non-numeric data should return an error
  expect_error(validate_input_files(taxon_table_non_numeric_columns, good_maps),
               "Please make sure that all columns apart from sum.taxonomy only contain numeric data!")

  # all sites in taxon file should be represented in metadata file
  expect_error(validate_input_files(taxon_table_extra_site, good_maps),
               "Please make sure that each sample in your biom table has a corresponding row in the mapping file!")
})

testthat::test_that("clean versions of input files return null", {

  expect_null(validate_input_files(good_taxon_table, good_maps))

  # It should be OK for metadata file to have extra information
  expect_null(validate_input_files(good_taxon_table, maps_extra_site))

})
