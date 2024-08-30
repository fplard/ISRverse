
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

First you will need install paramDemo from [GitHub](https://github.com/)
with:

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
path <- system.file("docs", "index.html", package = "ISRverse")
browseURL(path)
```

## Split Science extract per taxa

To be done only once after the download of the science extract. This
function will load the science extract and: \* split it by taxa \*
select only “Individual” for Animal Type \* add binSpecies name \*
weights and lengths: check that measurement are \> 0, add the following
columns: Age in years, UnitOfMeasure and MeasurementValue

``` r
# CHANGE THIS to Path to the ZIMSdata directory: 
ZIMSdirtest = "C:/Users/flopy/Documents/ISR/TaxonProfiles/Data"
Split_Zimsdata  (ZIMSdir = ZIMSdirtest) 
```

## Run demographic analyses

### 

## Tutorial for reproduction

### Litter size

``` r
library(tidyverse)
library(ISRverse)
library(glue)

# CHANGE THIS to Path to the ZIMSdata directory: 
ZIMSdir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/Data"
extractDate = "2024-08-30"
minDate = "1980-01-01"
Global = TRUE

taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Panthera onca","Panthera uncia", "Panthera tigris", "Panthera pardus"))

# Conditions to run the reproduction analyses
uncert_birth = 365  #Maximum uncertainty accepted for birth dates, in days
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records
minNlitter = 30 #Minimum number of litter sizes
parentProb = 80 #Minimum parentage probability
Nday = 7  #Group all offspring born within this interval of days in one litter

Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdir, 
                      species = List_species,
            Animal = TRUE,
              tables= c('Collection', 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = lubridate::as_date("2023/12/23"))
  
TAB = tibble()
for (species in List_species[[taxa]]){
  print(species)
  Dataspe <- select_species(species, Animal, Data[[taxa]]$Collection, uncert_birth = uncert_birth,
                         minDate = minDate , extractDate = extractDate,
                         Global = Global) 

    #prepare Reproduction data
    Datarep <- Rep_prepdata(coresubset =   Dataspe$data, 
                         Data[[taxa]]$Collection, Data[[taxa]]$Parent, Data[[taxa]]$Move,
                         BirthType_parent = "Captive", BirthType_offspring = "Captive",
                         minNrep=minNrepro, minNparep =minNparepro, Global = Global)
    if(nrow(Datarep$data)>0){
    #Litter sizes
    out <- Rep_littersize(Datarep$Reprodata, perAge = FALSE,
                      Nday = Nday, parentProb = parentProb,  minNlitter =minNlitter)
    
      df = out$littSizeDf%>%mutate(Species = species)
    
    TAB <- rbind(TAB, df)
    }
}

TAB
```

### Age at first reproduction

``` r
library(tidyverse)
library(ISRverse)
library(glue)

# CHANGE THIS to Path to the ZIMSdata directory: 
ZIMSdir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/Data"
extractDate = "2023-12-04"
minDate = "1980-01-01"
Global = TRUE

taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Alces alces","Lasiurus cinereus", "Gorilla gorilla"))

# Conditions to run the reproduction analyses
uncert_birth = 365  #Maximum uncertainty accepted for birth dates, in days
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records


Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdir, 
                      species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = lubridate::as_date("2023/12/23"))

TAB = tibble()
for (species in List_species[[taxa]]){
  print(species)
  Dataspe <- select_species(species, Animal, Data[[taxa]]$Collection, uncert_birth = uncert_birth,
                            minDate = minDate , extractDate = extractDate,
                            Global = Global) 
 if(nrow(Dataspe$data)>0){
  for (sx in c("Male", "Female", "All")){
    
    if(sx != "All"){
      coresubset <- Dataspe$data%>%filter(SexType == sx)
    }else{coresubset <- Dataspe$data}
     if(nrow(coresubset)>0){
    #prepare Reproduction data
    Datarep <- Rep_prepdata(coresubset = coresubset, 
                         Data[[taxa]]$Collection, Data[[taxa]]$Parent, Data[[taxa]]$Move,
                         BirthType_parent = "Captive", BirthType_offspring = "Captive",
                         minNrep=minNrepro, minNparep =minNparepro, Global = Global)
    if(nrow(Datarep$Reprodata)>0){
    #Calculate reproductive age statistics
    out <- Rep_agemat(Datarep$Reprodata)%>%
      mutate(Species = species,
             Class = taxa,
             Sex = sx)
    
    TAB <- rbind(TAB, out)
  }}
  }
 }
}

TAB
```

## Tutorial to run Taxon profiles

### Set up your Rstudio environnement

Use the correct directories to find data and run the analyses

#### On your own computer

``` r
# Path to the ZIMSdata directory:
ZIMSdir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/"

analysisDir <- "C:/Users/flopy/Documents/ISR/Data/ISR"

# ISR data directory:
ISRdatDir <- sprintf("%sISRdata/", analysisDir)

# Global data directory:
globDir <- sprintf("%sglobal/", analysisDir)

setwd(analysisDir)
```

#### On Ucloud

``` r

# Install libraries:
instPacks <- installed.packages()[, 1]
if (!"snowfall" %in% instPacks) {
  install.packages("snowfall")
}
if (!"RColorBrewer" %in% instPacks) {
  install.packages("RColorBrewer")
}
if (!"rjson" %in% instPacks) {
  install.packages("rjson")
}
if (!"ggpubr" %in% instPacks) {
  install.packages("ggpubr")
}
# Set one thread (core) for BLAS operations: 
if (!"RhpcBLASctl" %in% instPacks) {
  install.packages("RhpcBLASctl")
  library(RhpcBLASctl)
  blas_set_num_threads(1)
}

# if (!"extractZIMS" %in% instPacks) {
#   install.packages("/work/Species360/Rpackages/latestVersion/extractZIMS_0.1.1.tar.gz", 
#                    type = "source", repos = NULL)
# }
# if (!"paramDemo" %in% instPacks) {
#   install.packages("/work/Species360/Rpackages/latestVersion/paramDemo_1.0.0.tar.gz", 
#                    type = "source", repos = NULL)
# }
if (!"BaSTA2.0" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/BaSTA2.0_2.0.0.tar.gz", 
                   type = "source", repos = NULL)
}
if (!"ISRverse" %in% instPacks) {
  install.packages("/work/Species360/Rpackages/latestVersion/ISRverse_1.0.0.tar.gz", 
                   type = "source", repos = NULL)
}
# Set one thread (core) for BLAS operations: 
if (!"RhpcBLASctl" %in% instPacks) {
  install.packages("RhpcBLASctl")
  library(RhpcBLASctl)
  blas_set_num_threads(1)
}

# Path to the ZIMSdata directory:
ZIMSdir <- "/work/Species360/ZIMSdata_ext231204/"

# General directory:
analysisDir <- "/work/Species360/ISR/"

# ISR data directory:
ISRdatDir <- sprintf("%sISRdata/", analysisDir)

# Global data directory:
globDir <- sprintf("%sglobal/", analysisDir)


setwd(analysisDir)
```

### Libraries

Download the needed libraries

``` r
library(ISRverse)
library(BaSTA2.0)
library(snowfall)
library(RColorBrewer)
library(tidyverse)
library(rjson)
library(stringi)
library(ISRverse)
library(ggplot2)
library(ggpubr)
# library(paramDemo)
# library(extractZIMS)
```

### Choose important arguments

``` r
# Data --------------------------------------------
extractDate = "2024-07-01"

# List of taxa to analyze -------------------------
taxaList <- c("Mammalia", "Aves", "Reptilia", "Amphibia", 
              "Chondrichthyes", "Actinopterygii")

# Sex categories ----------------------------------
BySex <- c(Mammalia = c("Male", "Female"), 
           Aves = c("Male", "Female"), 
           Reptilia = c("Male", "Female", "All"), 
           Amphibia = c("Male", "Female", "All"), 
           Chondrichthyes = c("Male", "Female", "All"), 
           Actinopterygii = "All")


#Filters ----------------------------------
# Earliest date to include records
minDate <- "1980-01-01"
# Minimum number of individuals to run the taxon profile
minN <- 50
# Maximum threshold in the longevity distribution to use
maxOutl <- 99 
# Conditions to run all analyses
minInstitution = 2 
#Maximum uncertainty accepted for birth dates, in days
uncert_birth = 365
#Maximum uncertainty accepted for death dates, in days
uncert_death = 365
#Maximum uncertainty accepted for measurement dates: weight, in days
uncert_date = 365

# Maximum possible age
XMAX = 120


#      Survival Models --------------------------------
models_sur <- c("GO", "LO")
shape = "bathtub"

# Number of CPUS:
ncpus <- 4

# MCMC settings:
niter <- 25000
burnin <- 5001
thinning <- 20


# Conditions to run the survival analysis
minNsur = 50 #Minimum number of individuals
maxNsur = 1000 #Maximum number of individuals
minlx = 0.1  #Minimum survivorship reach by raw life table
MinBirthKnown = 0.3 #Minimum proportions of known birth date (within a month)

#Goodness of fit
Min_MLE = 0.1 #Minimum survivorship at Mean life expectancy
MaxLE = 2     #Maximum remaining life expectancy at max age


#     Reproduction Models ------------------------------
# Conditions to run the reproduction analyses
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records

#Litter size
parentProb = 80 #Minimum percentage of parentage probability to include in litter size
minNlitter = 30 #Minimum number of litters to run the analysis

minNseas = 50

#      Growth Models -----------------------------------
models_gro <- c("GO", "LO") 

# Measure type to select
MeasureType = "Live weight"

# Conditions to run the growth analysis
minNgro = 100 #Minimum number of individuals
minNIgro = 50 #Minimum number of weights
```

### Other Inputs

``` r
# Table with species that require rerruning with higher outlier level:
maxOutLev <- read.csv("ISRanalysisData/tables/maxOutlierLevel.csv", header = TRUE,
                      stringsAsFactors = FALSE)
spOutLev <- maxOutLev$Specie
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

taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")

run_txprofile (taxa, Species_list = "All", ZIMSdir, analysisDir,
               Sections = Sections, 
               extractDate = extractDate, minDate = minDate,
               sexCats = BySex[[taxaList[taxa]]], 
               minN = minN,  maxOutl = maxOutl,  spOutLev = spOutLev,
               uncert_birth = uncert_birth, uncert_death= uncert_death,
                        uncert_date = uncert_date,
                        minInstitution = minInstitution, 
               minNsur = minNsur, maxNsur = maxNsur,
               minlx = minlx, MinBirthKnown = MinBirthKnown, 
               Min_MLE = Min_MLE, MaxLE =  MaxLE,
              models_sur = models_sur, shape = shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, minNrepro = minNrepro, 
               minNparepro = minNparepro, minNseas = minNseas, 
               minNgro = minNgro, minNIgro = minNIgro, MeasureType = MeasureType,
               model_gro = model_gro
               
)
```

#### Option 2: Run one or a group of species from one taxa

``` r

taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")
Species_list = c('Panthera leo', 'Panthera uncia', 'Panthera tigra')

run_txprofile (taxa, Species_list = Species_list, ZIMSdir, analysisDir,
               Sections = Sections, 
               extractDate = extractDate, minDate = minDate,
               sexCats = BySex[[taxaList[taxa]]], 
               minN = minN,  maxOutl = maxOutl,  spOutLev = spOutLev,
               uncert_birth = uncert_birth, uncert_death= uncert_death,
                        uncert_date = uncert_date,
                        minInstitution = minInstitution, 
               minNsur = minNsur, maxNsur = maxNsur,
               minlx = minlx, MinBirthKnown = MinBirthKnown, 
               Min_MLE = Min_MLE, MaxLE =  MaxLE,
              models_sur = models_sur, shape = shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, minNrepro = minNrepro, 
               minNparepro = minNparepro, minNseas = minNseas, 
               minNgro = minNgro, minNIgro = minNIgro, MeasureType = MeasureType,
               model_gro = model_gro
               
)
```

#### Option 3: Run all species from one taxa in parallel on different computers

``` r
#Run this code changing ipara on each different computer
# for example on the first computer:
ipara = 1

taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")
#Number of different computers
XX = 3

run_txprofile (taxa, Species_list = "All", ZIMSdir, analysisDir,
               inparallel = TRUE, ipara = ipara, npara = XX, 
               Sections = Sections, 
               extractDate = extractDate, minDate = minDate,
               sexCats = BySex[[taxaList[taxa]]], 
               minN = minN,  maxOutl = maxOutl,  spOutLev = spOutLev,
               uncert_birth = uncert_birth, uncert_death= uncert_death,
                        uncert_date = uncert_date,
                        minInstitution = minInstitution, 
               minNsur = minNsur, maxNsur = maxNsur,
               minlx = minlx, MinBirthKnown = MinBirthKnown, 
               Min_MLE = Min_MLE, MaxLE =  MaxLE,
              models_sur = models_sur, shape = shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, minNrepro = minNrepro, 
               minNparepro = minNparepro, minNseas = minNseas, 
               minNgro = minNgro, minNIgro = minNIgro, MeasureType = MeasureType,
               model_gro = model_gro
)
```

### Run taxon profiles by taxa

### Group all outputs in one compressed file

### To Json

``` r
write(toJSON(repout), file = sprintf("ISRdata/global/json/%s.json", 
                                     repout$general$speciesID))
```
