test_that("hello() greets", {
  expect_equal(hello("R"), "Hello, R!")
  expect_equal(hello(), "Hello, world!")
})

test_that("hello() validates input", {
  expect_error(hello(1), "single string")
  expect_error(hello(c("a", "b")), "single string")
})
