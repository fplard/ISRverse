# WARNING - Generated by {fusen} from dev/flat_growth.Rmd: do not edit by hand

data(raw_weights)
data(core)


test_that("Gro_ana Captive works", {
  output= Gro_Main(data = raw_weights, coresubse = core,
                   taxa = "Mammalia", species = "Gorilla gorilla" ,
                   BirthType = c("Captive", "Wild"), 
                   agemat = 1,
                   type = "weight", MeasureType = "Live weight",
                   minNgro = 30, minNIgro = 30, 
                   models = c("vonBertalanffy", "logistic"), percentiles = c(2.5,97.5)) 
  
  expect_named(output,c("Captive", "Wild"))
  expect_named(output$Captive,c("wSummar", "weightQ"))
  expect_named(output$Captive$wSummar,
               c("NInd_raw", "NWeight_raw", "NWeight_val", "NInd_val", 
                 "NWeight_age", "NInd_age", "error", "Nerr", "agemat", "NJuv", 
                 "NJuv_keep", "NAd", "NAd_keep", "NWeight", "NInd", "analyzed"))
  expect_equal(output$Captive$wSummar$NWeight_raw, 1072)
  expect_equal(output$Captive$wSummar$Nerr, 6)
  expect_equal(output$Captive$wSummar$NWeight, 753)
  expect_true(output$Captive$wSummar$analyzed)
  expect_match(output$Captive$wSummar$error,"Model did not fit")
  expect_equal(output$Wild$wSummar$NJuv, 0)
  expect_equal(output$Wild$wSummar$Nerr, 1)
  expect_equal(output$Wild$wSummar$NAd, 0)
  expect_false(output$Wild$wSummar$analyzed)
  expect_match(output$Wild$wSummar$error,"No raw data")
  expect_named(output$Captive$weightQ, c("percent", "fit", "AIC_tab", "GOF"))
  
})
