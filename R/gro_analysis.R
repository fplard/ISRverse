# WARNING - Generated by {fusen} from dev/flat_growth.Rmd: do not edit by hand


#' Growth model selection
#' 
#' This function fits a series of growth models to a dataset, select the best one by AIC and estimates the percentiles of the predicted distribution of values.
#' 
#' @param data_weight \code{data.frame} including at least the numeric columns *Age*, *MeasurementValue* and *AnimalAnonID*.
#' @param all_mods \code{vector of character} indicatingthe growth models that need to be fit.The following models are supported : logistic, gompertz, chapmanRichards, vonBertalanffy, polynomial.
#' @param percentiles \code{vector of numeric} indicating the percentiles that need to be estimated. default: 95% predicted interval.
#' 
#' @import dplyr assertthat
#' @importFrom stats quantile qlnorm sd shapiro.test
#' @importFrom bbmle coef
#' @importFrom mgcv gam summary.gam predict.gam
#' @importFrom methods slot
#'
#' @return a list including:
#' * a data frame with the percentile selected
#' * the fit of the best model
#' * the AIC table of the model
#' * GOF: 3 GOF test including the normality of residuals and the test of trend in residuals against X and in the variance of the residuals
#' 
#' @export
#' @examples
#' Age <- sample(c(0:10), 100, replace = TRUE)
#' AnimalAnonID <- sample(c(0:20), 100, replace = TRUE)
#' MeasurementValue <- exp(0.2+15 * (1 - exp(-(0.1) * log(Age+1)))+ 
#'                           rnorm(100,0,0.01) + AnimalAnonID*0.1)-1 
#' dat = data.frame(Age = Age, MeasurementValue = MeasurementValue, 
#'                  AnimalAnonID = AnimalAnonID, MeasurementType = "Live Weight")
#'
#' out = Gro_analysis(dat, 
#'                    all_mods = c("logistic", "vonBertalanffy", "gam"), 
#'                    percentiles = c(2.5, 97.5))
Gro_analysis <- function(data_weight, all_mods =c("vonBertalanffy"), percentiles = c(2.5,97.5)
) {
   # Check correct format for inputs ---------------------------------------------
  assert_that(is.numeric(percentiles))
  assert_that(min(percentiles) > 0)
  assert_that(max(percentiles) < 100)
  assert_that(all(all_mods %in% c("logistic", "gompertz", "chapmanRichards", "vonBertalanffy", "polynomial", "gam")), msg = "The growth models supported are: logistic, gompertz, chapmanRichards, vonBertalanffy, and polynomial, in addition to GAM.")
  assert_that(is.data.frame(data_weight))
  assert_that(data_weight %has_name% c("MeasurementValue","Age", 'AnimalAnonID'))
  assert_that(all(data_weight$Age >= 0 ))
  assert_that(all(data_weight$MeasurementValue > 0 ))
  
  data_weight<-data_weight%>%
    mutate(logx = log(Age + 1),
           logz = log(MeasurementValue + 1))
  
  
  #Fitting the different growth models
  all_fits_tab=c()
  all_fits <- list()
  all_mods_g = stringr::str_subset(all_mods, 
                                   pattern = 'gam', 
                                   negate = T)
  
  if(length(all_mods_g)>0){
    all_fits <- lapply( 1:length(all_mods_g),
                        Gro_fitlog,
                        all_mods = all_mods_g,
                        dat = data_weight
    )
    
    for (i in 1:length(all_mods_g)){
      all_fits_tab <- rbind(all_fits_tab,all_fits[[i]]$tab%>%as_tibble)
    }
  }
  
  if('gam' %in% all_mods){
    fit_gam <-   mgcv::gam(logz~s(logx, bs = 'cr', k = 6) + s(AnimalAnonID, bs = 're'),
                           data = data_weight,
                           method = "ML",
                           drop.unused.levels = FALSE # do not drop empty level for prediction
    )
    b = mgcv::summary.gam(fit_gam)
    all_fits_tab <- rbind(all_fits_tab,tibble(index = length(all_mods_g) +1,
                                              model = "gam", 
                                              k =  sum(b$s.table[,2])+1,
                                              LSQ = sum(fit_gam$residuals^2))
    )
    all_fits[[length(all_mods_g) +1]] <- list(fit = fit_gam)
  }
  
  all_fits_tab <- all_fits_tab%>%
    mutate(QAIC = LSQ + 2 * k)%>% arrange(QAIC)
  best_std <- all_fits[[as.numeric(all_fits_tab[1, "index"]) ]]$fit
  
  #Vector for predictions
  zQuant <- tibble(Age = seq(min(data_weight$Age), max(data_weight$Age)+0.1, 0.1))
  
  #Fitted values and residuals
  if( all_fits_tab$model[1] == 'gam'){
    conv = fit_gam$converged
    elogz <- fit_gam$residuals
    lzexp <- predict.gam(fit_gam, newdata = tibble(logx = log(zQuant$Age+1),
                                                   AnimalAnonID = 1), exclude = c("s(AnimalAnonID)"))
  }else{
    growthMod <- all_fits[[as.numeric(all_fits_tab[1, "index"]) ]]$growthMod
    gam <- bbmle::coef(best_std)
    suppressWarnings(gam$logx <- data_weight$logx)
    logzfit <- do.call(growthMod, as.list(gam[c(1:(length(gam)-2),length(gam))]))
    conv = slot(best_std, "details")$convergence == 2
    elogz <- data_weight$logz - logzfit
    gam$logx =  log(zQuant$Age+1)
    lzexp <- do.call(growthMod, as.list(gam[c(1:(length(gam)-2),length(gam))]))
  }
  
  #GOF
  GOF = list(normal = T, X = T, var = T, conv = conv)
  elogz2 <- elogz^2
  if(length(elogz)<5000 & length(elogz)> 2){
  test  = shapiro.test(elogz)
  if(test$p.value<0.01){GOF$normal = FALSE}}
  a = summary(lm(elogz2 ~ data_weight$logx)) #test variance?
  if(a$coefficients[2,4]<0.01){GOF$X = FALSE}
  b = summary(lm(elogz ~ data_weight$logx)) #test pour senescence??
  if(b$coefficients[2,4]<0.01){GOF$var = FALSE}
  
  # Quantile calculation:
  sig <- sd(elogz) 
  for (al in 1:length(percentiles)) {
    zQuant[[paste0("percent",percentiles[al])]] <- qlnorm(percentiles[al] / 100, meanlog = lzexp, sdlog = sig) - 1
    zQuant[[paste0("percent",percentiles[al])]] [which( zQuant[[paste0("percent",percentiles[al])]] < 0)] = 0
  }
  if (!(50 %in% percentiles)){
    zQuant[["percent50"]] <- qlnorm(0.5, meanlog = lzexp, sdlog = sig) - 1
    zQuant[["percent50"]] [which( zQuant[["percent50"]] < 0)] = 0
    
  }
  
  all_fits_tab <- all_fits_tab%>% 
    dplyr::select(-index)
  
  return(list(percent = zQuant, 
              fit = best_std,
              AIC_tab =all_fits_tab,
              GOF = GOF)
  )
}
