# WARNING - Generated by {fusen} from dev/flat_main.Rmd: do not edit by hand

# file = system.file("coretest.csv", package = 'ISRverse')
# ZIMSdir = dirname(file)
# analysisDir = paste0(tempdir(check = TRUE),'\\temp')
# PlotDir = paste0(tempdir(check = TRUE),'\\temp\\plot')
# dir.create(analysisDir)
# dir.create(PlotDir)
# 
# test_that("run_txprofile works", {
#  
# out <- run_txprofile(taxa = "Mammalia", Species_list = "All", 
#                           ZIMSdir = RastDir, analysisDir = analysisDir,
#                           PlotDir = PlotDir, extractDate = "", 
#                           minDate = "1980-01-01",
#                           Sections = "sur", 
#                           sexCats = c('Male', 'Female')
# )
# 
# expect_true(file.exists(paste(analysisDir, "Gorilla_gorilla.Rdata", sep = '\\')))
# expect_true(file.exists(paste(PlotDir, 'Gorilla_gorilla_LongThres.pdf', sep = '\\')))
# expect_true(file.exists(paste(PlotDir, 'Gorilla_gorillasur.pdf', sep = '\\')))
# expect_true(file.exists(paste(PlotDir, 'Gorilla_gorilla_outliers.png', sep = '\\')))
# expect_true(file.exists(paste(PlotDir, 'Gorilla_gorilla_growth.png', sep = '\\')))
# 
# })
# unlink(RastDirgp, recursive = TRUE)

