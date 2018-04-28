context("bad biom breaks the validator")

## the test data ------
good_biom <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                        site_1 = c(0,1),
                        site_2 = c(10, 20))

good_maps <- data.frame(site = c("site_1", "site_2"),
                        season = c("wet", "dry"),
                        host = c("oak", "sage"))

# Get rid of column names
biom_no_colNames <- good_biom
colnames(biom_no_colNames) <- NULL

# Replace the column name 'sum.taxonomy' with just 'taxonomy'
biom_no_sum.tax  <- good_biom
colnames(biom_no_sum.tax)[1] <- "taxonomy"

# Retain "xxx_seq_number" column
biom_seq_numberCol <- good_biom
biom_seq_numberCol <- biom_seq_numberCol %>% mutate(A23_seq_number = rep(NA, nrow(biom_seq_numberCol)))

# Make one column non-numeric
biom_non_numeric_columns <- good_biom
biom_non_numeric_columns$site_1 <- as.character(biom_non_numeric_columns$site_1) ##########should I test other things besides as.character? and what if there is a column that is not called site_x that is non-numeric?

# Have column that does not correspond to good_maps
biom_extra_site <- good_biom
biom_extra_site <- biom_extra_site %>% mutate(site_3 = rep(1, nrow(biom_extra_site)))


## the tests ------
testthat::test_that("biom input is good", {
  expect_error(validate_input_biom(biom_no_colNames, good_maps),
               "The input biom table should have column names. The taxonomy column should be named 'sum.taxonomy'; the rest
          of the columns should be named according to their sample names.")

  expect_error(validate_input_biom(biom_no_sum.tax, good_maps),
               "Please make sure that the taxonomy column in the input biom table is called 'sum.taxonomy'!")

  expect_error(validate_input_biom(biom_seq_numberCol, good_maps),
               "Please makes sure that you have removed the 'xxx_seq_number' column from the dataset
         (note: this can be done with the function `scrub_seqNum_column`)", fixed = TRUE)

  expect_error(validate_input_biom(biom_non_numeric_columns, good_maps), "Please make sure that all columns apart from sum.taxonomy only contain numeric data!")

  expect_error(validate_input_biom(biom_extra_site, good_maps), "Please make sure that each sample in your biom table has a corresponding row in the mapping file!")

  expect_output(validate_input_biom(good_biom, good_maps), "success!")

})
