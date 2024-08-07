# WARNING - Generated by {fusen} from dev/flat_survival.Rmd: do not edit by hand

#' Age-specific survival
#' 
#' Estimate age-specific survival (i.e. the probability to leave at least a given number of years) from the parameters outputs of a Basta model.
#' 
#'
#' @param theMat \code{array} including the posteriors estimates of the model parameter
#' @param Nyear \code{numeric} number of year to survive Default = 1#
#' @param model \code{character} names of the basta models to run: "G0", "EX", "LO" and/or "WE". see ?basta for more information. Default = "GO"
#' @param shape \code{character} shape of the basta model: "simple", "Makeham", "bathtub".  see ?basta for more information. Default = "simple"
#' @param ncpus  \code{numeric} Number of core to use
#' @param ageMax \code{numeric} Maximum age in years Default = 120
#' @param dage \code{numeric} precision  for age Default = 0.01
#'
#' @return a data frame including age, the mean and 95% credible interval of the remaining life expectancy
#' 
#' @export
#' 
#' @importFrom paramDemo CalcSurv
#' @importFrom snowfall sfInit sfLibrary sfClusterApplyLB  sfStop
#' 
#' @examples
#' theMat = as.matrix(data.frame( b0 = rnorm(10, -6, 0.01),
#'                                b1= rnorm(10, 0.1, 0.01)))
#'
#'
#' out <- Sur_age(theMat, model = 'GO', shape = 'simple', ncpus = 2,
#'                  ageMax = 50, dage = 0.1, Nyear = 5)
Sur_age <- function(theMat, Nyear = 1, model = 'GO', shape = 'bathtub', ncpus = 1,
                      ageMax = 120, dage = 0.01) {
  
  assert_that(is.array(theMat))
  assert_that(is.numeric(ageMax))
  assert_that(ageMax > 1)
   assert_that(is.numeric(Nyear))
 assert_that(Nyear > 0)
  assert_that(is.numeric(dage))
  assert_that(dage > 0)
  assert_that(is.numeric(ncpus))
  assert_that(ncpus > 0)
  assert_that(is.character(model))
  assert_that(all(model %in% c("GO", "EX", "LO", "WE")))
  assert_that(is.character(shape))
  assert_that(all(shape %in% c("simple", "bathtub", "Makeham")))
  
  iseq <- floor(seq(0, nrow(theMat), length = ncpus + 1))
   xv <- seq(0, ageMax, by = dage)
 
  # run parallel estimation:
  sfInit(parallel = TRUE, cpus = ncpus)
  # Upload paramDemo:
  # sfLibrary(paramDemo)
  # export variables:
  # sfExport(list = c("iseq", "theMat", "model", "shape", "xMax", "dx"))
  # Run parallel function:
  exparal <- sfClusterApplyLB(1:ncpus, Sur_age_0, theMat = theMat,
                              model = model, shape = shape,  
                              iseq = iseq, Nyear = Nyear,
                              xv = xv )
  
  # Stop application:
  sfStop()
  
  # Gather estimates:
  for (jj in 1:ncpus) {
    if (jj == 1) {
      exMat <- exparal[[jj]]
    } else {
      exMat <- rbind(exMat, exparal[[jj]])
    }
  }
  
  Sur = paste0("Sur_",Nyear,"yr")
  exQuants <- tibble(Age = xv[1:ncol(exMat)], 
                         Lower = apply(exMat, 2, quantile, 0.025),
                         Upper = apply(exMat, 2, quantile, 0.975))%>%
    mutate({{Sur}} := apply(exMat, 2, mean))
  return(exQuants)
}


#' Raw age specific survival
#'
#' @return a data frame including age, the mean and 95% credible interval of survival
#' 
#' @importFrom paramDemo CalcSurv
#' 
#'
#' @noRd
Sur_age_0 <- function(sim= 1, theMat ,model = 'GO', shape = 'bathtub',  
                        iseq = 1:nrow(theMat), Nyear = 1, 
                      xv = seq(0, 50, by = 0.01)
 ) {
  
  idseq <- (iseq[sim] + 1):iseq[sim + 1]
  dep = which(xv == Nyear)
  surage <- t(sapply(idseq, function(ith) {
    theta <- theMat[ith, ]
    Sx <- paramDemo::CalcSurv(theta = theta, x = xv, model = model, shape = shape)
    idn0 <- length(Sx)
    ex = Sx[dep:idn0]/Sx[1:(idn0-dep+1)]
    return(ex)
  }))
  return( surage)
}
