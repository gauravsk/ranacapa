context("check that the physeq to vegan conversion proceeds smoothly")

# the test data ------

# validate a set of "good" input files -------
good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                               site_1 = c(0,1),
                               site_2 = c(10, 20))
vegan_formatted_taxon_table <- good_taxon_table %>%
  column_to_rownames("sum.taxonomy") %>% t

good_maps <- data.frame(site = c("site_1", "site_2"),
                        season = c("wet", "dry"),
                        host = c("oak", "sage"))

physeq_object <- convert_anacapa_to_phyloseq(good_taxon_table, good_maps)

testthat::test_that("conversion to vegan matrix works for good files", {

  # the function returns an object of class matrx
  expect_is(vegan_otu(physeq_object), "matrix")

  # the output matrix has as many columns as the number of taxon paths
  expect_equal(vegan_otu(physeq_object) %>% ncol,
               length(unique(good_taxon_table$sum.taxonomy)))

  # the output matrix has as many rows as the number of sites
  expect_equal(vegan_otu(physeq_object) %>% nrow,
                good_taxon_table %>% select(-sum.taxonomy) %>% ncol)

  # the output matches the expected vegan community matrix
  expect_identical(vegan_otu(physeq_object), vegan_formatted_taxon_table)
})
