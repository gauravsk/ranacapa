context("check if grouping by taxon works properly")

## the test data ------
# the function should get rid of the empty row;
# it should group the second taxonomy (pqrstu) together across the rows
# and add up the occurrences (occurrence in site 2 should be 25)
biom_duplicate_taxon <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u", "p;q;r;s;t;u", ""),
                        site_1 = c(0, 1, 0, 1),
                        site_2 = c(10, 20, 5, 1))

# This is what should look like after it is cleaned
biom_cleaned <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                                   site_1 = c(0, 1),
                                   site_2 = c(10, 25))
biom_cleaned$sum.taxonomy = as.character(biom_cleaned$sum.taxonomy)

## the tests -----
testthat::test_that("group_by_taxon is good", {
  # the number of rows should equal the number of unique taxonomies
  expect_equal(nrow(group_anacapa_by_taxonomy(biom_duplicate_taxon)),
               length(unique(biom_duplicate_taxon$sum.taxonomy[biom_duplicate_taxon$sum.taxonomy!=""])))

  # the number of columns in the output should be the same as in the input
  expect_equal(ncol(group_anacapa_by_taxonomy(biom_duplicate_taxon)),
               ncol(biom_duplicate_taxon))

  # this should be a data.frame, not a tbl_df
  expect_is(group_anacapa_by_taxonomy(biom_duplicate_taxon), "data.frame")

  # the output should be the same as the clean one made above
  expect_equal((group_anacapa_by_taxonomy(biom_duplicate_taxon)),(biom_cleaned))

})

