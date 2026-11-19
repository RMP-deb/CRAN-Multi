test_that("sum_squares_rust() matches R", {
  expect_equal(sum_squares_rust(c(1, 2, 3)), 14)
  expect_equal(sum_squares_rust(numeric()), 0)
  x <- runif(100)
  expect_equal(sum_squares_rust(x), sum(x^2))
})
