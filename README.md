
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ISRverse

<!-- badges: start -->

[![R-CMD-check](https://github.com/fplard/ISRverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/fplard/ISRverse/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/fplard/ISRverse/branch/master/graph/badge.svg)](https://app.codecov.io/gh/fplard/ISRverse?branch=master)
<!-- badges: end -->

ISRverse can be used to run taxon profiles for Species360. It proposes
tools to :

- Load Zims data
- Run the main demographic analyses: survival, reproduction and growth
  models
- Run the taxon profile analyses

## Installation

First you will need install paramDemo on your computer from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
# library(devtools)
install_git("https://github.com/fercol/paramDemo", subdir = "pkg/")
```

You can install the development version of ISRverse from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fplard/ISRverse")
```

## Documentation

Full documentation website on: <https://fplard.github.io/ISRverse>

You can also open the documentation locally on your machine using

``` r
path <- system.file("site", "index.html", package = "ISRverse")
browseURL(path)
```

## Set up your Rstudio environnement

Use the correct directories to find data and run the analyses

#### On your own computer

``` r
library(glue)
# Path to the ZIMSdata directory:
ZIMSDir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/"

ZIMSDirdata <- glue ("{ZIMSDir}Data")
AnalysisDir <- glue ("{ZIMSDir}Analyses/")

# directory to save Rdata:
RdataDir <-  glue ("{AnalysisDir}Rdata/")
# Plot directory:
PlotDir <- glue ("{ZIMSDir}Plot")

setwd(AnalysisDir)
library(ISRverse)
library(tidyverse)
```

#### On Ucloud

``` r

# Install libraries:
instPacks <- installed.packages()[, 1]
if (!"snowfall" %in% instPacks) {
  install.packages("snowfall")
}
if (!"rjson" %in% instPacks) {
  install.packages("rjson")
}
if (!"ggpubr" %in% instPacks) {
  install.packages("ggpubr")
}
if (!"bbmle" %in% instPacks) {
  install.packages("bbmle")
}
if (!"BasTA" %in% instPacks) {
  install.packages("BaSTA")
}
if (!"assertthat" %in% instPacks) {
  install.packages("assertthat")
}
if (!"glue" %in% instPacks) {
  install.packages("glue")
}
if (!"checkmate" %in% instPacks) {
  install.packages("checkmate")
}

if (!"paramDemo" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/paramDemo_1.0.0.tar.gz",
                   type = "source", repos = NULL)
}
if (!"ISRverse" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/ISRverse_0.0.0.9000.tar.gz", 
                   type = "source", repos = NULL)
}
library(glue)

# ZIMS directory where to find data:
ZIMSDirdata <- "/work/Species360/ZIMSdata_ext240829"

# General directory:
AnalysisDir <- glue ("/work/Species360/Demo_Analyses/")

# directory to save Rdata:
RdataDir <-  glue ("{AnalysisDir}Rdata/")
# Plot directory:
PlotDir <- glue ("{AnalysisDir}Plot/")

# Download the needed libraries
library(ISRverse)
library(tidyverse)
```

## Split Science extract per taxa

DO NOT DO THAT IN MOST CASES

To be done !!!!!ONLY ONCE!!!! after the download of the science extract.
This function will load the science extract and: \* split it by taxa \*
select only “Individual” for Animal Type \* add binSpecies name \*
weights and lengths: check that measurement are \> 0, add the following
columns: Age in years, UnitOfMeasure and MeasurementValue

``` r
# Path to the ZIMSdata directory:
ExtractDate ="2024-08-29"
Split_Zimsdata  (ZIMSDir = ZIMSDirdata, ExtractDate = ExtractDate) 
```

## Tutorial for survival

``` r
ExtractDate ="2024-08-29"
Taxa = "Mammalia"
List_species = list(Mammalia = c("Capra sibirica", "Cuon alpinus", "Nanger granti"))

#Filters -----------------------------------------------------------------------
# Earliest date to include records
MinDate <- "1980-01-01"
# Earliest birth date to include records
MinBirthDate <- "1900-01-01"
# Whether to include only Global individuals
Global = TRUE
# Birth Type of Animals: "Captive", "Wild" or "All"
BirthType = "Captive"
# Minimum number of individuals to run the taxon profile
MinN <- 50
# Maximum threshold in the longevity distribution to use
MaxOutl <- 99 
# Minimum number of Institutions that hold individuals from one species
MinInstitution = 2 
# Maximum uncertainty accepted for birth dates, in days
UncertBirth = 365
# Maximum uncertainty accepted for death dates, in days
UncertDeath = 365
# Maximum possible age
MaxAge = 120
# Age when to start the analysis
MinAge = 0


# Survival Models ------------------------------------------------------------
# Survival Models to run: "GO", "LO", "EX" or/and "WE"
ModelsSur <- c("GO", "LO")
# Shape of the survival model: "simple", "bathtub" or "Makeham"
Shape = "bathtub"

# Number of CPUS:
ncpus <- 4
# MCMC settings:
niter <- 10000
burnin <- 3001
thinning <- 20
nchain <- 3

# Conditions to run the survival analysis
MinNSur = 50 #Minimum number of individuals
MaxNSur = 1000 #Maximum number of individuals
MinLx = 0.1  #Minimum survivorship reach by life table (Kaplan-Meier estimator)
MinBirthKnown = 0.3 #Minimum proportions of known birth dates (within a month)
#Goodness of fit
MinMLE = 0.1 #Minimum survivorship at Mean life expectancy
MaxLE = 2     #Maximum remaining life expectancy at max age

# Table with species that require rerruning with higher outlier level:
MaxOutlev <- read.csv(glue("{AnalysisDir}MaxOutlierLevel.csv"), header = TRUE,
                      stringsAsFactors = FALSE)
spOutLev <- MaxOutlev$Specie

#Load Data -----------------------------------------------------------------------
Data <- Load_Zimsdata(Taxa = Taxa, ZIMSDir = ZIMSDirdata, 
                      species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', 'DeathInformation')) 
Animal <- Prep_Animal(Data[[Taxa]]$Animal, ExtractDate = lubridate::as_date("2024/08/29"))

# Run survival Analysis---------------------------------------------------------
## Loop over species
for (species in List_species[[Taxa]]){
  print(species)
  if (species %in% spOutLev) {MaxOutl1 <- 99.9
  }else{MaxOutl1 <- MaxOutl}
  Dataspe <- select_species(Species, Animal, Data[[Taxa]]$Collection, UncertBirth = UncertBirth,
                            BirthType = BirthType,
                            MinDate = MinDate , ExtractDate = ExtractDate,
                            Global = Global) 
  if(nrow(Dataspe$data)>0){
    out = list()
    ## Loop over sexes
    for (sx in c("Male", "Female")){
      print(sx)
      #Check for gaps in longevity distribution to define a threshold 
      #after which individuals will be deleted (possible outiers or errors in data)
      sexDat <- select_Longthreshold( Dataspe$data,  SexCats = sx, 
                                      PlotDir= glue::glue("{PlotDir}test2/"),
                                      MinN = MinN ,
                                      PlotName = glue::glue("{Taxa}_{species}_{sx}") )
      OutlLev1 = min(sexDat$summar$GapThresh,MaxOutl, na.rm = T)
      
      
      if(nrow(sexDat$data)>0){ 
        out[[sx]] <-  Sur_main(DataCore = sexDat$data,  DeathInformation =  Data[[Taxa]]$DeathInformation,
                               BirthType = BirthType, LastDead = T,
                               PlotDir = glue::glue("{PlotDir}test2/"),
                               MaxAge = MaxAge,
                               models = ModelsSur, Shape= Shape, 
                               OutlLev1 =OutlLev1,
                               MinMLE = MinMLE, MaxLE =  MaxLE,
                               MinDate = MinDate, MinNSur = MinNSur, MaxNSur = MaxNSur, 
                               MinInstitution = MinInstitution,UncertDeath= UncertDeath,
                               MinLx = MinLx , MinBirthKnown = MinBirthKnown, 
                               niter = niter, burnin = burnin, thinning = thinning, nchain = nchain, 
                               ncpus = ncpus, PlotName = glue("{Taxa}_{species}_{sx}") )
        print(out$summary$error)
      }
    }
  }
}

#Plot predictions and fit from Basta survival model
plot(out$bastaRes, plot.type = 'gof')
```

## Tutorial for reproduction

### Litter size

``` r
ExtractDate ="2024-08-29"
MinDate = "1980-01-01"
Global = TRUE

Taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Panthera onca","Panthera uncia", "Panthera tigris", "Panthera pardus"))

#Filters ------------------------------------------------------------------------
# Conditions to run the reproduction analyses
UncertBirth = 365  #Maximum uncertainty accepted for birth dates, in days
UncertDeath = 10000 #Maximum uncertainty accepted for death dates, in days
MinNRepro = 100   #Minimum number of birth records
MinNPaRepro = 30  #Minimum number of unique parent records
MinNLitter = 30 #Minimum number of litter sizes
ParentPercDam = 80 #Minimum parentage probability for Dam
ParentPercSire = 80 #Minimum parentage probability for Sire
NDay = 7  #Group all offspring born within this interval of days in one litter
BirthType = "All"

#Load Data -----------------------------------------------------------------------
Data <- Load_Zimsdata(Taxa = Taxa, ZIMSDir = ZIMSDirdata, 
                      Species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[Taxa]]$Animal, ExtractDate = lubridate::as_date("2024/08/29"))

# Run Reproduction Analysis---------------------------------------------------------
## Loop over species
TAB = tibble()
for (species in List_species[[Taxa]]){
  print(species)
  Dataspe <- select_species(species, Animal, Data[[Taxa]]$Collection, UncertBirth = UncertBirth,
                            BirthType = BirthType,
                            MinDate = MinDate , ExtractDate = ExtractDate,
                            Global = Global) 
  
  #prepare Reproduction data
  Datarep <- Rep_prepdata(Dataspe$data, 
                          Data[[Taxa]]$Collection, Data[[Taxa]]$Parent, Data[[Taxa]]$Move,
                          BirthType_parent = "Captive", BirthType_offspring = "Captive",
                          MinNrepro = MinNRepro, MinNparepro = MinNPaRepro, Global = Global)
  if(nrow(Datarep$Reprodata)>0){
    #Litter size Analysis
    out <- Rep_littersize(Datarep$Reprodata, 
                          NDay = NDay, ParentPercDam = ParentPercDam,
                          ParentPercSire = ParentPercSire,  
                          MinNLitter = MinNLitter)
    
    df = out$littSizeDf%>%mutate(Species = species)
    
    TAB <- rbind(TAB, df)
  }
}

TAB
```

### Age at first reproduction

``` r
ExtractDate ="2024-08-29"
MinDate = "1980-01-01"
Global = TRUE

Taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Alces alces","Lasiurus cinereus", "Gorilla gorilla"))

#Filters ------------------------------------------------------------------------
# Conditions to run the reproduction analyses
UncertBirth = 365  #Maximum uncertainty accepted for birth dates, in days
MinNRepro = 100   #Minimum number of birth records
MinNPaRepro = 30  #Minimum number of unique parent records

#Load Data -----------------------------------------------------------------------
Data <- Load_Zimsdata(Taxa = Taxa, ZIMSDir = ZIMSDirdata, 
                      Species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[Taxa]]$Animal, ExtractDate = lubridate::as_date("2024/08/29"))

# Run Reproduction Analysis---------------------------------------------------------
## Loop over species
TAB = tibble()
for (species in List_species[[Taxa]]){
  print(species)
  Dataspe <- select_species(species, Animal, Data[[Taxa]]$Collection, UncertBirth = UncertBirth,
                            BirthType = BirthType,UncertDeath= UncertDeath,
                            MinDate = MinDate , ExtractDate = ExtractDate,
                            Global = Global) 
  if(nrow(Dataspe$data)>0){
    for (sx in c("Male", "Female", "All")){
      print(sx)
      if(sx != "All"){
        coresubset <- Dataspe$data%>%filter(SexType == sx)
      }else{coresubset <- Dataspe$data}
      if(nrow(coresubset)>0){
        #prepare Reproduction data
        Datarep <- Rep_prepdata(coresubset = coresubset, 
                                Data[[Taxa]]$Collection, Data[[Taxa]]$Parent, Data[[Taxa]]$Move,
                                BirthType_parent = "Captive", BirthType_offspring = "Captive",
                                MinNrepro = MinNRepro, MinNparepro = MinNPaRepro, Global = Global)
        if(nrow(Datarep$Reprodata)>0){
          #Calculate reproductive age statistics
          out <- Rep_agemat(Datarep$Reprodata)%>%
            mutate(Species = species,
                   Class = Taxa,
                   Sex = sx)
          
          TAB <- rbind(TAB, out)
        }
      }
    }
  }
}

TAB
```

## Tutorial for growth

### Outliers

``` r
#Directory where to save results
SaveDir = glue ("{AnalysisDir}savegrowth")
PlotDir = glue ("{AnalysisDir}plotgrowth")
ExtractDate ="2024-08-29"


Taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Panthera onca","Panthera uncia", "Panthera tigris", "Panthera pardus"))

c# Earliest date to include records
MinDate <- "1980-01-01"
# Earliest birth date to include records
MinBirthDate <- "1900-01-01"
#Whether to include only Global individuals
Global = TRUE
#Birth Type of Animals: "Captive", "Wild" or "All"
BirthType = "Captive"
#Maximum uncertainty accepted for birth dates, in days
UncertBirth = 365
#Maximum uncertainty accepted for measurement dates: weight, in days
UncertDate = 365

# Measure type to select
MeasureType = "Live weight"

# Conditions to estimate age at sexual maturity
MinNRepro = 100   #Minimum number of birth records
MinNPaRepro = 30  #Minimum number of unique parent records

#Load Data -----------------------------------------------------------------------
Data <- Load_Zimsdata(Taxa = Taxa, ZIMSDir = ZIMSDirdata, 
                      Species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', "Weight", 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[Taxa]]$Animal, ExtractDate = ExtractDate, MinBirthDate =MinBirthDate)


#Choose Species and sex ----------------------------------------------------------------
species = List_species[[Taxa]][1]
sx = "All" #can also be "Female" or "Male"

Dataspe <- select_species(species, Animal, Data[[Taxa]]$Collection, UncertBirth = UncertBirth,
                          BirthType = BirthType,UncertDeath= 3600,
                          MinDate = MinDate , ExtractDate = ExtractDate,
                          Global = Global) 

# Run outlier analysis-----------------------------------------------------------
if(nrow(Dataspe$data)>0){
  repr = list()
  if(sx != "All"){
    coresubset <- Dataspe$data%>%filter(SexType == sx)
  }else{coresubset <- Dataspe$data}
  if(nrow(coresubset)>0){
    #Estimate age at sexual maturity
    repr[[sx]] <- Rep_main(coresubset= coresubset, Data[[Taxa]]$Collection, 
                           Data[[Taxa]]$Parent, Data[[Taxa]]$Move,  
                           Repsect = "agemat",
                           BirthType_parent = BirthType, BirthType_offspring = BirthType, 
                           Global = Global, 
                           MinNRepro = MinNRepro, MinNPaRepro =  MinNPaRepro
    )
    
    agemat = NULL
    if(length(repr[[sx]])>0){
      if(repr[[sx]]$summary$amat_analyzed){
        agemat =repr[[sx]]$agemat$ageMat
      }
    }
    
    #Clean measures
    ouput <- Gro_cleanmeasures(data = Data[[Taxa]]$Weight, coresubse = coresubset,
                               BirthType = BirthType, type ="weight", 
                               UncertDate = UncertDate,
                               MeasureType = MeasureType,
                               MinDate = MinDate)
    #Look for outliers
    if(nrow(ouput$data)>0){
      data_weight <- ouput$data%>%
        Gro_remoutliers (Taxa = Taxa, AgeMat = agemat, maxweight = NULL, 
                         variableid = "AnimalAnonID", min_Nmeasures = 7,
                         perc_weight_min=0.2, perc_weight_max=2.5,
                         IQR=2.75, minq=0.025, Ninterval_juv = 10)
      
      #plot outliers: Look at ?Gro_outplot to understand the different colors
      if(!is.null(PlotDir)){
        p1 <-Gro_outplot(data_weight, title = glue("{species} {sx}"), ylimit = NULL, xlimit = NULL)
        ggsave(p1, filename = glue("{PlotDir}/{species}_{sx}_outliers.png"), height = 6, width = 6)
      }
      
    }
  }
}      
```

### Growth models

``` r
#Directory where to save results
SaveDir = glue ("{AnalysisDir}savegrowth")
PlotDir = glue ("{AnalysisDir}plotgrowth")
ExtractDate ="2024-08-29"

Taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Panthera onca","Panthera uncia", "Panthera tigris", "Panthera pardus"))
SexCats = c("Female", "Male", "All")

#Load Data -----------------------------------------------------------------------
# Earliest date to include records
MinDate <- "1980-01-01"
# Earliest birth date to include records
MinBirthDate <- "1900-01-01"
#Whether to include only Global individuals
Global = TRUE
#Birth Type of Animals: "Captive", "Wild" or "All"
BirthType = "Captive"
# Maximum threshold in the longevity distribution to use
MaxOutl <- 99 
#Maximum uncertainty accepted for birth dates, in days
UncertBirth = 365
#Maximum uncertainty accepted for measurement dates: weight, in days
UncertDate = 365

#Models: "logistic", "gompertz", "chapmanRichards", "vonBertalanffy", "gam", and/or "polynomial"
ModelsGro <- c("vonBertalanffy", "gompertz") 

# Measure type to select
MeasureType = "Live weight"
# Conditions to run the growth analysis
MinNGro = 100 #Minimum number of weights
MinNIGro = 50 #Minimum number of individuals

# Conditions to estimate age at sexual maturity
MinNRepro = 100   #Minimum number of birth records
MinNPaRepro = 30  #Minimum number of unique parent records

#Load Data -----------------------------------------------------------------------
Data <- Load_Zimsdata(Taxa = Taxa, ZIMSDir = ZIMSDirdata, 
                      species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', "Weight", 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[Taxa]]$Animal, ExtractDate = ExtractDate, MinBirthDate =MinBirthDate)

# Run Growth Analysis---------------------------------------------------------
## Loop over species
for (species in List_species[[Taxa]]){
  print(species)
  Dataspe <- select_species(species, Animal, Data[[Taxa]]$Collection, UncertBirth = UncertBirth,
                            BirthType = BirthType,UncertDeath= UncertDeath,
                            MinDate = MinDate , ExtractDate = ExtractDate,
                            Global = Global) 
  
  if(nrow(Dataspe$data)>0){
    repr = weig = list()
    for (sx in SexCats){
      cat(paste0(" ****************************  ",sx,"  ****************************\n"))
      if(sx != "All"){
        coresubset <- Dataspe$data%>%filter(SexType == sx)
      }else{coresubset <- Dataspe$data}
      if(nrow(coresubset)>0){
        #Estimate age at sexual maturity
        repr[[sx]] <- Rep_main(coresubset= coresubset, Data[[Taxa]]$Collection, 
                               Data[[Taxa]]$Parent, Data[[Taxa]]$Move,  
                               Repsect = "agemat",
                               BirthType_parent = BirthType, BirthType_offspring = BirthType, 
                               Global = Global, 
                               MinNRepro = MinNRepro, MinNPaRepro =  MinNPaRepro
        )
        
        agemat = NULL
        if(length(repr[[sx]])>0){
          if(repr[[sx]]$summary$amat_analyzed){
            agemat =repr[[sx]]$agemat$ageMat
          }
        }
        #Run growth model
        weig[[sx]] <- Gro_Main(data = Data[[Taxa]]$Weight, coresubse = coresubset,
                               Taxa = Taxa, species = species,
                               BirthType = BirthType, 
                               agemat = agemat, percentiles = c(2.5,97.5),
                               PlotDir = PlotDir, type = "weight",
                               UncertDate = UncertDate,
                               MeasureType = MeasureType,
                               MinNGro = MinNGro, MinNIGro = MinNIGro, 
                               models = ModelsGro,
                               MinDate = MinDate, PlotName = glue("{species}_{sx}") )
        
      }
    }
    save(weig, file = glue("{SaveDir}/{species}_growth.Rdata"))   
  }      
  }
```

## Tutorial to run Taxon profiles

### Choose important arguments

``` r
# Data -------------------------------------------------------------------------
ExtractDate = "2024-08-29"

# List of taxa to analyze -------------------------------------------------------
TaxaList <- c("Mammalia", "Aves", "Reptilia", "Amphibia", 
              "Chondrichthyes", "Osteichthyes")

# Sex categories -----------------------------------------------------------------
BySex <- list(Mammalia = c("Male", "Female", "All"), 
              Aves = c("Male", "Female", "All"), 
              Reptilia = c("Male", "Female", "All"), 
              Amphibia = c("Male", "Female", "All"), 
              Chondrichthyes = c("Male", "Female", "All"), 
              Osteichthyes = c("Male", "Female", "All"))


#Filters -------------------------------------------------------------------------
# Earliest date to include records
MinDate <- "1980-01-01"
# Earliest birth date to include records
MinBirthDate <- "1900-01-01"
#Whether to include only Global individuals
Global = TRUE
#Birth Type of Animals: "Captive", "Wild" or "All"
BirthType = "Captive"
# Minimum number of individuals to run the taxon profile
MinN <- 50
# Maximum threshold in the longevity distribution to use
MaxOutl <- 99 
# Minimum number of Institutions that hold individuals from one species
MinInstitution = 2 
# Maximum uncertainty accepted for birth dates, in days
UncertBirth = 365
# Maximum uncertainty accepted for death dates, in days
UncertDeath = 365
# Maximum uncertainty accepted for measurement dates: weight, in days
UncertDate = 365

# Maximum possible age
MaxAge = 120

# Age when to start the analysis
MinAge =0
# Whether the oldest individuals should be considered as dead by the model
LastDead = FALSE


# Survival Models --------------------------------------------------------------------
# Survival Models to run: "GO", "LO", "EX" or/and "WE"
ModelsSur <- c("GO", "LO")
#Shape of the survival model: "simple", "bathtub" or "Makeham"
Shape = "bathtub"

# Number of CPUS:
ncpus <- 4

# MCMC settings:
niter <- 10000
burnin <- 3001
thinning <- 20
nchain <- 3

# Conditions to run the survival analysis
MinNSur = 50 #Minimum number of individuals
MaxNSur = 1000 #Maximum number of individuals
MinLx = 0.1  #Minimum survivorship reach by raw life table
MinBirthKnown = 0.3 #Minimum proportions of known birth date (within a month)

#Goodness of fit
MinMLE = 0.1 #Minimum survivorship at Mean life expectancy
MaxLE = 2     #Maximum remaining life expectancy at max age


# Reproduction Models -----------------------------------------------------------
# Reproductive Analyses to run: "agemat" or/and "litter"
Repsect = c('agemat', 'litter')

# Conditions to run the reproduction analyses
MinNRepro = 100   #Minimum number of birth records
MinNPaRepro = 30  #Minimum number of unique parent records

#Litter/clutch size
ParentPercDam = 80 #Minimum percentage of parentage probability to include for Dam in litter size
ParentPercSire = 80 #Minimum percentage of parentage probability to include for Sire in litter size
MinNLitter = 30 #Minimum number of litters to run the analysis
NDay = 7 #Number of days to group all offspring in one litter/clutch

#Seasonnality
MinNseas = 50  #Minimum number of births to run the seasonnality analysis

# Growth Models -----------------------------------------------------------------
#Models: "logistic", "gompertz", "chapmanRichards", "vonBertalanffy", and/or "polynomial"
ModelsGro <- c("vonBertalanffy", "gam") 

# Measure type to select
MeasureType = "Live weight"

# Conditions to run the growth analysis
MinNGro = 100 #Minimum number of weights
MinNIGro = 30 #Minimum number of individuals
```

### Other Inputs

``` r
# Table with species that require rerruning with higher outlier level:
MaxOutlev <- read.csv(glue("{AnalysisDir}MaxOutlierLevel.csv"), header = TRUE,
                      stringsAsFactors = FALSE)
spOutLev <- MaxOutlev$Specie
```

### Run taxon profiles by taxa

You cannot run all taxa at once due to the computational resources
needed. But you can choose to run per taxa (option 1) or you can also
separate species for each taxa to run it in parallel on different
computer (option 2)

For all options, you can choose which analysis to run using the argument
`Sections` giving the name of the sections to run/update in the taxon
profile results: “sur”, “rep” and/or “gro”

#### Option 1: Run all species of one taxa

``` r
#Sections to run or to update
Sections = c("sur", "rep", "gro")
Sections = c("sur")

run_txprofile (TaxaList[Taxa], Species_list = "All", ZIMSDirdata, 
               AnalysisDir = AnalysisDir, PlotDir = PlotDir,
               Sections = Sections, ErasePrevious = FALSE,
               ExtractDate = ExtractDate, MinDate = MinDate,
               SexCats = BySex[[TaxaList[Taxa]]], 
               MinN = MinN,  Global =  Global,
               MaxOutl = MaxOutl,  spOutLev = spOutLev, BirthType = BirthType, 
               UncertBirth = UncertBirth, UncertDeath= UncertDeath,
               UncertDate = UncertDate,
               MinInstitution = MinInstitution, 
               MinNSur = MinNSur, MaxNSur = MaxNSur, MaxAge = MaxAge,
               MinLx = MinLx, MinBirthKnown = MinBirthKnown, 
               MinMLE = MinMLE, MaxLE =  MaxLE,
               ModelsSur = ModelsSur, Shape = Shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, MinNRepro = MinNRepro, 
               MinNPaRepro = MinNPaRepro, MinNseas = MinNseas, 
               MinNLitter = MinNLitter, NDay = NDay, 
               MinNGro = MinNGro, MinNIGro = MinNIGro, MeasureType = MeasureType,
               ModelsGro = ModelsGro
)
```

#### Option 2: Run one or a group of species from one taxa

``` r
list_surv= readxl::read_xlsx(glue("{AnalysisDir}Liste_Survival.xlsx"), sheet =1)%>%
  filter(Class == "Mammalia")%>%
  pull(Species)%>%unique()

Taxa <- 4
#Sections to run or to update
Sections = c("sur")
# Species_list =list_surv
Species_list =c("Panthera onca", "Loris_tardigradus", "Pteropus_livingstonii")


run_txprofile (Taxa = TaxaList[Taxa], 
               ZIMSDir =ZIMSDirdata,AnalysisDir = AnalysisDir, PlotDir = PlotDir,
               ErasePrevious = FALSE,    inparallel = FALSE,
               BirthType = BirthType, 
               SexCats = BySex[[TaxaList[Taxa]]],
               Species_list = Species_list,  Sections = Sections,  
               ExtractDate = ExtractDate, MinDate = MinDate, 
               MinAge = MinAge, LastDead =LastDead,
               MinBirthDate = MinBirthDate, MinN = MinN,  Global =  Global,
               MaxOutl = MaxOutl,  spOutLev = spOutLev, 
               UncertBirth = UncertBirth, UncertDeath= UncertDeath,
               UncertDate = UncertDate,
               MinInstitution = MinInstitution, 
               MinNSur = MinNSur, MaxNSur = MaxNSur, MaxAge = MaxAge,
               MinLx = MinLx, MinBirthKnown = MinBirthKnown, 
               MinMLE = MinMLE, MaxLE =  MaxLE,
               ModelsSur = ModelsSur, Shape = Shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               ParentPercDam = ParentPercDam, ParentPercSire = ParentPercSire, 
               MinNRepro = MinNRepro, 
               MinNPaRepro = MinNPaRepro, MinNseas = MinNseas, 
               MinNLitter = MinNLitter, NDay = NDay, 
               MinNGro = MinNGro, MinNIGro = MinNIGro, MeasureType = MeasureType,
               ModelsGro = ModelsGro
)
```

#### Option 3: Run all species from one taxa in parallel on different computers

``` r
# for example on the first computer:
ipara = 1


Taxa = 2
#Run this code changing ipara on each different computer
XX = 5
#Sections to run or to update
Sections = c("sur", "rep", "gro")
#Number of different computers

run_txprofile (TaxaList[Taxa], Species_list = "All", ZIMSDirdata, 
               inparallel = TRUE, ipara = ipara, npara = XX, 
               AnalysisDir = AnalysisDir, PlotDir = PlotDir,
               Sections = Sections, ErasePrevious = FALSE,
               MinAge = MinAge, LastDead =LastDead,
               ExtractDate = ExtractDate, MinDate = MinDate,
               SexCats = BySex[[TaxaList[Taxa]]], 
               MinN = MinN,  Global =  Global,
               MaxOutl = MaxOutl,  spOutLev = spOutLev, BirthType = BirthType, 
               UncertBirth = UncertBirth, UncertDeath= UncertDeath,
               UncertDate = UncertDate,
               MinInstitution = MinInstitution, 
               MinNSur = MinNSur, MaxNSur = MaxNSur, MaxAge = MaxAge,
               MinLx = MinLx, MinBirthKnown = MinBirthKnown, 
               MinMLE = MinMLE, MaxLE =  MaxLE,
               ModelsSur = ModelsSur, Shape = Shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               ParentPercSire =  ParentPercSire,
               ParentPercDam =  ParentPercDam,
               MinNRepro = MinNRepro, 
               MinNPaRepro = MinNPaRepro, MinNseas = MinNseas, 
               MinNLitter = MinNLitter, NDay = NDay, 
               MinNGro = MinNGro, MinNIGro = MinNIGro, MeasureType = MeasureType,
               ModelsGro = ModelsGro
               
)
save(ipara, file = glue("{AnalysisDir}/finished_{TaxaList[Taxa]}{ipara}.Rdata"))
```

### Make the summary tables

``` r
# List of taxa to summarize -------------------------
TaxaList <- c("Mammalia", "Aves", "Reptilia", "Amphibia", 
              "Chondrichthyes", "Osteichthyes")

# Sex categories ----------------------------------
BySex <- list(Mammalia = c("Male", "Female", "All"), 
              Aves = c("Male", "Female", "All"), 
              Reptilia = c("Male", "Female", "All"), 
              Amphibia = c("Male", "Female", "All"), 
              Chondrichthyes = c("Male", "Female", "All"), 
              Osteichthyes = c("Male", "Female", "All"))


SummTab <- make_summary2(AnalysisDir=glue("{AnalysisDir}Rdata"), 
                         SaveDir = glue("{AnalysisDir}"),
                         TaxaList = TaxaList,
                         BySex = BySex ,
                         Sections = c("sur"),
                         MinAge = 0
)
```

### Make the output for the Dev Team

``` r
# directory to save Json for the dev team:
JsonDir <-  glue ("{AnalysisDir}Json/")
write(toJSON(repout), file = sprintf("ISRdata/global/json/%s.json", 
                                     repout$general$speciesID))
```

### Compress the output

``` r
system("zip -r Species360/Demo_Analyses/plot2.zip Species360/Demo_Analyses/Plot/")
#> [1] 12
```
