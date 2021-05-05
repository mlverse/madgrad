library(testthat)
library(madgrad)

if (Sys.getenv("TORCH_TEST", unset = 0) == 1)
  test_check("madgrad")
