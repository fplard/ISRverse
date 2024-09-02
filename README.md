
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
path <- system.file("docs", "index.html", package = "ISRverse")
browseURL(path)
```

## Set up your Rstudio environnement

Use the correct directories to find data and run the analyses

#### On your own computer

``` r
# Path to the ZIMSdata directory:
ZIMSdir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/"

ZIMSdirdata <- glue ("{ZIMSdir}Data")
analysisDir <- glue ("{ZIMSdir}Analyses/")

# directory to save Rdata:
ISRdatDir <-  glue ("{analysisDir}Rdata/")
# directory to save Json for the dev team:
ISRdatDir <-  glue ("{analysisDir}Json/")
# Plot directory:
plotDir <- glue ("{analysisDir}Plot/")

setwd(analysisDir)
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

# General directory:
ZIMSdirdata <- "/work/Species360/ZIMSdata_ext240829"

# General directory:
analysisDir <- glue ("/work/Species360/Demo_Analyses/")

# directory to save Rdata:
ISRdatDir <-  glue ("{analysisDir}Rdata/")
# directory to save Json for the dev team:
ISRdatDir <-  glue ("{analysisDir}Json/")
# Plot directory:
plotDir <- glue ("{analysisDir}Plot/")
```

### Libraries

Download the needed libraries

``` r
library(ISRverse)
library(tidyverse)
library(rjson)
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
extractDate ="2024-08-29"
Split_Zimsdata  (ZIMSdir = ZIMSdirdata, extractDate = extractDate) 
```

## Tutorial for reproduction

### Litter size

``` r
extractDate ="2024-08-29"
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

Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdirdata, 
                      species = List_species,
            Animal = TRUE,
              tables= c('Collection', 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = lubridate::as_date("2024/08/29"))
  
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
    if(nrow(Datarep$Reprodata)>0){
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
extractDate ="2024-08-29"
minDate = "1980-01-01"
Global = TRUE

taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Alces alces","Lasiurus cinereus", "Gorilla gorilla"))

# Conditions to run the reproduction analyses
uncert_birth = 365  #Maximum uncertainty accepted for birth dates, in days
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records


Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdirdata, 
                      species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = lubridate::as_date("2024/08/29"))

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

### Choose important arguments

``` r
# Data --------------------------------------------
extractDate = "2024-07-01"

# List of taxa to analyze -------------------------
taxaList <- c("Mammalia", "Aves", "Reptilia", "Amphibia", 
              "Chondrichthyes", "Actinopterygii")

# Sex categories ----------------------------------
BySex <- list(Mammalia = c("Male", "Female"), 
           Aves = c("Male", "Female"), 
           Reptilia = c("Male", "Female", "All"), 
           Amphibia = c("Male", "Female", "All"), 
           Chondrichthyes = c("Male", "Female", "All"), 
           Actinopterygii = "All")


#Filters ----------------------------------
# Earliest date to include records
minDate <- "1980-01-01"
#Whether to include only Global individuals
Global = TRUE
#Birth Type of Animals: "Captive", "Wild" or "All"
Birth_Type = "Captive"
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
# Survival Models to run: "GO", "LO", "EX" or/and "WE"
models_sur <- c("GO", "LO")
#Shape of the survival model: "simple", "bathtub" or "Makeham"
shape = "bathtub"

# Number of CPUS:
ncpus <- 4

# MCMC settings:
niter <- 25000
burnin <- 5001
thinning <- 20
nchain <- 3

# Conditions to run the survival analysis
minNsur = 50 #Minimum number of individuals
maxNsur = 1000 #Maximum number of individuals
minlx = 0.1  #Minimum survivorship reach by raw life table
MinBirthKnown = 0.3 #Minimum proportions of known birth date (within a month)

#Goodness of fit
Min_MLE = 0.1 #Minimum survivorship at Mean life expectancy
MaxLE = 2     #Maximum remaining life expectancy at max age


#     Reproduction Models ------------------------------
# Reproductive Analyses to run: "agemat" or/and "litter"
Repsect = c('agemat', 'litter')

# Conditions to run the reproduction analyses
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records

#Litter/clutch size
parentProb = 80 #Minimum percentage of parentage probability to include in litter size
minNlitter = 30 #Minimum number of litters to run the analysis
Nday = 7 #Number of days to group all offspring in one litter/clutch

#Seasonnality
minNseas = 50  #Minimum number of births to run the seasonnality analysis

#      Growth Models -----------------------------------
#Models: "logistic", "gompertz", "chapmanRichards", "vonBertalanffy", and/or "polynomial"
models_gro <- c("vonBertalanffy") 

# Measure type to select
MeasureType = "Live weight"

# Conditions to run the growth analysis
minNgro = 100 #Minimum number of individuals
minNIgro = 50 #Minimum number of weights
```

### Other Inputs

``` r
# Table with species that require rerruning with higher outlier level:
maxOutLev <- read.csv(glue("{analysisDir}maxOutlierLevel.csv"), header = TRUE,
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

run_txprofile (taxaList[taxa], Species_list = "All", ZIMSdirdata, 
                AnalysisDir = analysisDir, PlotDir = plotDir,
                 Sections = Sections, erase_previous = FALSE,
               extractDate = extractDate, minDate = minDate,
               sexCats = BySex[[taxaList[taxa]]], 
               minN = minN,  Global =  Global,
               maxOutl = maxOutl,  spOutLev = spOutLev, Birth_Type = "Captive", 
               uncert_birth = uncert_birth, uncert_death= uncert_death,
                        uncert_date = uncert_date,
                        minInstitution = minInstitution, 
               minNsur = minNsur, maxNsur = maxNsur, XMAX = XMAX,
               minlx = minlx, MinBirthKnown = MinBirthKnown, 
               Min_MLE = Min_MLE, MaxLE =  MaxLE,
              models_sur = models_sur, shape = shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, minNrepro = minNrepro, 
               minNparepro = minNparepro, minNseas = minNseas, 
              minNlitter = minNlitter, Nday = Nday, 
               minNgro = minNgro, minNIgro = minNIgro, MeasureType = MeasureType,
               models_gro = models_gro
               
)
```

#### Option 2: Run one or a group of species from one taxa

``` r

taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")
Species_list = c('Panthera leo', 'Panthera uncia', 'Panthera tigra')

run_txprofile (taxaList[taxa], Species_list = Species_list, ZIMSdirdata,
              AnalysisDir = analysisDir, PlotDir = plotDir,
                 Sections = Sections, erase_previous = FALSE,
               extractDate = extractDate, minDate = minDate,
               sexCats = BySex[[taxaList[taxa]]], 
               minN = minN,  Global =  Global,
               maxOutl = maxOutl,  spOutLev = spOutLev, Birth_Type = "Captive", 
               uncert_birth = uncert_birth, uncert_death= uncert_death,
                        uncert_date = uncert_date,
                        minInstitution = minInstitution, 
               minNsur = minNsur, maxNsur = maxNsur, XMAX = XMAX,
               minlx = minlx, MinBirthKnown = MinBirthKnown, 
               Min_MLE = Min_MLE, MaxLE =  MaxLE,
              models_sur = models_sur, shape = shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, minNrepro = minNrepro, 
               minNparepro = minNparepro, minNseas = minNseas, 
              minNlitter = minNlitter, Nday = Nday, 
               minNgro = minNgro, minNIgro = minNIgro, MeasureType = MeasureType,
               models_gro = models_gro
)
```

#### Option 3: Run all species from one taxa in parallel on different computers

``` r
#Run this code changing ipara on each different computer
XX = 3
# for example on the first computer:
ipara = 1

taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")
#Number of different computers

run_txprofile (taxaList[taxa], Species_list = "All", ZIMSdirdata, 
               inparallel = TRUE, ipara = ipara, npara = XX, 
          AnalysisDir = analysisDir, PlotDir = plotDir,
                 Sections = Sections, erase_previous = FALSE,
               extractDate = extractDate, minDate = minDate,
               sexCats = BySex[[taxaList[taxa]]], 
               minN = minN,  Global =  Global,
               maxOutl = maxOutl,  spOutLev = spOutLev, Birth_Type = "Captive", 
               uncert_birth = uncert_birth, uncert_death= uncert_death,
                        uncert_date = uncert_date,
                        minInstitution = minInstitution, 
               minNsur = minNsur, maxNsur = maxNsur, XMAX = XMAX,
               minlx = minlx, MinBirthKnown = MinBirthKnown, 
               Min_MLE = Min_MLE, MaxLE =  MaxLE,
              models_sur = models_sur, shape = shape,
               niter = niter, burnin = burnin, thinning = thinning, 
               nchain = nchain, ncpus = ncpus,
               parentProb = parentProb, minNrepro = minNrepro, 
               minNparepro = minNparepro, minNseas = minNseas, 
              minNlitter = minNlitter, Nday = Nday, 
               minNgro = minNgro, minNIgro = minNIgro, MeasureType = MeasureType,
               models_gro = models_gro
               
)
```

### Group all outputs in one compressed file

### Make the output for the Dev Team

``` r
write(toJSON(repout), file = sprintf("ISRdata/global/json/%s.json", 
                                     repout$general$speciesID))
```

### Compress the output
