# WARNING - Generated by {fusen} from dev/flat_main.Rmd: do not edit by hand

#' Run Taxon Profiles
#' 
#' Load data needed and run or update demographic analyses for the list of species selected
#'
#' @param Taxa \code{character} Name of the taxa studied
#' @param SpeciesList \code{vector of character} Species selected
#' @param ZIMSDir \code{character} Directory where to find data
#' @param AnalysisDir \code{character} Directory where to save results
#' @param PlotDir \code{character} Directory to save the plots. Default: no plot is saved
#' @param ExtractDate \code{character 'YYYY-MM-DD'} Date of data extraction
#' @param MinBirthDate  \code{character}: Earliest possible date: date used when minimum birth or death dates are unknown
#' @param BirthType \code{character} Captive, Wild, or All.
#' @param MinDate \code{character 'YYYY-MM-DD'} Earliest date to include data
#' @param Sections \code{vector of character} Names of the sections to update in the results: "sur", "rep" and/or "gro".
#' @param ErasePrevious \code{logical} Whether the current result file should be deleted (before being replaced).
#' @param SexCats \code{character} Male, Female or All.
#' @param Global \code{logical} Whether only individuals belonging to global collections should be used.
#' @param InParallel \code{logical} Whether this function is run in parallel on different computers. In other words: should the species list be divided?
#' @param ipara \code{numeric} ID number of the computer used
#' @param npara \code{numeric} Number of computers used in parallel
#' @param MinN \code{numeric} Minimum number of individuals needed to run the analysis.
#' @param spOutLev \code{vector of character} List of species for which the Maximum threshold for the longevity distribution is 99.9% instead of MaxOutl.
#' @param MinInstitution \code{numeric} Minimum number of institutions that should hold records to run the analyses.
#' @param UncertBirth \code{numeric}: Maximum uncertainty accepted for birth dates, in days
#' @param UncertDeath \code{numeric}: Maximum uncertainty accepted for death dates, in days.
#' @param UncertDate \code{numeric}: Maximum uncertainty accepted for measurement dates: weight, in days.
#' @param MinNSur \code{numeric} Minimum number of individual records to run the survival analysis.
#' @param MaxNSur \code{numeric} Maximum number of individual records to run the survival analysis.
#' @param MinLx  \code{numeric} Value used for longevity threshold and for checks. between 0 and 1. Minimum reached survivorship from the raw Kaplan Meier analysis. This number avoids running survival analysis if there are too few dead individuals in the data. Lower is better.
#' @param MinMLE \code{numeric} Value used for checks. Minimum survivorship allowed at mean life expectancy. Between 0 and 1.
#' @param MaxLE \code{numeric} Value used for checks. Maximum remaining life expectancy at last observed age. In years.
#' @param MaxOutl \code{numeric} Start threshold to select individuals based on the longevity distribution: 100%, 99.9, 99 or 95%. This number must decrease when many errors are expected in longevity data.
#' @param MinBirthKnown  \code{numeric} between 0 and 1. Minimum proportion of individuals with a known birth month in the data.
#' @param MaxAge \code{numeric} Maximum possible age in years. Only used for model predictions. This argument is not used to select data.
#' @param MinAge \code{numeric} Ages at which the analyses should start.  see ?basta for more information.
#' @param ModelsSur \code{vector of characters} names of the survival basta models to run: "G0", "EX", "LO" and/or "WE". see ?basta for more information.
#' @param Shape \code{character} Shape of the survival basta model to run: "simple", "Makeham", "bathtub".  see ?basta for more information.
#' @param LastDead  \code{logical} Whether the longest lived individual should be considered dead.
#' @param niter  \code{numeric}. Number of MCMC iterations to run the survival model. see ?basta for more information.
#' @param burnin  \code{numeric} Number of iterations removed so that the survival model has time to converge. see ?basta for more information. 
#' @param thinning  \code{numeric} Number of iteration to run the survival model before saving a set of parameters. see ?basta for more information. 
#' @param nchain  \code{numeric} Number of chains to run the survival model.
#' @param ncpus  \code{numeric} Number of computer core to use.
#' @param RepSect \code{character} Names of the reproductive analyses to run: "agemat", "litter" and/or ...
#' @param NDay \code{numeric} Number of consecutive days over which the birth dates of a litter/clutch can be spread
#' @param ParentPercDam \code{numeric} Minimum percentage of parentage probability to include Dam.
#' @param ParentPercSire \code{numeric} Minimum percentage of parentage probability to include Sire.
#' @param MinNLitter \code{numeric} Minimum number of litters to run the analysis. The data frame for litter size will be produced in all cases. 
#' @param MinNRepro \code{numeric} Minimum number of birth records needed to run reproductive analyses.
#' @param MinNPaRepro \code{numeric} Minimum number of unique parent records needed to run reproductive analyses.
#' @param MinNSeas \code{numeric} XXXXXXXXXXX
#' @param MinNGro \code{numeric} Minimum number of weight needed to fit the growth models
#' @param MinNIGro \code{numeric} Minimum number of unique individuals needed to fit the growth models
#' @param MeasureType \code{vector of characters} Names of the types of measurement that should be included.  Default: all measurement type are included.
#' @param ModelsGro \code{vector of characters} Names the growth models that need to be fit.The following models are supported : logistic, gompertz, chapmanRichards, vonBertalanffy, polynomial. default = "vonBertalanffy"
#'
#' @return Save and replace the result file for each species in the list. The file is saved in {AnalysisDir}/Rdata/{Taxa}_{species}.Rdata
#' @export
#'
#' @examples
#' # Here is an example but use directly your own ZIMSDir (directory to find data) 
#' # and AnalysisDir (directory to save the analysis)
#' file = system.file("sci_Animal.csv", package = 'ISRverse')
#' ZIMSDir = dirname(file)
#' AnalysisDir = paste0(tempdir(check = TRUE),'/temp')
#' PlotDir = paste0(AnalysisDir,'/plot')
#' # dir.create(AnalysisDir)
#' dir.create(paste0(AnalysisDir,'/Rdata'), recursive = TRUE)
#' dir.create(PlotDir)
#'
#' #This code run the survival analysis
#' run_txprofile(Taxa = "Reptilia", SpeciesList = "All",
#'               ZIMSDir = ZIMSDir, AnalysisDir = AnalysisDir,
#'               PlotDir = PlotDir,
#'               ExtractDate = "",
#'               MinDate = "1980-01-01",
#'               Sections = c("sur"),
#'               SexCats = c('Male', 'Female'),
#'               niter = 1000, burnin = 101, thinning = 10, nchain = 3, ncpus = 3
#' )
#'
#' list.files(PlotDir)
#' list.files(paste0(AnalysisDir,'/Rdata'))
#'
#' unlink(AnalysisDir, recursive = TRUE)
#' unlink(PlotDir, recursive = TRUE)
run_txprofile <- function(Taxa, SpeciesList, ZIMSDir, 
                          AnalysisDir, PlotDir,
                          ExtractDate, MinDate = "1980-01-01",
                          Sections, ErasePrevious = FALSE,
                          SexCats = c('Male', 'Female'), MinBirthDate = "1900-01-01",
                          InParallel = FALSE, ipara = 1, npara = 1, 
                          MinN= 50,  MaxOutl =99,  spOutLev = NULL, Global = TRUE,
                          UncertBirth = 365,  UncertDeath = 365,  UncertDate = 365, 
                          MinNSur = 50, MaxNSur = NULL, MinInstitution = 2,
                          MinLx = 0.1, MinBirthKnown = 0.3, MaxAge =120,
                          MinMLE = 0.1, MaxLE = 2, MinAge = 0,
                          ModelsSur = "GO", Shape = "bathtub",
                          niter = 25000, burnin = 5001, thinning = 20, 
                          nchain = 3, ncpus = 2,
                          RepSect = c('agemat', 'litter'),
                          BirthType = "Captive", LastDead = FALSE,
                          ParentPercSire = 80, ParentPercDam = 80, MinNLitter = 20,NDay = 7,
                          MinNRepro = 100, MinNPaRepro = 30, MinNSeas = 50, 
                          MinNGro =100,MinNIGro = 50, MeasureType = "Live weight",
                          ModelsGro = "vonBertalanffy"
                          
){
  # Check correct format for inputs -----------------------------------------------------------------------
  assert_that(is.character(Taxa))
  assert_that(is.character(Sections))
  assert_that(all(Sections %in% c("sur", "gro", "rep")))
  assert_that(is.character(SpeciesList))
  assert_that(is.logical(Global))
  MinDate = lubridate::as_date(MinDate)
  ExtractDate = lubridate::as_date(ExtractDate)
  assert_that(BirthType %in% c("Captive", "Wild", "All"))
  assert_that(is.logical(ErasePrevious))
  assert_that(is.logical(InParallel))
  assert_that(is.numeric(ipara))
  assert_that(is.numeric(npara))
  assert_that(ipara <= npara)
  
  assert_that(is.numeric( MaxOutl))
  assert_that(is.numeric(MinAge))
  assert_that(MinAge>=0)
  assert_that(MaxOutl <= 100)
  assert_that(is.numeric(UncertBirth))
  assert_that(is.numeric(UncertDeath))
  assert_that(is.numeric(UncertDate))
  assert_that(is.double(MinInstitution))
  assert_that(is.numeric(ncpus))
  assert_that(ncpus > 0)
  checkmate::assert_directory_exists(PlotDir)
  assert_directory_exists(ZIMSDir)
  assert_directory_exists(AnalysisDir)
  assert_directory_exists(glue("{AnalysisDir}/Rdata"))
  
  if("sur" %in% Sections){
    
    assert_that(is.numeric(MinNSur))
    assert_that(MinNSur > 0)
    if(!is.null(MaxNSur)) assert_that(is.numeric(MaxNSur))
    assert_that(is.numeric(MinLx))
    assert_that(MinLx >= 0 & MinLx <= 1)
    assert_that(is.numeric(MinMLE))
    assert_that(MinMLE >= 0 & MinMLE <= 1)
    assert_that(is.numeric(MaxLE))
    assert_that(is.numeric(MinBirthKnown))
    assert_that(MinBirthKnown <= 1,
                msg ='MinBirthKnown must be a proportion, so between 0 and 1')
    assert_that(is.numeric(niter))
    assert_that(niter > 0)
    assert_that(is.numeric(burnin))
    assert_that(burnin > 0)
    assert_that(burnin < niter)
    assert_that(is.numeric(thinning))
    assert_that(thinning > 0)
    assert_that(thinning < niter)
    assert_that(is.numeric(nchain))
    assert_that(nchain > 0)
    assert_that(is.numeric(ncpus))
    assert_that(ncpus > 0)
    assert_that(is.character(ModelsSur))
    assert_that(all(ModelsSur %in% c("GO", "EX", "LO", "WE")))
    assert_that(is.character(Shape))
    assert_that(all(Shape %in% c("simple", "bathtub", "Makeham")))
  }
  
  if("rep" %in% Sections){
    assert_that(all(RepSect %in% c("agemat", "litter")))
    assert_that(is.numeric(ParentPercDam))
    assert_that(ParentPercDam > 0)
    assert_that(is.numeric(ParentPercSire))
    assert_that(ParentPercSire > 0)
    assert_that(is.numeric(MinNRepro))
    assert_that(MinNRepro > 0)
    assert_that(is.numeric(MinNPaRepro))
    assert_that(MinNPaRepro > 0)
    assert_that(is.numeric(MinNLitter))
    assert_that(MinNLitter > 0)
    assert_that(is.numeric( MinNSeas))
    assert_that( MinNSeas > 0)
    assert_that(is.numeric( NDay))
    assert_that( NDay >= 0)
  }
  
  if("gro" %in% Sections){
    assert_that(is.numeric(MinNIGro))
    assert_that(MinNIGro > 0)
    assert_that(is.numeric(MinNGro))
    assert_that(MinNGro > 0)
    assert_that(is.character(MeasureType))
    assert_that(is.character(ModelsGro))
    assert_that(all(ModelsGro %in% c("logistic", "gompertz", "chapmanRichards",
                                     "vonBertalanffy", "polynomial", "gam")),
                msg = "The growth models supported are: logistic, gompertz, 
                chapmanRichards, vonBertalanffy, and polynomial, in addition to GAM.")
  }
  
  assert_that(is.character(SexCats))
  assert_that(all(SexCats %in% c("Male", "Female", "All")))
  
  
  
  # Load data ------------------------------------------------------------------------
  cat("Loading Data\n")
  tables = c("Collection")
  if("sur" %in% Sections){
    tables = c(tables, "DeathInformation")
  }
  if("gro" %in% Sections){
    tables = c(tables, "Weight")
  }
  if("rep" %in% Sections){
    tables = c(tables, "Parent", "Contraception", "Move")
  }
  Species_List = list()
  Species_List[[Taxa]] = SpeciesList
  data <- Load_Zimsdata	(Taxa = Taxa, ZIMSDir = ZIMSDir, 
                         Species = Species_List,
                         Animal = TRUE,
                         tables = tables,
                         silent = TRUE) 
  
  # Species List -------------------------------------------------------------------
  if(all(SpeciesList == "All")){
    spAll <- unique(data[[Taxa]]$Animal$binSpecies)%>%
      stringr::str_subset(pattern = ' sp.', negate = TRUE)
  }else{
    spAll <-SpeciesList
  }
  if (InParallel){
    # IDs of species to run per version:
    idsprun <- seq(ipara, length(spAll), by = npara)
  }else{
    idsprun <- c(1:length(spAll))}
  
  
  # RUN ANALYSES-------------------------------------------------------------------
  core <- Prep_Animal(data[[Taxa]]$Animal, 
                      ExtractDate = ExtractDate, 
                      MinBirthDate = MinBirthDate)
  # #subset Tables
  if("sur" %in% Sections){
    DeathInformation <- data[[Taxa]]$DeathInformation
  }else{DeathInformation <- NULL}
  if("gro" %in% Sections){
    weights = data[[Taxa]]$Weight
  }else{
    weights <-NULL
  }
  if("rep" %in% Sections){
    parents = data[[Taxa]]$Parent
    move = data[[Taxa]]$Move
    contraceptions = data[[Taxa]]$Contraception
  }else{
    parents =contraceptions = move = NULL
  }
  
  # Start counter:
  icount <- 0
  # Loop over species
  for (isp in idsprun) {
    # Extract species:
    species <- spAll[isp]
    # progress count:
    icount <- icount + 1
    
    # Report progress:
    cat("\n====================\nClass:   ", Taxa, "\nSpecies: ", species, 
        "\nProgress:", round(icount / length(idsprun) * 100, 0), 
        "%\n=====================\n")
    cat("Species running...\n ")
    
    speciesname = stringr::str_replace(species, " ", "_")
    
    #Load previous taxon profile to update it
    if(ErasePrevious){
      repout = list()
    }else{
      if(length(list.files(glue::glue("{AnalysisDir}/Rdata/"), glue::glue("{Taxa}_{speciesname}.RData")))>0){
        load(glue::glue("{AnalysisDir}/Rdata/{Taxa}_{speciesname}.RData"))
      }else{repout = list()}
    }
    if (species %in% spOutLev) {MaxOutl1 <- 99.9
    }else{MaxOutl1 <- MaxOutl}
    
    
    # Create report:
    repout <- tx_report(species, Taxa, 
                        Animal =  core, Collection = data[[Taxa]]$Collection, 
                        DeathInformation = DeathInformation,
                        PlotDir = PlotDir, ExtractDate= ExtractDate, 
                        MinBirthDate = MinBirthDate,
                        Weights = weights, Parents = parents,
                        Contraceptions = contraceptions, Move = move,
                        repout = repout, Sections = Sections, 
                        BirthType = BirthType,
                        SexCats = SexCats, MinN= MinN, 
                        MinDate= MinDate, Global = Global,
                        UncertBirth = UncertBirth, UncertDeath= UncertDeath,
                        UncertDate = UncertDate,MinAge =MinAge,
                        MaxOutl = MaxOutl1, MinLx = MinLx, 
                        MinInstitution = MinInstitution,
                        MinNSur = MinNSur, MaxNSur = MaxNSur, 
                        MinBirthKnown = MinBirthKnown,
                        MinMLE = MinMLE, MaxLE =  MaxLE,MaxAge = MaxAge,
                        ModelsSur = ModelsSur, Shape = Shape,
                        LastDead = LastDead,
                        niter = niter, burnin =  burnin, thinning = thinning,
                        nchain = nchain,  ncpus = ncpus,
                        RepSect = RepSect, ParentPercDam = ParentPercDam,
                        ParentPercSire = ParentPercSire, MinNRepro = MinNRepro,
                        MinNLitter = MinNLitter, NDay = NDay,
                        MinNPaRepro = MinNPaRepro, MinNSeas = MinNSeas, 
                        MinNGro =MinNGro,MinNIGro = MinNIGro, 
                        MeasureType = MeasureType, ModelsGro = ModelsGro
    )
    
    # Save results ------------------------------------------------------------------
    # Save species list:
    save("repout", file = glue::glue("{AnalysisDir}/Rdata/{Taxa}_{speciesname}.RData"))
    cat(" done.\n")
  }
}

