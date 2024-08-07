# WARNING - Generated by {fusen} from dev/flat_select.Rmd: do not edit by hand

#' Gap analysis in longevity
#' 
#' Run a gap analysis on the distribution of longevity and give the threshold value to use in this distribution to avoid having gaps in longevities. Plot the distribution of longevities with gaps.
#' 
#' @param data.core \code{data.frame} including at least the following columns *Birth.Date* (\code{date}), *Depart.Date* (\code{date}), *Entry.Date* (\code{date}), and *Sex*
#' @param sexCats \code{character} Male, Female or All Default =  "All"
#' @param PlotDir \code{character} Directory to save the plots. Default = ""
#' @param maintitle \code{character} name of the graph to be saved. Default = ""
#' @param minN \code{numeric} Minimum number of individuals. Default = 50
#'
#' @return A list including
#' * the data with the selected sex and additional columns showing which individuals are above the percentiles 95%, 99% and 99.9%
#' * A summary list with:
#' - Sex = the sex selected
#' - Nglobal: the number of individuals of this sex
#' - Nlifespan : the number of individuals with estimated lifespan (i.e. estimated birth dates, censored individuals are also included)
#' - GapThresh : The threshold value selected for the distribution of longevity
#' - NThres : the number of individuals slected using this threshold
#' 
#' @export
#'
#' @examples
#' TempDir <- paste0(tempdir(check = TRUE),'\\temp')
#' dir.create(TempDir)
#' data(core) #### CHANGE DATASET WITH ONE EXCLUDING ABOVE95 99 99.9
#' out <- select_Longthreshold (data.core = core,  sexCats = "All", 
#'                              PlotDir = TempDir, maintitle = 'Gorilla_gorilla')
#' list.files(TempDir)
#' #remove temporary folder
#' unlink(TempDir, recursive = TRUE)
select_Longthreshold <- function(data.core,  sexCats = "All", 
                                 PlotDir = "", maintitle = '', minN = 50) {
  
  assert_that(is.data.frame(data.core ))
  assert_that(data.core  %has_name% c("BirthDate", "DepartDate",
                                      "EntryDate", "Sex"))
  assert_that(is.character(sexCats))
  assert_that(length(sexCats)==1, 
              msg = "You can chose only one sex category")
  assert_that(all(sexCats %in% c("Female", "Male", "All")))
  assert_that(is.character(PlotDir))
  checkmate::assert_directory_exists(PlotDir)
  
  coresubset <- data.core%>%
    mutate(
      #longevities:
      lifespans = as.numeric(DepartDate - BirthDate) / 365.25,
      # Calculate time alive:
      alive = as.numeric(DepartDate - EntryDate) / 365.25)
  
  # Output table:
  outTab <- tibble( 
    Sex = sexCats,
    Nglobal = nrow(coresubset),
    Nlifespan = 0,
    GapThresh = NA, 
    NThres = 0
  ) 
 
   if(sexCats %in% c('Male', 'Female')){
    coresex <- coresubset%>%filter(Sex ==sexCats)
  }else{coresex = coresubset}
  
  if(nrow(coresex)>0){
  # Check longevities:
  pdf(file = glue::glue("{PlotDir}\\{maintitle}_LongThres.pdf"), width = 3, height = 10)
  par(mfrow = c(4,1))
 
  quant = quantile (coresubset$lifespans,c(0.95,0.99,0.999))
  
  coresex <-  coresex%>%
    mutate(`above95`= if_else(lifespans> quant[1], 1, 0),
           `above99`= if_else(lifespans> quant[2], 1, 0),
           `above99.9`= if_else(lifespans> quant[3], 1, 0)
    )
  
  # Find gaps in longevities:
  corelong <- coresex%>%tidyr::drop_na(lifespans)
  outTab$Nlifespan <- nrow(corelong)
  
  
  if (nrow(corelong) > minN) {
    gapsAlive <- find_gaps(corelong$alive, 
                           maxAlive = quantile(corelong$alive, 0.5, na.rm = TRUE), 
                           plot = F)
    if (nrow(gapsAlive) > 0) {
      maxAlive <-  gapsAlive$iniAge[1]
    } else {
      maxAlive <- max(corelong$alive, na.rm = TRUE)
    }
    if (maxAlive < 5) {
      maxAlive <- 5
    } else if (maxAlive > 50) {
      maxAlive <- 50
    }
    
    par(mar = c(4, 4, 1, 1))
    gaps <- find_gaps(corelong$lifespans, plot = T,
                      main = maintitle, 
                      xlab = "")
    
    
    if (nrow(gaps) > 0) {
      allev <- 0
      while(ngap > 0 & allev < 3) {
        allev <- allev + 1
        qlev <- c("99.9", "99", "95")[allev]
        abcol <- sprintf("above%s", qlev)
        gaps <- find_gaps(corelong$lifespans[corelong[[abcol]] == 0], 
                          maxAlive = maxAlive, plot = T,
                          main = paste(qlev, "%"), 
                          xlab = "")
        
      }
      outTab$GapThresh <-as.numeric(qlev)
      
      if (allev < 3) {
        for (ll in (allev + 1):3) {
          qlev <- c("99.9", "99", "95")[ll]
          abcol <- sprintf("above%s", qlev)
          plot(c(0, 1), c(0, 1), col = NA, axes = FALSE, xlab = "", 
               ylab = "", main = paste(qlev, "%"))
          text(0.5, 0.5, "No gaps", cex = 2)
          box()
        }
      }
    } else {
      outTab$GapThresh <-100
      for (ll in 1:3) {
        qlev <- c("99.9", "99", "95")[ll]
        abcol <- sprintf("above%s", qlev)
        plot(c(0, 1), c(0, 1), col = NA, axes = FALSE, xlab = "", 
             ylab = "", main = paste(qlev, "%"))
        text(0.5, 0.5, "No gaps", cex = 2)
        box()
      }
    }
    outTab$NThres <- nrow(coresex%>%filter())
    
    
    
  } else {
    par(mar = c(4, 4, 1, 1))
    for (inpl in 1:4) {
      plot(c(0, 1), c(0, 1), col = NA, axes = FALSE, xlab = "", ylab ="")
      text(0.5, 0.5, "No data")
    }
  }
  
  dev.off()
  }
  return(list(summar = outTab, data = coresex) )
}



