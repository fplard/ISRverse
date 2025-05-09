# WARNING - Generated by {fusen} from dev/flat_growth.Rmd: do not edit by hand

#' Remove outliers from percentiles
#'
#' @param z  \code{numeric vector} Measurement values
#' @param x  \code{numeric vector} Age
#' @param minq \code{numeric} Sensitivity of the function to remove outliers, between 0 and 1.
#' @param type \code{character} "both", "lower", or "upper" to choose if the lower or upper part of the distribution should be screened.
#'
#' @return
#' Vector of 0 and 1 indicating the measurement values to keep (=1) vs. the outliers (=0).
#' 
#' @importFrom stats quantile
#' 
#' @export
#' 
#' @details
#' This functions removes all values lower and higher than the median value multiplied by how many times the (100-q)th percentile is higher than the qth percentile of the distribution of weights.
#'
#' @examples
#' z = c(rnorm(100,5,1), runif(3,40,100))
#' x = rnorm(103,3,2)
#' Gro_Rout_quan (z,x, minq = 0.05)
Gro_Rout_quan <- function (z, x, minq = 0.05, type = "both") 
{
   # Check correct format for inputs ---------------------------------------------
  assert_that(is.numeric(z))
  assert_that(is.numeric(x))
  assert_that(length(z) == length(x))
  assert_that(is.numeric(minq))
  assert_that(is.character(type))
  assert_that(minq < 1, msg = "minq must be a proportion between 0 and 1")
  assert_that(minq > 0, msg = "minq must be a proportion between 0 and 1")
  assert_that(type %in% c("upper", "lower", "both"))
  qzn <- quantile(z, c(minq, 1-minq))
  qzrat <- qzn[2]/qzn[1]
  qzlu <- c(quantile(z, 0.5)/qzrat, quantile(z, 0.5) * qzrat)
  if(type =="both"){idkeep <- which(z > qzlu[1] & z < qzlu[2])}
  if(type =="lower"){idkeep <- which(z > qzlu[1])}
  if(type =="upper"){idkeep <- which(z < qzlu[2])}
  
  indKeep = rep(0,length(z))
  indKeep[idkeep] <- 1
  
  #Avoid removing youngest and oldest individuals that might be the lightest and heaviest 
  b = rank(x)
  indKeep[x < 0.1] <- 1
  indKeep[b < 3] <- 1
  indKeep[b > max(b-2, na.rm = T)] <- 1
  
  return(indKeep)
}
