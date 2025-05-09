# WARNING - Generated by {fusen} from dev/flat_growth.Rmd: do not edit by hand

Age <- sample(c(0:10), 1000, replace = T)
MeasurementValue <- exp(0.2+15 * (1 - exp(-(0.1) * log(Age+1)))+ rnorm(1000,0,0.01))-1 
AnimalAnonID <- sample(c(0:20), 100, replace = TRUE)
dat = data.frame(Age = Age, MeasurementValue = MeasurementValue, 
                 AnimalAnonID = AnimalAnonID, MeasurementType = "Live Weight")
out = dat %>% Gro_analysis()

test_that(
  "Gro_plot",
  {
    expect_error(dat$MeasurementValue %>% Gro_plot(out$percent),
                 regexp = "data is not a data frame")
    expect_error(dat %>% Gro_plot(out$percent$Age),
                 regexp = "data_percent is not a data frame")
  })

test_that(
  "Gro_plot",
  { 
    p<- dat %>% Gro_plot(out$percent)
    expect_named(p$labels,c("title", "x", "y", "ymin", "ymax"))
    expect_length(p$layers,3)
  })

