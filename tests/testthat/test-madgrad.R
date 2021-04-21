test_that("madgrad works", {
  expect_optim_works(optim_madgrad, list(lr = 0.1))
})
