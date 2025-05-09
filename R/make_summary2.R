# WARNING - Generated by {fusen} from dev/flat_main.Rmd: do not edit by hand

#' Summarize taxon profiles analyses
#' 
#' Produce summary tables of the demographic analyses made for all species
#'
#' @param AnalysisDir  \code{character} Directory where to find the analyses results: .Rdata files.
#' @param SaveDir  \code{character} Directory where to save summary plots and tables.
#' @param namefile \code{character} Suffix to add to the name of files produced if needed.
#' @param TaxaList \code{vector of character} names of the taxa studied.
#' @param BySex \code{list} of the taxa names indicating the sexes analyzed.
#' @param Sections \code{vector of character} names of the sections: "sur", "rep" and/or "gro". Default = c("sur", "rep", "gro")
#' @param ModelSur \code{character} Name of the survival models to save
#' @return It saves :
#' * A general summary table including:
#'     * NRaw : Raw number of individuals
#'     * NDate : Number of individuals with an entry date posterior to the minimum date
#'     * NGlobal: Number of individuals selected from global Collections
#'     * NBirthType: Number of individuals selected from birth type
#'     * NUncertBirth: Number of individuals selected from uncertainty in birth
#'     * NAlive: Number of individuals still alive
#'     * FirstDate: Date of first record
#'     * MaxAgeRaw: Maximum observed age.
#' * A table AnyAna including:
#'     * Nselect: the number of individuals of this sex
#'     * Nlifespan : the number of individuals with estimated lifespan (i.e. estimated birth dates, censored individuals are also included)
#'     * GapThresh : The threshold value selected for the distribution of longevity
#'     * NThres : the number of individuals selected using this threshold
#'     * Surv_Ana: whether the survival analysis has been run 
#'     * Surv_error: if no survival analyses: the error explaining why
#'     * Surv_model: if the survival analysis run, the name of the model selected
#' * A table for the survival section including main metrics and checks of the survival analysis. See ?Sur_main() for more details

#' @export
#' 
#' @importFrom ggpubr ggarrange
#' 
#' @examples
#' file = system.file("sci_Animal.csv", package = 'ISRverse')
#' AnalysisDir  = paste0(dirname(file),'/Rdata')
#' SaveDir = paste0(tempdir(check = TRUE),'/temp')
#' dir.create(SaveDir)
#'
#' SummTab <- make_summary2(AnalysisDir, SaveDir,
#'                          TaxaList = "Reptilia",
#'                          BySex = list(Reptilia = c("Male", "Female")) ,
#'                          Sections = c("sur")
#' )
#' list.files(SaveDir)
#' unlink(SaveDir, recursive = TRUE)
make_summary2 <- function (AnalysisDir, SaveDir, namefile = "",
                           TaxaList = "Mammalia", 
                           BySex = list(Mammalia = c("Male", "Female")) , Sections = c("sur"),
                           ModelSur = "from0"
){
  nullToNA <- function(x) {
    x[sapply(x, is.null)] <- NA
    return(x)
  }
  # Check correct format for inputs -----------------------------------------------------------------------
  assert_that(is.character(TaxaList))
  assert_that(is.character(Sections))
  assert_that(all(Sections %in% c("sur", "gro", "rep")))
  checkmate::assert_directory_exists(AnalysisDir)
  checkmate::assert_directory_exists(SaveDir)
  assert_that(is.character(namefile))
  assert_that(length(ModelSur)==1)
  assert_that(is.list(BySex))
  assert_that(all(TaxaList %in% names(BySex)), msg = "BySex should be a list with names identical to TaxaList")
  
  # List of available analysis Results  -----------------------------------------------------------------------
  SRGlist <- list.files(AnalysisDir, pattern = ".RData")
  assert_that(length(SRGlist) > 0, 
              msg = glue::glue("There are no result file in {AnalysisDir}"))
  SRGsps <- gsub(".RData", "", SRGlist)
  
  # Loop over taxa: load result for each species and save summary metrics --------------------------------------
  icount <- 0
  for (Taxa in TaxaList) {
    
    SRGsps_ta = SRGsps%>%stringr::str_subset(Taxa)
    SRGspecies <- SRGsps_ta%>%
      stringr::str_remove(pattern = paste0(Taxa, '_'))%>%
      stringr::str_replace("_", " ")
    SexCats <- BySex [[Taxa]]
    icount <- icount + 1
    
    #Initialize tables ----------------------------------------------------------
    # main table giving summary of data used and selected
    table<-tibble(Class = rep(Taxa, length(SRGsps_ta)),
                  Species = SRGspecies,
                  Sex = "All",
                  NRaw = numeric(1),
                  NDate = numeric(1),
                  NGlobal = numeric(1),
                  NBirthType = numeric(1),
                  NUncertBirth = numeric(1),
                  NAlive = numeric(1),
                  FirstDate = as.Date(x = integer(1), origin = "1980-01-01"),
                  MaxAgeRaw = numeric(1),
                  ExtractDate =  as.Date(x = integer(1), origin = "1980-01-01"),
                  
    )
    AnyAna<- tibble(Class = rep(Taxa, length( SRGsps_ta )*length(SexCats)),
                    Species = rep(SRGspecies, each = length(SexCats)),
                    Sex = rep(SexCats, length(SRGspecies)),
                    Nselect = numeric(1),
                    Nlifespan = numeric(1),
                    GapThresh = numeric(1),
                    NThres = numeric(1),
                    Surv_Ana = logical(1), 
                    Surv_error = character(1),
                    Surv_model = character(1),
    )
    # Survival tables:
    if ("sur" %in% Sections){
      tempsur <- tibble(Class = character(0),
                        Species =  character(0),
                        Sex =  character(0),
                        models = character(0),
                        Data = character(0),
                        firstage = character(0),
                        param = character(0),
                        stat = character(0),
                        value = numeric(0)
                        
      )
    }else{tempsur = tibble()}
    i = 0
    # Loop over species
    for (isp in SRGsps_ta) {
      i = i+1
      specie =isp%>%
        stringr::str_remove(pattern = paste0(Taxa, '_'))%>%
        stringr::str_replace("_", " ")
      cat("\n", Taxa,": ", SRGspecies[i], "--", round(i / length(SRGsps_ta) * 100, 1),"%")
      # SRG file:
      load(glue::glue("{AnalysisDir}/{isp}.RData"))
      
      #Update main table
      table = table%>%
        rows_update(repout$general%>%nullToNA%>%as_tibble %>% 
                      mutate(Species = specie, Sex = "All"), 
                    by = c("Species", "Sex"), unmatched = "ignore")
      
      #Loop over sex categories
      for (sx in SexCats) {
        #Update each table
        if(length(repout$summar[[sx]])>0){
          AnyAna = AnyAna%>%
            rows_update(repout$summar[[sx]]%>%nullToNA%>%as_tibble() %>% 
                          mutate(Species = specie, Sex = sx), 
                        by = c("Sex", "Species"), unmatched = "ignore")
        }
        if("sur" %in% Sections){
          nam =  ModelSur
          for( n in 1:length(nam)){
            if(length(repout$surv[[sx]][[n]]$summary)>0){
              
              tempsur <- rbind(tempsur,
                               repout$surv[[sx]][[n]]$summary%>%nullToNA%>%
                                 as_tibble() %>% dplyr::select(-c(model,Nerr, analyzed,error))%>%
                                 tidyr::pivot_longer(everything(), names_to = 'param', values_to = "value")%>%
                                 mutate(Species = specie,
                                        Sex = sx,
                                        Class = Taxa,
                                        models = nam[n],
                                        Data = "Raw",
                                        firstage = "birth",
                                        stat = "value"))
              AnyAna = AnyAna%>%
                rows_update(repout$surv[[sx]][[n]]$summary%>%nullToNA%>%
                              as_tibble() %>% dplyr::select(c(model,  analyzed,error))%>% 
                              mutate(Species = specie,Sex = sx)%>%
                              rename(Surv_Ana = analyzed, Surv_error = error, Surv_model =model),
                            by = c("Sex", "Species"), unmatched = "ignore")
              
              tempsur <- rbind(tempsur,
                               repout$surv[[sx]][[n]]$metrics%>%nullToNA%>%
                                 as_tibble() %>%
                                 mutate(Class = Taxa,
                                        Species = specie,
                                        Sex = sx,
                                        models = nam[n]))
              
              tempsur <- rbind(tempsur,repout$surv[[sx]][[n]]$check%>%nullToNA%>%
                                 as_tibble() %>%
                                 tidyr::pivot_longer(everything(), names_to = 'param', values_to = "value")%>%
                                 mutate(Species = specie,
                                        Sex = sx,
                                        Class = Taxa,
                                        models = nam[n],
                                        Data = "Raw",
                                        firstage = "birth",
                                        stat = "value"))
            }
          }
        }
      }
    }
    if (icount == 1) {
      SummTab <-table
      SurTab <- tempsur
    } else {
      SummTab <- rbind(SummTab, table)
      SurTab <- rbind(SurTab, tempsur)
    }
    
  }
  # Write section tables--------------------------------------------------
  if("sur" %in% Sections){  
    readr::write_excel_csv2(SurTab, file = glue::glue("{SaveDir}/DP_Survival{namefile}.csv"))
  }
  # Write main tables------------------------------------------------------------------
  readr::write_excel_csv2(AnyAna, file =  glue::glue("{SaveDir}/DP_Any_Ana{namefile}.csv"))
  readr::write_excel_csv2(SummTab, file =  glue::glue("{SaveDir}/DP_Analyses{namefile}.csv"))
  return(SummTab)
}
