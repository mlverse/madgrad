% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/madgrad.R
\name{optim_madgrad}
\alias{optim_madgrad}
\title{A Momentumized, Adaptive, Dual Averaged Gradient Method for Stochastic
Optimization.}
\usage{
optim_madgrad(params, lr = 0.01, momentum = 0.9, weight_decay = 0, eps = 1e-06)
}
\arguments{
\item{params}{(list): List of parameters to optimize.}

\item{lr}{(float): Learning rate (default: 1e-2).}

\item{momentum}{(float): Momentum value in  the range [0,1) (default: 0.9).}

\item{weight_decay}{(float): Weight decay, i.e. a L2 penalty (default: 0).}

\item{eps}{(float): Term added to the denominator outside of the root operation to improve numerical stability. (default: 1e-6).}
}
\value{
An optimizer object implementing the \code{step} and \code{zero_grad} methods.
}
\description{
\href{https://arxiv.org/abs/2101.11075}{MADGRAD} is a general purpose optimizer that
can be used in place of SGD or Adam may converge faster and generalize better.
Currently GPU-only. Typically, the same learning rate schedule that is used
for SGD or Adam may be used. The overall learning rate is not comparable to
either method and should be determined by a hyper-parameter sweep.
}
\details{
MADGRAD requires less weight decay than other methods, often as little as
zero. Momentum values used for SGD or Adam's beta1 should work here also.

On sparse problems both weight_decay and momentum should be set to 0.
(not yet supported in the R implementation).
}
\examples{
if (torch::torch_is_installed()) {
library(torch)
x <- torch_randn(1, requires_grad = TRUE)
opt <- optim_madgrad(x)
for (i in 1:100) {
  opt$zero_grad()
  y <- x^2
  y$backward()
  opt$step()
}
all.equal(x$item(), 0, tolerance = 1e-9)
}

}
