context("check that continous variables get converted to cagegorical")

metadata_file <- data.frame(site = paste0("site_", 0:9),
                            season = rep(c("wet", "dry"),5),
                            host = rep(c("oak", "sage"), each = 5),
                            cont_1 = 0:9,
                            cont_2 = 9:0,
                            cont_3 = seq(from = 0.1, to = 1, by = 0.1))
str(metadata_file)

testthat::test_that("continuous variable converted to categorical", {
  # Check that all three cont variables end up as factors
  expect_true(categorize_continuous_metadata(metadata_file) %>%
              select(cont_1) %>% unlist %>% is.factor)
  expect_true(categorize_continuous_metadata(metadata_file) %>%
                select(cont_2) %>% unlist %>% is.factor)
  expect_true(categorize_continuous_metadata(metadata_file) %>%
                select(cont_3) %>% unlist %>% is.factor)

  # Check that the order is right
  expect_equal(categorize_continuous_metadata(metadata_file) %>%
                 select(cont_1) %>% unlist(., use.names = F),
               factor(c(rep("low",4), rep("medium", 3), rep("high",3)),
                      levels = c("low","medium","high")))

  expect_equal(categorize_continuous_metadata(metadata_file) %>%
                 select(cont_2) %>% unlist(., use.names = F),
               factor(c(rep("high",3), rep("medium", 3), rep("low",4)),
                      levels = c("low","medium","high")))

  expect_equal(categorize_continuous_metadata(metadata_file) %>%
                 select(cont_3) %>% unlist(., use.names = F),
               factor(c(rep("low",4), rep("medium", 3), rep("high",3)),
                      levels = c("low","medium","high")))


})
