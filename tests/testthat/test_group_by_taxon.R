context("grouping by taxon")

## the test data ------
biom_duplicate_taxon <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u", "p;q;r;s;t;u"),
                        site_1 = c(0, 1, 0),
                        site_2 = c(10, 20, 5))


## the tests -----
testthat::test_that("group_by_taxon is good", {
  expect_equal(nrow(group_anacapa_by_taxonomy(biom_duplicate_taxon)), length(unique(biom_duplicate_taxon$sum.taxonomy)))

  expect_is(group_anacapa_by_taxonomy(biom_duplicate_taxon), "data.frame")

})

