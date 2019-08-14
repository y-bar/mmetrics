context("test-mmetrics")

df <- dummy_data

metrics <- define(
  count = n(),
  cost = sum(cost),
  ctr = sum(click)/sum(impression)
)

test_that("define metrics", {
  expect_equal(metrics, rlang::quos(count = n(), cost = sum(cost), ctr  = sum(click)/sum(impression)))
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

test_that("not evaluatable metrics must be removed without error", {
  # Metrics with meaningless one
  mm <- define(count = n(), x = xxx/sum(yyy), ctr = sum(click)/sum(impression), cost_ratio = cost/sum(cost))
  mg <- define(count = n(), x = xxx/sum(yyy), ctr = sum(click)/sum(impression))
  # Mutate
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::mutate(count = n(), ctr = sum(click)/sum(impression), cost_ratio = cost/sum(cost))
  expect_equal(gmutate(df, gender, metrics = mm), df_expected)
  expect_error(gmutate(df, gender, metrics = mm, filter = FALSE))
  # Summarize
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::summarize(count = n(), ctr = sum(click)/sum(impression))
  expect_equal(gsummarize(df, gender, metrics = mg), df_expected)
  expect_error(gsummarize(df, gender, metrics = mm, filter= FALSE))
})

test_that("not evaluatable metrics must produce error when filter = FALSE", {
  # Metrics with meaningless one
  mm <- define(count = n(), x = xxx/sum(yyy), ctr = sum(click)/sum(impression), cost_ratio = cost/sum(cost))
  mg <- define(count = n(), x = xxx/sum(yyy), ctr = sum(click)/sum(impression))
  # Mutate
  expect_error(gmutate(df, gender, metrics = mm, filter = FALSE))
  # Summarize
  expect_error(gsummarize(df, gender, metrics = mm, filter= FALSE))
})

test_that("metrics with a variable must be evaluated if the variable is defined/located at front column", {
  metrics <- define(total_impression = sum(impression), ctr = sum(click)/total_impression)
  # Mutate
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::mutate(!!!metrics)
  expect_equal(add(df, gender, metrics = metrics, summarize = FALSE), df_expected)
  # Summarize
  df_expected <- dplyr::group_by(df, gender) %>% dplyr::summarize(!!!metrics)
  expect_equal(add(df, gender, metrics = metrics, summarize = TRUE), df_expected)
})

test_that("add() and measure() must return the same result", {
  expect_equal(add(df, gender, metrics = metrics, summarize = FALSE), measure(df, gender, metrics = metrics, summarize = FALSE))
  expect_equal(add(df, gender, metrics = metrics), measure(df, gender, metrics = metrics))
})
