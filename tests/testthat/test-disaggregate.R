context("test-disaggregate")

df <- dummy_data

metrics <- define(
  cost = sum(cost),
  ctr  = sum(click)/sum(impression)
)

test_that("disaggregate for quosure (x/y)", {
  metric <- disaggregate(metrics[["ctr"]])
  df_tested <- as.data.frame(dplyr::mutate(df, !!metric))
  df_expected <- as.data.frame(dplyr::mutate(df, ctr=click/impression))
  # Check except for column name
  expect_true(all.equal(df_expected, df_tested, check.names = FALSE))
  # Check format
  expect_equal(rlang::quo_text(disaggregate(metrics[["ctr"]])), "click/impression")
})

test_that("disaggregate for quosure (x)", {
  df_tested <- as.data.frame(dplyr::mutate(df, !!disaggregate(metrics[["cost"]])))
  df_expected <- as.data.frame(dplyr::mutate(df, cost=cost))
  # Check except for column name
  expect_true(all.equal(df_expected, df_tested, check.names = FALSE))
})

test_that("disaggregate for quosure (complicated)", {
  expect_equal(rlang::quo_text(disaggregate(rlang::quo(sum(x)/sum(y) * aa))), "x/y * aa")
})

test_that("disaggregate for quosures", {
  df_tested <- dplyr::mutate(df, !!!disaggregate(metrics))
  df_expected <- dplyr::mutate(df, cost=cost, ctr=click/impression)
  expect_equal(df_tested, df_expected)
})

test_that("disaggregate should fail when arguemnt is not quosure(s)", {
  expect_error(disaggregate("hoge"), "metrics must be quosure or quores")
})
