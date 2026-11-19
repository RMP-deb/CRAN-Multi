test_that("sum_squares_cpp() matches R", {
  expect_equal(sum_squares_cpp(c(1, 2, 3)), 14)
  expect_equal(sum_squares_cpp(numeric()), 0)
  x <- runif(100)
  expect_equal(sum_squares_cpp(x), sum(x^2))
})
