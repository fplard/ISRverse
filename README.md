
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

## Tutorial for reproduction

### Age at first reproduction

``` r
library(tidyvserse)
library(ISRverse)

# CHANGE THIS to Path to the ZIMSdata directory: 
ZIMSdir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/"
extractDate = "2023-12-04"
minDate = "1980-01-01"
Global = TRUE

taxa = "Mammalia"
List_species = c()


Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdir, 
              extractDate = extractDate, 
              type = c('core', 'collections', 'parent', 'moves')) 

Tab = tibble()
for (species in List_species){
  
  Data <- select_species(species, core, collection,
                         minDate = minDate , extractDate = extractDate,
                         Global = Global) 
  
  for (sx in c("Male", "Female", "All")){
    
    if(sx != "All"){
      coresubset <- core%>%filter(Sex == sx)
    }else{coresubset <- core}
    #prepare Reproduction data
    Data <- Rep_prepdata(coresubset = coresubset, 
                         collection, parent, moves,
                         BirthType_parent = "Captive", BirthType_offspring = "Captive",
                         Age_uncert = 365, Global = Global)
    #Calculate reproductive age statistics
    out <- Rep_agemat(Data$Reprodata)%>%
      mutate(Species = species,
             Class = taxa,
             Sex = sx)
    
    TAB <- rbind(TAB, out)
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
minlx = 0.1  #Minimum survivorship reach by raw life table
MinBirthKnown = 0.3 #Minimum proportions of known birth date (within a month)

#     Reproduction Models ------------------------------
# Conditions to run the reproduction analysis
parentProb = 80
minNrepro = 100
minNparepro = 30
minNseas = 50

#      Growth Models -----------------------------------
models_gro <- c("GO", "LO") 

# Measure type to select
MeasureType = ""

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
               minNsur = minNsur, minlx = minlx, MinBirthKnown = MinBirthKnown, 
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
               minNsur = minNsur, minlx = minlx, MinBirthKnown = MinBirthKnown, 
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
               minNsur = minNsur, minlx = minlx, MinBirthKnown = MinBirthKnown, 
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
