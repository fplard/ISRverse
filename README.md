
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
library(glue)
# Path to the ZIMSdata directory:
ZIMSdir <- "C:/Users/flopy/Documents/ISR/TaxonProfiles/"

ZIMSdirdata <- glue ("{ZIMSdir}Data")
analysisDir <- glue ("{ZIMSdir}Analyses/")

# directory to save Rdata:
RdataDir <-  glue ("{analysisDir}Rdata/")
# directory to save Json for the dev team:
JsonDir <-  glue ("{analysisDir}Json/")
# Plot directory:
plotDir <- glue ("{ZIMSdir}Plot/")

setwd(analysisDir)
library(ISRverse)
library(tidyverse)
library(rjson)
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
ZIMSdirdata <- "/work/Species360/ZIMSdata_ext240829"

# General directory:
analysisDir <- glue ("/work/Species360/Demo_Analyses/")

# directory to save Rdata:
RdataDir <-  glue ("{analysisDir}Rdata/")
# directory to save Json for the dev team:
JsonDir <-  glue ("{analysisDir}Json/")
# Plot directory:
plotDir <- glue ("{analysisDir}Plot/")
```

### Libraries

Download the needed libraries

``` r
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
extractDate ="2024-08-29"
Split_Zimsdata  (ZIMSdir = ZIMSdirdata, extractDate = extractDate) 
```

## Tutorial for survival

``` r
extractDate ="2024-08-29"
taxa = "Mammalia"
List_species = list(Mammalia = c("Capra sibirica", "Cuon alpinus", "Nanger granti"))

#Filters ----------------------------------
# Earliest date to include records
minDate <- "1980-01-01"
# Earliest birth date to include records
minBirthDate <- "1900-01-01"
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
# Maximum possible age
XMAX = 120
#Age when to start the analysis
minAge =c(0)
#Whether to run the first year survival analysis
firstyear = F


#      Survival Models --------------------------------
# Survival Models to run: "GO", "LO", "EX" or/and "WE"
models_sur <- c("GO", "LO")
#Shape of the survival model: "simple", "bathtub" or "Makeham"
shape = "bathtub"

# Number of CPUS:
ncpus <- 4

# MCMC settings:
niter <- 10000
burnin <- 3001
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

# Table with species that require rerruning with higher outlier level:
maxOutLev <- read.csv(glue("{analysisDir}maxOutlierLevel.csv"), header = TRUE,
                      stringsAsFactors = FALSE)
spOutLev <- maxOutLev$Specie

#Load Data
Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdirdata, 
                      species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', 'DeathInformation')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = lubridate::as_date("2024/08/29"))

for (species in List_species[[taxa]]){
  print(species)
  if (species %in% spOutLev) {maxOutl1 <- 99.9
  }else{maxOutl1 <- maxOutl}
  Dataspe <- select_species(species, Animal, Data[[taxa]]$Collection, uncert_birth = uncert_birth,
                            minDate = minDate , extractDate = extractDate,
                            Global = Global) 
  if(nrow(Dataspe$data)>0){
    out = list()
    for (sx in c("Male", "Female")){
      print(sx)
      sexDat <- select_Longthreshold( Dataspe$data,  sexCats = sx, 
                                      PlotDir= glue::glue("{plotDir}test2/"),
                                      minN = minN ,
                                      maintitle = glue::glue("{taxa}_{species}_{sx}") )
      outlLev1 = min(sexDat$summar$GapThresh,maxOutl, na.rm = T)
      
  
      if(nrow(sexDat$data)>0){ 
        #Calculate reproductive age statistics
        out[[sx]] <-  Sur_main(data.core = sexDat$data,  DeathInformation =  Data[[taxa]]$DeathInformation,
                               Birth_Type = Birth_Type, lastdead = T,
                               PlotDir = glue::glue("{plotDir}test2/"),
                               XMAX = XMAX,
                               models = models_sur, shape= shape, 
                               outlLev1 =outlLev1,
                               Min_MLE = Min_MLE, MaxLE =  MaxLE,
                               mindate = minDate, minNsur = minNsur, maxNsur = maxNsur, 
                               minInstitution = minInstitution,uncert_death= uncert_death,
                               minlx = minlx , MinBirthKnown = MinBirthKnown, 
                               niter = niter, burnin = burnin, thinning = thinning, nchain = nchain, 
                               ncpus = ncpus, plotname = glue("{taxa}_{species}_{sx}") )
        print(out$summary$error)
      }
    }
  }
}

plot(out$bastaRes, plot.type = 'gof')
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
      print(sx)
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

## Tutorial for growth

``` r
#Directory where to save results
SaveDir = glue ("{analysisDir}savegrowth")
PlotDir = glue ("{analysisDir}plotgrowth")
extractDate ="2024-08-29"


taxa = "Mammalia"
List_species = list(Mammalia = c("Panthera leo", "Panthera onca","Panthera uncia", "Panthera tigris", "Panthera pardus"))
List_species = list(Mammalia = c("Cervus elaphus"))
sexCats = c("Female", "Male", "All")

#Filters
# Earliest date to include records
minDate <- "1980-01-01"
# Earliest birth date to include records
minBirthDate <- "1900-01-01"
#Whether to include only Global individuals
Global = TRUE
#Birth Type of Animals: "Captive", "Wild" or "All"
Birth_Type = "Captive"
# Maximum threshold in the longevity distribution to use
maxOutl <- 99 
#Maximum uncertainty accepted for birth dates, in days
uncert_birth = 365
#Maximum uncertainty accepted for measurement dates: weight, in days
uncert_date = 365


#Models: "logistic", "gompertz", "chapmanRichards", "vonBertalanffy", "gam", and/or "polynomial"
models_gro <- c("vonBertalanffy", "gompertz") 

# Measure type to select
MeasureType = "Live weight"

# Conditions to run the growth analysis
minNgro = 100 #Minimum number of weights
minNIgro = 50 #Minimum number of individuals


# Conditions to estimate age at sexual maturity
minNrepro = 100   #Minimum number of birth records
minNparepro = 30  #Minimum number of unique parent records


Data <- Load_Zimsdata(taxa = taxa, ZIMSdir = ZIMSdirdata, 
                      species = List_species,
                      Animal = TRUE,
                      tables= c('Collection', "Weight", 'Parent', 'Move')) 
Animal <- Prep_Animal(Data[[taxa]]$Animal, extractDate = extractDate, minBirthDate =minBirthDate)

for (species in List_species[[taxa]]){
  print(species)
  Dataspe <- select_species(species, Animal, Data[[taxa]]$Collection, uncert_birth = uncert_birth,
                            minDate = minDate , extractDate = extractDate,
                            Global = Global) 
  
  if(nrow(Dataspe$data)>0){
    repr = weig = list()
    for (sx in sexCats){
      cat(paste0(" ****************************  ",sx,"  ****************************\n"))
      #Let's see later if we need to set a threshold for the longevity distribution
      # sexDat <- select_Longthreshold( Dataspe$data,  sexCats = sx, 
      #                                 PlotDir= PlotDir, minN = minN,
      #                                 maintitle = glue::glue("{species}_{sx}") )
      if(sx != "All"){
        coresubset <- Dataspe$data%>%filter(SexType == sx)
      }else{coresubset <- Dataspe$data}
      if(nrow(coresubset)>0){
        #Estimate age at sexual maturity
        repr[[sx]] <- Rep_main(coresubset= coresubset, Data[[taxa]]$Collection, 
                               Data[[taxa]]$Parent, Data[[taxa]]$Move,  
                               Repsect = "agemat",
                               BirthType_parent = Birth_Type, BirthType_offspring = Birth_Type, 
                               Global = Global, 
                               minNrepro = minNrepro, minNparepro =  minNparepro
        )
        
        agemat = NULL
        if(length(repr[[sx]])>0){
          if(repr[[sx]]$summary$amat_analyzed){
            agemat =repr[[sx]]$agemat$ageMat
          }
        }
        
        weig[[sx]] <- Gro_Main(data = Data[[taxa]]$Weight, coresubse = coresubset,
                               taxa = taxa, species = species,
                               Birth_Type = Birth_Type, 
                               agemat = agemat, percentiles = c(2.5,97.5),
                               PlotDir = PlotDir, type = "weight",
                               uncert_date = uncert_date,
                               MeasureType = MeasureType,
                               minNgro = minNgro, minNIgro = minNIgro, 
                               models = models_gro,
                               mindate = minDate, plotname = glue("{species}_{sx}") )
        
      }
    }
    save(weig, file = glue("{SaveDir}/{species}_growth.Rdata"))   
  }      
  
}
#Look at what is in "weig" and we will work on additional code to make the analysis of several species easier to save and to compare results
```

## Tutorial to run Taxon profiles

### Choose important arguments

``` r
# Data --------------------------------------------
extractDate = "2024-08-29"

# List of taxa to analyze -------------------------
taxaList <- c("Mammalia", "Aves", "Reptilia", "Amphibia", 
              "Chondrichthyes", "Osteichthyes")

# Sex categories ----------------------------------
BySex <- list(Mammalia = c("Male", "Female"), 
              Aves = c("Male", "Female"), 
              Reptilia = c("Male", "Female", "All"), 
              Amphibia = c("Male", "Female", "All"), 
              Chondrichthyes = c("Male", "Female", "All"), 
              Osteichthyes = "All")


#Filters ----------------------------------
# Earliest date to include records
minDate <- "1980-01-01"
# Earliest birth date to include records
minBirthDate <- "1900-01-01"
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

#Age when to start the analysis
minAge =c(0)
#Whether to run the first year survival analysis
firstyear = TRUE
#Whether the oldest individuals should be considered as dead by the model
lastdead = T


#      Survival Models --------------------------------
# Survival Models to run: "GO", "LO", "EX" or/and "WE"
models_sur <- c("GO", "LO")
#Shape of the survival model: "simple", "bathtub" or "Makeham"
shape = "bathtub"

# Number of CPUS:
ncpus <- 4

# MCMC settings:
niter <- 10000
burnin <- 3001
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
models_gro <- c("vonBertalanffy", "gam") 

# Measure type to select
MeasureType = "Live weight"

# Conditions to run the growth analysis
minNgro = 100 #Minimum number of weights
minNIgro = 30 #Minimum number of individuals
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
Sections = c("sur")

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

list_surv= readxl::read_xlsx(glue("{analysisDir}Liste_Survival.xlsx"), sheet =1)%>%
  filter(Class == "Mammalia")%>%
  pull(Species)%>%unique()

taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")
# Sections = c("sur")
# Species_list =list_surv
Species_list =c("Panthera onca", "Loris_tardigradus", "Pteropus_livingstonii")

run_txprofile (taxa = taxaList[taxa], 
               ZIMSdir =ZIMSdirdata,AnalysisDir = analysisDir, PlotDir = plotDir,
               erase_previous = FALSE,Birth_Type = "Captive", 
               sexCats = BySex[[taxaList[taxa]]], inparallel = FALSE,
               Species_list = Species_list,  Sections = Sections,  
               extractDate = extractDate, minDate = minDate, 
               minAge = minAge, firstyear = firstyear,lastdead =lastdead,
               minBirthDate = minBirthDate, minN = minN,  Global =  Global,
               maxOutl = maxOutl,  spOutLev = spOutLev, 
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
# for example on the first computer:
ipara = 1


#Run this code changing ipara on each different computer
XX = 5
taxa <- 1
#Sections to run or to update
Sections = c("sur", "rep", "gro")
#Number of different computers

run_txprofile (taxaList[taxa], Species_list = "All", ZIMSdirdata, 
               inparallel = TRUE, ipara = ipara, npara = XX, 
               AnalysisDir = analysisDir, PlotDir = plotDir,
               Sections = Sections, erase_previous = FALSE,
               minAge = minAge, firstyear = firstyear,lastdead =lastdead,
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
save(ipara, file = glue("{analysisDir}/{ipara}finished.Rdata"))
```

### Check

#### Find species with sex with 50-1000 individuals

``` r


minNsur = 10000000 #Minimum number of individuals
#Sections to run or to update
Sections = c("sur")
Species_list = "All"
for (taxa in 6:2){
  
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
}
```

#### Check of the species with issues reported

Issues reported in document “Taxon Profile Version2 CSA
Documentation_October 2023”

List of species : Kihansi spray toad, Hellbender, Tufted capuchin,
Guianan squirrel monkey, Green woodhoopoe, Green and black poison frog,
Rock eagle owl, Plains-wanderer

``` r
Spec_list  = list(Amphibia = c("Nectophrynoides asperginis", "Cryptobranchus alleganiensis", "Dendrobates auratus"),
                  Mammalia = c("Sapajus apella", "Saimiri sciureus"),
                  Aves = c("Phoeniculus purpureus", "Bubo bengalensis", 'Pedionomus torquatus'))

for (taxa in c(1,2,4)){
  #Sections to run or to update
  Sections = c("sur", "rep", "gro")
  
  run_txprofile (taxa = taxaList[taxa], 
                 ZIMSdir =ZIMSdirdata,AnalysisDir = analysisDir, PlotDir = plotDir,
                 erase_previous = FALSE,Birth_Type = "Captive", 
                 sexCats = BySex[[taxaList[taxa]]], inparallel = FALSE,
                 Species_list = Spec_list[[taxaList[taxa]]],  Sections = Sections,  
                 extractDate = extractDate, minDate = minDate, 
                 minBirthDate = minBirthDate, minN = minN,  Global =  Global,
                 maxOutl = maxOutl,  spOutLev = spOutLev, 
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
}
```

Tufted capuchin: \* Male = \>1000 individuals \* Female : a lot of
undead individuals so we have a high life expectancy compared to what
observed but the model seems to fit ok “Min(Life_exp) \>= MaxLE”

Guianan squirrel monkey \* Male = \>1000 individuals \* Female = \>1000
individuals

Green woodhoopoe \* Male “Min(Life_exp) \>= MaxLE” \* Female
“Min(Life_exp) \>= MaxLE”

Rock eagle owl \* Male “Nglobal \< minNsur” \* FeMale “Nglobal \<
minNsur”

Plains-wanderer \* Male “lxMin \> minlx” \* FeMale “lxMin \> minlx”

Kihansi spray toad \* Male “Nglobal \< minNsur” \* Female “Nglobal \<
minNsur”

Hellbender \* Male lxMin \> minlx” \* Female “lxMin \> minlx”

Green and black poison frog \* Male “Min(Life_exp) \>= MaxLE” \* Female
“Min(Life_exp) \>= MaxLE”

### Make the summary tables

``` r
# List of taxa to summarize -------------------------
taxaList <- c("Mammalia", "Aves", "Reptilia", "Amphibia", 
              "Chondrichthyes", "Osteichthyes")

# Sex categories ----------------------------------
BySex <- list(Mammalia = c("Male", "Female"), 
              Aves = c("Male", "Female"), 
              Reptilia = c("Male", "Female", "All"), 
              Amphibia = c("Male", "Female", "All"), 
              Chondrichthyes = c("Male", "Female", "All"), 
              Osteichthyes = "All")


SummTab <- make_summary(AnalysisDir=glue("{analysisDir}Rdata"), 
                        SaveDir = glue("{analysisDir}"),
                        taxaList = taxaList[1],
                        BySex = BySex ,
                        Sections = c("sur", "rep", "gro")
)
```

### Make the output for the Dev Team

``` r
write(toJSON(repout), file = sprintf("ISRdata/global/json/%s.json", 
                                     repout$general$speciesID))
```

### Compress the output
