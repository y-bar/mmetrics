context("test-mmetrics")

df <- data.frame(
  gender = rep(c("M", "F"), 2),
  age = (2:5)*10,
  cost = c(51:54),
  impression = c(101:104),
  click = c(0:3)*3,
  conversion = c(0:3),
  stringsAsFactors = FALSE
)

metrics <- define(
  cost = sum(cost),
  ctr = sum(click)/sum(impression)
)

test_that("define metrics", {
  expect_equal(metrics, rlang::quos(cost = sum(cost), ctr  = sum(click)/sum(impression)))
})

test_that("summarize one key", {
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::summarise(!!!metrics)
  expect_equal(add(df, gender, metrics = metrics, summarize = TRUE), df_expected)
})

test_that("summarize two keys", {
  df_expected <- dplyr::group_by(df, gender, age) %>% dplyr::summarise(!!!metrics)
  expect_equal(add(df, gender, age, metrics = metrics, summarize = TRUE), df_expected)
})

test_that("summarize all", {
  df_expected <- dplyr::summarise(df, !!!metrics)
  expect_equal(add(df, metrics = metrics), df_expected)
})

test_that("mutate one key", {
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::mutate(!!!metrics)
  expect_equal(add(df, gender, metrics = metrics, summarize = FALSE), df_expected)
})

test_that("mutate two keys", {
  df_expected <- dplyr::group_by(df, gender, age) %>% dplyr::mutate(!!!metrics)
  expect_equal(add(df, gender, age, metrics = metrics, summarize = FALSE), df_expected)
})

test_that("mutate all with", {
  df_expected <- dplyr::mutate(df, !!!metrics)
  expect_equal(add(df, metrics = metrics, summarize=FALSE), df_expected)
})

test_that("mutate with non summarize mode to evaluate ratio", {
  metrics <- define(cost_ratio = cost/sum(cost))
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::mutate(!!!metrics)
  expect_equal(add(df, gender, metrics = metrics, summarize = FALSE), df_expected)
})
