# WARNING - Generated by {fusen} from dev/flat_main.Rmd: do not edit by hand

# test_that("Tx_devout works", {
#   file = system.file("sci_Animal.csv", package = 'ISRverse')
#   AnalysisDir  = paste0(dirname(file),'/Rdata')
#   TempDir = paste0(tempdir(check = TRUE),'/temp')
#   dir.create(TempDir,showWarnings =FALSE)
#   SpeciesTable = data.frame( Class = "Reptilia", Species = "Testudo hermanni")
# Tx_devout(SpeciesTable, AnalysisDir, SaveDir =TempDir ,
#                         TaxaList = "Reptilia",
#                         BySex = list(Reptilia = c("Male", "Female")) ,
#                         Sections = c("sur", 'gro')
# )
#   expect_true(file.exists(paste(TempDir, 'Reptilia_Testudo_hermanni.json', sep = '/')))
# 
#   unlink(TempDir, recursive = TRUE)
# })

