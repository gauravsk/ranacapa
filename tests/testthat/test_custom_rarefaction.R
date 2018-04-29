context("check that the custom rarefaction works as expected")

# the test data ------
taxon_table <- data.frame(sum.taxonomy = c("a;b;c;d;f;u", "p;q;r;s;t;u"),
                               site_1 = c(11,100),
                               site_2 = c(100, 202))

metadata <- data.frame(site = c("site_1", "site_2"),
                        season = c("wet", "dry"),
                        host = c("oak", "sage"))
physeq_object <- convert_anacapa_to_phyloseq(taxon_table, metadata)

testthat::test_that("conversion to vegan matrix works for good files", {

  # the output object is a phyloseq object
  expect_is(custom_rarefaction(physeq_object, sample_size = 10, replicates = 1), "phyloseq")

  # each column in the outputted otu table should have a column sum equal to the sample_size
  expect_equal(custom_rarefaction(physeq_object, sample_size = 10, replicates = 1) %>%
                 otu_table %>% colSums %>% unique,
               10)
  expect_equal(custom_rarefaction(physeq_object, sample_size = 100, replicates = 1) %>%
                 otu_table %>% colSums %>% unique,
               100)
  # it should be a whole number in each column, even with many replicates
  expect_equal(custom_rarefaction(physeq_object, sample_size = 10, replicates = 2) %>%
                 otu_table %>% colSums %>% unique %% 1 %>% unique,
               0)
  # phyloseq object that is written should retain the taxonomy table and the sample_data
  expect_is(custom_rarefaction(physeq_object, sample_size = 10, replicates = 1) %>% tax_table,
            "taxonomyTable")
  expect_is(custom_rarefaction(physeq_object, sample_size = 10, replicates = 1) %>% sample_data,
            "sample_data")

  })

# if a sample is thrown out because it has too few samples, it should also be gone from the sample data
# site 1 just has 120 seqs, so setting the sample_size = 150 should get rid of site 1

filtered_sitenames <- colnames(taxon_table %>% select(-sum.taxonomy)) %>% setdiff(., "site_1")
rarified_object <- custom_rarefaction(physeq_object, sample_size = 150, replicates = 1)
testthat::test_that("sites with too few seqs get smoothly filtered out", {
  expect_equal(rarified_object %>% otu_table %>% ncol,
               1)
  expect_equal(rarified_object %>% sample_data %>% nrow,
               1)
  expect_identical(rarified_object %>% sample_data %>% rownames,
                   filtered_sitenames)
  expect_identical(rarified_object %>% otu_table %>% colnames,
                   filtered_sitenames)

})
