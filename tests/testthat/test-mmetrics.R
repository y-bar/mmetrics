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
  ctr  = sum(click)/sum(impression)
)

test_that("define metrics", {
  expect_equal(metrics, rlang::quos(cost = sum(cost), ctr  = sum(click)/sum(impression)))
})

test_that("summarize one key", {
  df_expected <- dplyr::group_by(df, gender) %>%
    dplyr::summarise(cost=sum(cost), ctr=sum(click)/sum(impression))
  expect_equal(add(df, gender, metrics = metrics), df_expected)
})

test_that("summarize two keys", {
  df_expected <- dplyr::group_by(df, gender, age) %>%
    dplyr::summarise(cost=sum(cost), ctr=sum(click)/sum(impression))
  expect_equal(add(df, gender, age, metrics = metrics), df_expected)
})

test_that("summarize all", {
  df_expected <- dplyr::summarise(df, cost=sum(cost), ctr=sum(click)/sum(impression))
  expect_equal(add(df, metrics = metrics), df_expected)
})

test_that("disaggregate for quosure (x/y)", {
  df_tested <- as.data.frame(dplyr::mutate(df, !!disaggregate(metrics[["ctr"]])))
  df_expected <- as.data.frame(dplyr::mutate(df, ctr=click/impression))
  # Check except for column name
  expect_true(all.equal(df_expected, df_tested, check.names = FALSE))
})

test_that("disaggregate for quosure (x)", {
  df_tested <- as.data.frame(dplyr::mutate(df, !!disaggregate(metrics[["cost"]])))
  df_expected <- as.data.frame(dplyr::mutate(df, cost=cost))
  # Check except for column name
  expect_true(all.equal(df_expected, df_tested, check.names = FALSE))
})

test_that("disaggregate for quosures", {
  df_tested <- dplyr::mutate(df, !!!disaggregate(metrics))
  df_expected <- dplyr::mutate(df, cost=cost, ctr=click/impression)
  expect_equal(df_tested, df_expected)
})

