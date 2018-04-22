context("bad biom breaks the validator")

good_biom <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                        site_1 = c(0,1),
                        site_2 = c(10, 20))

# Get rid of column names
biom_no_colNames <- good_biom
colnames(biom_no_colNames) <- NULL

# Replace the column name 'sum.taxonomy' with just 'taxonomy'
biom_no_sum.tax  <- good_biom
colnames(biom_no_sum.tax)[1] <- "taxonomy"

good_maps <- data.frame(site = c("site_1", "site_2"),
                        season = c("wet", "dry"),
                        host = c("oak", "sage"))

testthat::test_that("biom input is good", {
  expect_error(validate_input_biom(biom_no_colNames, good_maps),
               "The input biom table should have column names. The taxonomy column should be named 'sum.taxonomy'; the rest
          of the columns should be named according to their sample names.")

  expect_error(validate_input_biom(biom_no_sum.tax, good_maps),
               "Please make sure that the taxonomy column in the input biom table is called 'sum.taxonomy'!")
})
