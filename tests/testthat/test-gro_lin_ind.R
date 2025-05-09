# WARNING - Generated by {fusen} from dev/flat_growth.Rmd: do not edit by hand

data <- tibble(AnimalAnonID = rep(c(1,2), c(10,15)),
               Age = c(c(1:10), c(1:15)),
               MeasurementValue = 2+3*Age)
data$MeasurementValue[1] = 0.5
data$MeasurementValue[3] = data$MeasurementValue[3]+50
data$MeasurementValue[14] = data$MeasurementValue[3]+30
data$MeasurementValue[20] = data$MeasurementValue[3]+100

test_that(
  "Gro_lin_ind error",
  {
    expect_error(
      data %>% Gro_lin_ind(IQR =0.5),
      regexp = "IQR should be higher than 1 to avoid removing real data")
    expect_error(
      data[1:4,] %>% Gro_lin_ind(),
      regexp = "There should be at least 5 measures")
  })



test_that(
  "Gro_lin_ind Tested ",
  { 
    expect_named(
      data %>% Gro_lin_ind(),
      c("AnimalAnonID", "Age", "MeasurementValue", "Keep2"))
    expect_equal(
      sum(data %>% Gro_lin_ind(IQR= 1.5, remove_ext = F, traj_ind = F)%>%pull(Keep2)),
      25-3)
    expect_equal(
      sum(data %>% Gro_lin_ind(remove_ext = F)%>%pull(Keep2)),
      25-3)
    expect_equal(
      sum(data %>% Gro_lin_ind(IQR= 1.5)%>%pull(Keep2)),
      25-3)
  }
)
