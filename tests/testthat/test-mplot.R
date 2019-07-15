context("test-mplot")

df <- dummy_data

metrics <- define(
  cost = sum(cost),
  ctr = sum(click)/sum(impression)
)

test_that("mplot_bar() returns ggplot2 object", {
  p <- mplot_bar(add(df, gender, metrics = metrics), ctr, gender)
  expect_is(p, "ggplot")
  expect_equal(p$data, add(df, gender, metrics = metrics))
})

test_that("mplot_bar() uses first column as x-axis if it is omitted", {
  p1 <- mplot_bar(add(df, gender, metrics = metrics), ctr, gender)
  p2 <- mplot_bar(add(df, gender, metrics = metrics), ctr)
  expect_is(p2, "ggplot")
  expect_equal(unlist(p1$labels), unlist(p2$labels))
  expect_equal(p1$data, p2$data)
})
