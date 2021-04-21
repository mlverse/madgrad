expect_optim_works <- function(optim, defaults) {

  w_true <- torch::torch_randn(10, 1)
  x <- torch::torch_randn(100, 10)
  y <- torch::torch_mm(x, w_true)

  loss <- function(y, y_pred) {
    torch::torch_mean(
      (y - y_pred)^2
    )
  }

  w <- torch::torch_randn(10, 1, requires_grad = TRUE)
  z <- torch::torch_randn(10, 1, requires_grad = TRUE)
  defaults[["params"]] <- list(w, z)
  opt <- do.call(optim, defaults)

  fn <- function() {
    opt$zero_grad()
    y_pred <- torch::torch_mm(x, w)
    l <- loss(y, y_pred)
    l$backward()
    l
  }

  initial_value <- fn()

  for (i in seq_len(200)) {
    opt$step(fn)
  }


  expect_true(torch::as_array(fn()) <= torch::as_array(initial_value)/2)
}


