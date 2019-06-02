#' Calculates mean absolute error
#' 
#' @description Calculates mean absolute error from observed and predicted values.
#' 
#' @param y Vector of observed values.
#' @param pred Vector of predicted values.
#'
#' @return A numeric vector of length one.
#' 
#' @export
#'
#' @examples 
#' mae(1:10, 2:11)
mae <- function(y, pred) {
  stopifnot(length(y) == length(pred))
  mean(abs(y - pred)) 
}

#' Calculates root mean squared error of prediction
#' 
#' @description Calculates root mean squared error from observed and predicted values.
#' 
#' @param y Vector of observed values.
#' @param pred Vector of predicted values.
#'
#' @return A numeric vector of length one.
#' 
#' @export
#'
#' @examples 
#' rmse(1:10, 2:11)
rmse <- function(y, pred) {
  stopifnot(length(y) == length(pred))
  sqrt(mean((y - pred)^2))
}

#' Calculates proportion of predictions within range of observed values
#' 
#' @importFrom stats setNames
#' 
#' @description Calculates proportion of predictions within range of observed values.
#' 
#' @param y Vector of observed values.
#' @param pred Vector of predicted values.
#' @param q Vector of values forming the range.
#'
#' @return A numeric vector of the same length as q.
#' 
#' @export
#'
#' @examples 
#' propWithin(1:10, (1:10)^2, q = c(1, 5, 100))
propWithin <- function(y, pred, q = c(0.01, 0.02, 0.05, 0.1)) {
  stopifnot(length(y) == length(pred))
  r <- abs(y - pred)
  out <- sapply(q, function(z) mean(r <= z))
  setNames(out, gsub("\\.", "_", paste("Prop", q, sep = "_")))
}

#' Calculates different performance measures
#' 
#' @importFrom stats setNames
#' 
#' @description Calculates mean absolute error as well as certain proportions of predictions near observed values.
#' 
#' @param y Vector of observed values.
#' @param pred Vector of predicted values.
#' @param lab Label of the returned row.
#' @param q Vector of values forming the range.
#'
#' @return A \code{data.frame} with one row.
#' 
#' @export
#'
#' @examples 
#' perf(1:10, (1:10)^2, q = c(1, 5, 100))
perf <- function(y, pred, lab = "perf", q = c(0.01, 0.02, 0.05, 0.1)) {
  stopifnot(length(y) == length(pred))
  
  data.frame(lab = if (!is.null(lab)) lab,
             n = length(y),
             mae = mae(y = y, pred = pred),
             t(propWithin(y = y, pred = pred, q = q)),
             min = min(y - pred),
             max = max(y - pred))
}



