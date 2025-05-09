# WARNING - Generated by {fusen} from dev/flat_select.Rmd: do not edit by hand

test_that("Prep_Animal works", {
  file = system.file("sci_Animal.csv", package = 'ISRverse')
  ZIMSDirtest = dirname(file)
  
  data <- Load_Zimsdata	(Taxa = "Reptilia",
                         Species = list(Reptilia = "All"),
                         ZIMSDir = ZIMSDirtest,
                         Animal = TRUE)
  
  Animal <- Prep_Animal(data$Reptilia$Animal, ExtractDate = "2023/12/23")
  expect_named(Animal, c("AnimalAnonID", "Class", "Order", "Family", 'SpeciesName', "CommonName", "IUCNRedList", "CITES", "CITESE", "FirstHoldingInstitution", "FirstCollectionScopeType", "LastHoldingInstitution", "LastCollectionScopeType", "AnyLocalCollectionFlag", "LatitudeZone", "BirthDate", "BirthDateEstimateType", "BirthType", "BirthObserved", "FirstAcquisitionDate", "SexType", "PhysicalMoveCount", "DeathDate", "DeathDateEstimateType", "GlobalStatus", "AnimalType", "LastCommentEntryDate", "LastTXDate", 'binSpecies', "MinBirthDate", "MaxBirthDate", "MinDeathDate", "MaxDeathDate",  "EntryDate", "EntryType", "DepartDate", "DepartType", "BirthUncertainty", "DeathUncertainty"))
  
})
