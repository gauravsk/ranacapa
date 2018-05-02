context("check that the anacapa to physeq conversion proceeds smoothly")
library(dplyr)
library(tibble)
library(phyloseq)
# the test data ------

# validate a set of "good" input files -------
good_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                               site_1 = c(0,1),
                               site_2 = c(10, 20))

good_maps <- data.frame(site = c("site_1", "site_2"),
                        season = c("wet", "dry"),
                        host = c("oak", "sage"))

testthat::test_that("conversion to physeq object works for good files", {

  # the function returns an object of class phyloseq
  expect_is(convert_anacapa_to_phyloseq(good_taxon_table, good_maps), "phyloseq")

  # the phyloseq object contains site an otu_table, a taxon_table, and a sample_data
  expect_is(convert_anacapa_to_phyloseq(good_taxon_table, good_maps) %>%
              otu_table,
            "otu_table")
  expect_is(convert_anacapa_to_phyloseq(good_taxon_table, good_maps) %>%
              sample_data,
            "sample_data")
  expect_is(convert_anacapa_to_phyloseq(good_taxon_table, good_maps) %>%
              tax_table,
            "taxonomyTable")

  # the returned otu_table has the same data as the input taxon table
  # the otu table has taxonomy as rowname, not in a 'sum.taxonomy' column
  expect_identical(convert_anacapa_to_phyloseq(good_taxon_table, good_maps) %>%
                     otu_table %>% data.frame,
                 good_taxon_table %>% tibble::column_to_rownames('sum.taxonomy'))

})

# Confirm that validation of input files happens ---------

bad_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                              site_1 = c(0,1),
                              # rename to site 22 here- no info for this site in metadata
                              site_22 = c(10, 20))


testthat::test_that("conversion to physeq object breaks for bad files", {
  expect_error(convert_anacapa_to_phyloseq(bad_taxon_table, good_maps),
               "Please make sure that each sample in your biom table has a corresponding row in the mapping file!")
})

# make sure that the taxon table is grouped by taxonomy during the conversion --------
duplicate_taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u", "p;q;r;s;t;u"),
                                    site_1 = c(0,1, 1),
                                    site_2 = c(10, 20, 1))

testthat::test_that("duplicate entries in taxon table get summarized", {
  # check that it has happened in the tax_table
  expect_equal(convert_anacapa_to_phyloseq(duplicate_taxon_table, good_maps) %>% tax_table %>% nrow,
               length(unique(duplicate_taxon_table$sum.taxonomy)))

  # check that it has happened in the otu_table
  expect_equal(convert_anacapa_to_phyloseq(duplicate_taxon_table, good_maps) %>% otu_table %>% nrow,
               length(unique(duplicate_taxon_table$sum.taxonomy)))

})

# make sure that extra entries in the metadata file get thrown out during the conversion process

extra_maps <- data.frame(site = c("site_1", "site_2", "site_Z"),
                        season = c("wet", "dry", "autumn"),
                        host = c("oak", "sage", "maple"))

test_that("extra entries in metadata file get filtered out", {
  expect_equal(convert_anacapa_to_phyloseq(good_taxon_table, extra_maps) %>% sample_data %>% nrow,
               good_taxon_table %>% select(-sum.taxonomy) %>% ncol)
  expect_identical(convert_anacapa_to_phyloseq(good_taxon_table, extra_maps) %>% sample_data %>%
                     select(site) %>% unlist %>% as.character,
                   good_taxon_table %>% select(-sum.taxonomy) %>% colnames)
})
