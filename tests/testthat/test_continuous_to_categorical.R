context("check that continous variables get converted to cagegorical")
library(dplyr)
library(tibble)

metadata_file <- data.frame(site = paste0("site_", 0:9),
                            season = rep(c("wet", "dry"),5),
                            host = rep(c("oak", "sage"), each = 5),
                            cont_1 = 0:9,
                            cont_2 = 9:0,
                            cont_3 = seq(from = 0.1, to = 1, by = 0.1),
                            cont_4 = rep(c(0.5, 1.8), each = 5),
                            cont_5 = rep(1, 10))
str(metadata_file)

testthat::test_that("continuous variable converted to categorical", {

  # not categorizing any columns works (returns the same df as input)
  expect_equal(categorize_continuous_metadata(metadata_file),
               metadata_file)

  # categorizing an already-categorized column doesn't do anything
  # (returns the same df as input)
  expect_equal(categorize_continuous_metadata(metadata_file, "season"),
               metadata_file)


  # if asking cont_1 to be categorical, only cont_1 is categorical
  expect_false(categorize_continuous_metadata(metadata_file, "cont_1") %>%
                 select(cont_2) %>% unlist %>% is.factor)
  expect_true(categorize_continuous_metadata(metadata_file, "cont_1") %>%
                select(cont_1) %>% unlist %>% is.factor)
  expect_false(categorize_continuous_metadata(metadata_file, "cont_1") %>%
                 select(cont_3) %>% unlist %>% is.factor)

  # cont_3 is not categorical if cont_1 and cont_2 are asked to be
  expect_false(categorize_continuous_metadata(metadata_file, c("cont_1", "cont_2")) %>%
                 select(cont_3) %>% unlist %>% is.factor)
  expect_true(categorize_continuous_metadata(metadata_file, c("cont_1", "cont_2")) %>%
                select(cont_1) %>% unlist %>% is.factor)
  expect_true(categorize_continuous_metadata(metadata_file, c("cont_1", "cont_2")) %>%
                select(cont_2) %>% unlist %>% is.factor)


  # Check that the order is right
  expect_equal(categorize_continuous_metadata(metadata_file, "cont_1") %>%
                 select(cont_1) %>% unlist(., use.names = F),
               factor(c(rep("low",4), rep("medium", 3), rep("high",3)),
                      levels = c("low","medium","high")))

  expect_equal(categorize_continuous_metadata(metadata_file, "cont_2") %>%
                 select(cont_2) %>% unlist(., use.names = F),
               factor(c(rep("high",3), rep("medium", 3), rep("low",4)),
                      levels = c("low","medium","high")))

  expect_equal(categorize_continuous_metadata(metadata_file, "cont_3") %>%
                 select(cont_3) %>% unlist(., use.names = F),
               factor(c(rep("low",4), rep("medium", 3), rep("high",3)),
                      levels = c("low","medium","high")))

  # make sure that for <2 unique entries in metadata_file, things work as expected
  expect_equal(categorize_continuous_metadata(metadata_file, "cont_4") %>%
                 select(cont_4) %>% unlist(., use.names = F),
               factor(c(rep("low",5), rep("high",5)),
                      levels = c("high","low")))



})
