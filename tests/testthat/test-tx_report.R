# WARNING - Generated by {fusen} from dev/flat_select.Rmd: do not edit by hand

test_that("tx_report works", {
  file = system.file("sci_Animal.csv", package = 'ISRverse')
  ZIMSDirtest = dirname(file)
  data <- Load_Zimsdata	(Taxa = "Reptilia",
                         Species = list(Reptilia = "All"), ZIMSDir = ZIMSDirtest,
                         Animal = TRUE, tables = c("Collection","DeathInformation", 
                                                   "Weight", "Parent", "Move", 
                                                   "Contraception"))
  Animal<- Prep_Animal(data[["Reptilia"]]$Animal, ExtractDate= "2024/08/29" )
  PlotDir = paste0(tempdir(check = TRUE),'/temp')
  dir.create(PlotDir)
  
  out <- tx_report(Species = "Testudo hermanni", Taxa = "Reptilia",
                   Animal, data$Reptilia$Collection,
                   Move = data$Reptilia$Move, Parents =data$Reptilia$Parent,
                   Contraceptions = data$Reptilia$Contraception,
                   MinBirthKnown = 0,
                   MinLx =0.5,MinNIGro=40,
                   BirthType = "All", UncertBirth = 3500, UncertDeath = 3500, 
                   DeathInformation =data$Reptilia$DeathInformation,
                   Weights =data$Reptilia$Weight,
                   niter = 1000, burnin = 101, thinning = 10, nchain = 3, ncpus = 3,
                   PlotDir = PlotDir, Sections = c('sur','gro', 'rep'),
                   SexCats = c("Male", "Female"),
                   ModelsSur = "GO", Shape = "simple",
                   ModelsGro = "vonBertalanffy"
  )
  expect_named(out, c('general', "summary", 'repr', 'surv', 'weig'))
  expect_named(out$general, c('NRaw', 'NDate', 'NGlobal', 'NBirthType', 'NUncertBirth', 'NAlive', 'FirstDate', 'MaxAgeRaw', 'ExtractDate'))
  expect_named(out$sur, c('Male', "Female"))
  expect_named(out$sur$Male, c("from0"))
  expect_named(out$sur$Male$from0, c('summary', 'metrics', 'bastaRes', 'DICmods', 'KM_estimator', 'relex', 'Sur1', 'Sur5', 'L90', 'L50', 'check', 'relex_from0', 'Sur1m'))
  expect_named(out$weig, c('Male', "Female"))
  expect_named(out$weig$Male$All, c('wSummar', "weightQ"))
  expect_named(out$weig$Female$All, c('wSummar', "weightQ"))
  expect_true(file.exists(paste(PlotDir, "Long_dist/Reptilia_Testudo_hermanni_Male_LongThres.pdf", sep = '/')))
  expect_true(file.exists(paste(PlotDir, "Survival/10_Reptilia_Testudo_hermanni_Male_0_surcheck.pdf", sep = '/')))
  expect_true(file.exists(paste(PlotDir, "Survival/10_Reptilia_Testudo_hermanni_Male_0_surplot.pdf", sep = '/')))
  expect_true(file.exists(paste(PlotDir, "Growth/Reptilia_Testudo_hermanni_Male_All_outliers.png", sep = '/')))
  expect_true(file.exists(paste(PlotDir, "Growth/Reptilia_Testudo_hermanni_Male_All_growth.png", sep = '/')))
  unlink(PlotDir, recursive = TRUE)
})
