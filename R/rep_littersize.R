# WARNING - Generated by {fusen} from dev/flat_repro.Rmd: do not edit by hand

#' Litter Size
#' 
#' Make a data frame of litter size per parent and birth date and produce summary tables of litter size. it selects only offspring/mother couples
#'
#' @param Reprodata \code{data frame} including at least the columns *AnonID*, *ParentAnonID*, *ParentType*, *Probability*, *Offspring_BirthDate*, *Offspring_Inst* and *ageBirth*
#' @param perAge \code{logical} Whether to estimate litter size per mother age. Default = FALSE
#' @param Nday \code{numeric} Number of consecutive days over which the birth dates of a litter/clutch can be spread. Default = 7
#' @param parentProb \code{numeric} Minimum percentage of parentage probability to include. Default = 80
#' @param minNlitter \code{numeric} Minimum number of litters to run the analysis. The data frame for litter size will be produced in all cases. Default = 30
#'
#' @return A list including:
#' * A data frame with the litter size per mother and birth date
#' * A table including the number and proportion of each size of litter
#' * Summary statistics including:
#' - NOffsp_prob: Number of offspring
#' - NParent_prob: Number of parents
#' - NReprEvent: Number of litters
#' - MeanLittSize: Mean litter size 
#' - MedLittSize: Median litter size 
#' - SdLittSize: Standard deviation of litter size 
#' - analyzed = FALSE,
#' - error: if the litter size where not analysze, the associated error is printed here. It can be :"No births with parentage probability higher than {parentProb} or  N litter < {minNlitter}
#' - Nerr: The number id of the error
#' * if perAge = TRUE, a table including the mean and standard deviation of litter size per maternal age
#' 
#' @export
#'
#' @examples
#' data(core)
#' data(collection)
#' data(parent)
#' data(moves)
#' #prepare Data
#' Data <- Rep_prepdata (coresubset = core, collection, parent, moves)
#'
#' #Estimate litter size
#' out <- Rep_littersize(Data$Reprodata, perAge = TRUE,
#'                            Nday = 7)
#'
#' out$littSizeTab
Rep_littersize <- function(Reprodata, perAge = FALSE,
                           Nday = 7, 
                           parentProb = 80,  minNlitter =30
                           ) {
  
   assert_that(is.data.frame(Reprodata))
  
  assert_that(Reprodata %has_name% c("AnonID", "ParentAnonID", "Probability", 
                                     "ParentType", "Offspring_BirthDate",
                                     "Offspring_Inst"))
  
     assert_that(is.logical(perAge))
     if(perAge){  assert_that(Reprodata %has_name%  "ageBirth")}
   assert_that(is.numeric(Nday))
  assert_that(is.numeric(parentProb))
  assert_that(is.numeric(minNlitter))


  
  littSumm <- tibble(NOffsp_prob = NULL, NParent_prob = NULL, NReprEvent = NULL,
                   analyzed = FALSE,error = "", Nerr= 0,
                   MeanLittSize = NULL, MedLittSize = NULL, SdLittSize = NULL)
  littSizeDf <- tibble()
  littSizeTab <- NULL
  littSizeperAge <- NULL
  
  subpar <- Reprodata %>%
    filter(ParentType == "Parentage_Dam",
            Probability >= parentProb)
  
  littSumm$NOffsp_prob <- length(unique(subpar$AnonID))
  littSumm$NParent_prob <- length(unique(subpar$ParentAnonID))
  
    
      if(nrow(subpar >0)){
    #remove duplicated lines
      subpar <- subpar%>%
        dplyr::select(ParentAnonID, AnonID, Offspring_BirthDate, Offspring_Inst)%>%
        distinct()
      

        
        for (id in unique(subpar$ParentAnonID)) {
          parid <- subpar%>%filter(ParentAnonID == id)%>%
            sort(Offspring_BirthDate)

          
          parid$diff=   as.numeric(diff(parid$Offspring_BirthDate))
          parid$litt=   as.numeric(diff > Nday)
          
          if(!perAge){
            pardid$ageBirth = 0
          }
          
          parid <- pardid%>%
            group_by (Offspring_BirthDate, Offspring_Istitution, ageBirth)%>%
            summarize(litterSize = n())
          
          littSizeDf <- rbind(littSizeDf, parid)
        }
if (nrow(subpar)>= minNlitter)  {
          littSizeTab <- littSizeDf%>%
            group_by(litterSize)%>%
           summarise( N = n(),
                      prop = n()/nrow(littSizeDf))
        
        if(perAge){
          littSizeperAge <- littSizeDf%>%
            group_by(Age)%>%
            summarise(littSizeMean = mean(litterSize),
                      littSizeMean = sd(litterSize),
                      Nlitter = n())
          
        }else{
          littSizeDf <- littSizeDf%>%
            dplyr::select(-ageBirth)
          
        }

        # Summary
        littSumm$MeanLittSize =  mean(littSizeDf$litterSize)
        littSumm$MedLittSize = median(littSizeDf$litterSize)
        littSumm$SdLittSize = median(littSizeDf$litterSize)
        littSumm$analyzed = TRUE 
        littSumm$NReprEvent= sum(littSize$N)
}else{
  error = glue::glue("N birts with Parentage probability higher than {parentProb}")
          Nerr = 2
}
      }else{
        error = glue::glue("N litter < {minNlitter}")
          Nerr = 1
        
      }
return(list(summary = littSumm, littSizeDf = littSizeDf,  
            littSizeTab =  littSizeTab, littSizeperAge = littSizeperAge))
}
