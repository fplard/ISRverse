% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run_txprofile.R
\name{run_txprofile}
\alias{run_txprofile}
\title{Run Taxon Profiles}
\usage{
run_txprofile(
  Taxa,
  SpeciesList,
  ZIMSDir,
  AnalysisDir,
  PlotDir,
  ExtractDate,
  MinDate = "1980-01-01",
  Sections,
  ErasePrevious = FALSE,
  SexCats = c("Male", "Female"),
  MinBirthDate = "1900-01-01",
  InParallel = FALSE,
  ipara = 1,
  npara = 1,
  MinN = 50,
  MaxOutl = 99,
  spOutLev = NULL,
  Global = TRUE,
  UncertBirth = 365,
  UncertDeath = 365,
  UncertDate = 365,
  MinNSur = 50,
  MaxNSur = NULL,
  MinInstitution = 2,
  MinLx = 0.1,
  MinBirthKnown = 0.3,
  MaxAge = 120,
  MinMLE = 0.1,
  MaxLE = 2,
  MinAge = 0,
  ModelsSur = "GO",
  Shape = "bathtub",
  niter = 25000,
  burnin = 5001,
  thinning = 20,
  nchain = 3,
  ncpus = 2,
  RepSect = c("agemat", "litter"),
  BirthType = "Captive",
  LastDead = FALSE,
  ParentPercSire = 80,
  ParentPercDam = 80,
  MinNLitter = 20,
  NDay = 7,
  MinNRepro = 100,
  MinNPaRepro = 30,
  MinNSeas = 50,
  MinNGro = 100,
  MinNIGro = 50,
  MeasureType = "Live weight",
  ModelsGro = "vonBertalanffy"
)
}
\arguments{
\item{Taxa}{\code{character} Name of the taxa studied}

\item{SpeciesList}{\code{vector of character} Species selected}

\item{ZIMSDir}{\code{character} Directory where to find data}

\item{AnalysisDir}{\code{character} Directory where to save results}

\item{PlotDir}{\code{character} Directory to save the plots. Default: no plot is saved}

\item{ExtractDate}{\code{character 'YYYY-MM-DD'} Date of data extraction}

\item{MinDate}{\code{character 'YYYY-MM-DD'} Earliest date to include data}

\item{Sections}{\code{vector of character} Names of the sections to update in the results: "sur", "rep" and/or "gro".}

\item{ErasePrevious}{\code{logical} Whether the current result file should be deleted (before being replaced).}

\item{SexCats}{\code{character} Male, Female or All.}

\item{MinBirthDate}{\code{character}: Earliest possible date: date used when minimum birth or death dates are unknown}

\item{InParallel}{\code{logical} Whether this function is run in parallel on different computers. In other words: should the species list be divided?}

\item{ipara}{\code{numeric} ID number of the computer used}

\item{npara}{\code{numeric} Number of computers used in parallel}

\item{MinN}{\code{numeric} Minimum number of individuals needed to run the analysis.}

\item{MaxOutl}{\code{numeric} Start threshold to select individuals based on the longevity distribution: 100\%, 99.9, 99 or 95\%. This number must decrease when many errors are expected in longevity data.}

\item{spOutLev}{\code{vector of character} List of species for which the Maximum threshold for the longevity distribution is 99.9\% instead of MaxOutl.}

\item{Global}{\code{logical} Whether only individuals belonging to global collections should be used.}

\item{UncertBirth}{\code{numeric}: Maximum uncertainty accepted for birth dates, in days}

\item{UncertDeath}{\code{numeric}: Maximum uncertainty accepted for death dates, in days.}

\item{UncertDate}{\code{numeric}: Maximum uncertainty accepted for measurement dates: weight, in days.}

\item{MinNSur}{\code{numeric} Minimum number of individual records to run the survival analysis.}

\item{MaxNSur}{\code{numeric} Maximum number of individual records to run the survival analysis.}

\item{MinInstitution}{\code{numeric} Minimum number of institutions that should hold records to run the analyses.}

\item{MinLx}{\code{numeric} Value used for longevity threshold and for checks. between 0 and 1. Minimum reached survivorship from the raw Kaplan Meier analysis. This number avoids running survival analysis if there are too few dead individuals in the data. Lower is better.}

\item{MinBirthKnown}{\code{numeric} between 0 and 1. Minimum proportion of individuals with a known birth month in the data.}

\item{MaxAge}{\code{numeric} Maximum possible age in years. Only used for model predictions. This argument is not used to select data.}

\item{MinMLE}{\code{numeric} Value used for checks. Minimum survivorship allowed at mean life expectancy. Between 0 and 1.}

\item{MaxLE}{\code{numeric} Value used for checks. Maximum remaining life expectancy at last observed age. In years.}

\item{MinAge}{\code{numeric} Ages at which the analyses should start.  see ?basta for more information.}

\item{ModelsSur}{\code{vector of characters} names of the survival basta models to run: "G0", "EX", "LO" and/or "WE". see ?basta for more information.}

\item{Shape}{\code{character} Shape of the survival basta model to run: "simple", "Makeham", "bathtub".  see ?basta for more information.}

\item{niter}{\code{numeric}. Number of MCMC iterations to run the survival model. see ?basta for more information.}

\item{burnin}{\code{numeric} Number of iterations removed so that the survival model has time to converge. see ?basta for more information.}

\item{thinning}{\code{numeric} Number of iteration to run the survival model before saving a set of parameters. see ?basta for more information.}

\item{nchain}{\code{numeric} Number of chains to run the survival model.}

\item{ncpus}{\code{numeric} Number of computer core to use.}

\item{RepSect}{\code{character} Names of the reproductive analyses to run: "agemat", "litter" and/or ...}

\item{BirthType}{\code{character} Captive, Wild, or All.}

\item{LastDead}{\code{logical} Whether the longest lived individual should be considered dead.}

\item{ParentPercSire}{\code{numeric} Minimum percentage of parentage probability to include Sire.}

\item{ParentPercDam}{\code{numeric} Minimum percentage of parentage probability to include Dam.}

\item{MinNLitter}{\code{numeric} Minimum number of litters to run the analysis. The data frame for litter size will be produced in all cases.}

\item{NDay}{\code{numeric} Number of consecutive days over which the birth dates of a litter/clutch can be spread}

\item{MinNRepro}{\code{numeric} Minimum number of birth records needed to run reproductive analyses.}

\item{MinNPaRepro}{\code{numeric} Minimum number of unique parent records needed to run reproductive analyses.}

\item{MinNSeas}{\code{numeric} XXXXXXXXXXX}

\item{MinNGro}{\code{numeric} Minimum number of weight needed to fit the growth models}

\item{MinNIGro}{\code{numeric} Minimum number of unique individuals needed to fit the growth models}

\item{MeasureType}{\code{vector of characters} Names of the types of measurement that should be included.  Default: all measurement type are included.}

\item{ModelsGro}{\code{vector of characters} Names the growth models that need to be fit.The following models are supported : logistic, gompertz, chapmanRichards, vonBertalanffy, polynomial. default = "vonBertalanffy"}
}
\value{
Save and replace the result file for each species in the list. The file is saved in {AnalysisDir}/Rdata/{Taxa}_{species}.Rdata
}
\description{
Load data needed and run or update demographic analyses for the list of species selected
}
\examples{
# Here is an example but use directly your own ZIMSDir (directory to find data) 
# and AnalysisDir (directory to save the analysis)
file = system.file("sci_Animal.csv", package = 'ISRverse')
ZIMSDir = dirname(file)
AnalysisDir = paste0(tempdir(check = TRUE),'/temp')
PlotDir = paste0(AnalysisDir,'/plot')
# dir.create(AnalysisDir)
dir.create(paste0(AnalysisDir,'/Rdata'), recursive = TRUE)
dir.create(PlotDir)

#This code run the survival analysis
run_txprofile(Taxa = "Reptilia", SpeciesList = "All",
              ZIMSDir = ZIMSDir, AnalysisDir = AnalysisDir,
              PlotDir = PlotDir,
              ExtractDate = "",
              MinDate = "1980-01-01",
              Sections = c("sur"),
              SexCats = c('Male', 'Female'),
              niter = 1000, burnin = 101, thinning = 10, nchain = 3, ncpus = 3
)

list.files(PlotDir)
list.files(paste0(AnalysisDir,'/Rdata'))

unlink(AnalysisDir, recursive = TRUE)
unlink(PlotDir, recursive = TRUE)
}
