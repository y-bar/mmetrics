context("test-mmetrics")

df <- data.frame(
  gender = rep(c("M", "F"), 2),
  age = (2:5)*10,
  cost = c(51:54),
  impression = c(101:104),
  click = c(0:3)*3,
  conversion = c(0:3)
)

metrics <- rlang::quos(
  cost = sum(cost),
  ctr  = sum(click)/sum(impression)
)

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

test_that("summarize two keys implicitly", {
  df_expected <- dplyr::group_by(df, gender, age) %>%
    dplyr::summarise(cost=sum(cost), ctr=sum(click)/sum(impression))
  expect_equal(add(df, metrics = metrics), df_expected)
})

test_that("summarize", {
  df_expected <- dplyr::summarise(df, cost=sum(cost), ctr=sum(click)/sum(impression))
  expect_equal(add(df, metrics = metrics, summarize=TRUE), df_expected)
})
