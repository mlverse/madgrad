
optim_madgrad <- torch::optimizer(
  initialize = function(params, lr = 1e-2, momentum = 0.9, weight_decay = 0,
                        eps = 1e-6) {

    if (momentum < 0 || momentum >= 1)
      rlang::abort("Momentum must be in the range [0,1].")

    if (lr <= 0)
      rlang::abort("Learning rate must be positive.")

    if (weight_decay < 0)
      rlang::abort("Weight decay must be non-negative.")

    if (eps < 0)
      rlang::abort("Eps must be non-negative.")

    defaults <- list(lr = lr, eps = eps, momentum = momentum,
                     weight_decay = weight_decay)

    super$initialize(params, defaults)
  },
  step = function(closure = NULL) {
    if (is.null(self$k))
      self$k <- 0
    loss <- super$step_helper(closure, function(group, param, ...) {

      eps <- group$eps
      lr <- group$lr + eps
      decay <- group$weight_decay
      momentum <- group$momentum

      ck <- 1 - momentum
      lamb <- lr * (self$k + 1)^0.5

      grad <- param$grad


      if (is.null(state(param))) {
        state(param) <- list()
        state(param)[["grad_sum_sq"]] <- torch::torch_zeros_like(param)$detach()
        state(param)[["s"]] <- torch::torch_zeros_like(param)$detach()
        if (momentum != 0)
          state(param)[["x0"]] <- param$clone()
      }

      if (decay != 0) {
        grad$add_(param, alpha=decay)
      }

      if (momentum == 0) {
        # Compute x_0 from other known quantities
        rms <- state(param)[["grad_sum_sq"]]$pow(1 / 3)$add_(eps)
        x0 <- param$addcdiv(state(param)[["s"]], rms, value=1)
      } else {
        x0 <- state(param)[["x0"]]
      }

      # Accumulate second moments
      state(param)[["grad_sum_sq"]]$addcmul_(grad, grad, value=lamb)
      rms <- state(param)[["grad_sum_sq"]]$pow(1 / 3)$add_(eps)

      # Update s
      state(param)[["s"]]$add_(grad, alpha=lamb)

      # Step
      if (momentum == 0) {
        p$copy_(x0$addcdiv(state(param)[["s"]], rms, value=-1))
      } else {
        z <- x0$addcdiv(state(param)[["s"]], rms, value = -1)
      }

      # p is a moving average of z
      param$mul_(1 - ck)$add_(z, alpha=ck)

    })
    self$k <- self$k + 1
    loss
  }
)


state <- function(self) {
  attr(self, "state")
}

`state<-` <- function(self, value) {
  attr(self, "state") <- value
  self
}
