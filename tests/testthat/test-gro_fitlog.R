# WARNING - Generated by {fusen} from dev/flat_growth.Rmd: do not edit by hand

logx <- rnorm(100, 0, 1)
logz <- 0.2+ 15 * (1 - exp(-(1) * logx)) +rnorm(100, 0, 0.01)
dat = data.frame(logx = logx, logz = logz,AnimalAnonID = sample(c(0:20), 100, replace = TRUE)
)

test_that(
  "Gro_fitlog error",
  {
    expect_error(
      Gro_fitlog(data = dat, all_mods = "vonBert"),
      regexp = "The growth models supported are: logistic, gompertz, chapmanRichards, vonBertalanffy , and polynomial")
    expect_error(
      Gro_fitlog(data = dat$logz), regexp = "data is not a data frame")
    expect_error(
      Gro_fitlog(num = 2, data = dat))
  })


a= Gro_fitlog(data = dat, all_mods = "vonBertalanffy")

test_that(
  "Gro_fitlog works",
  { 
    expect_named(a, c("fit", "tab", 'growthMod'))
    expect_named(a$tab, c("index", "model", "k", "LSQ"))
    expect_equal(a$tab$k, 3)
    expect_match(a$tab$model, "vonBertalanffy")
    expect_type(a$tab$LSQ, "double")
    expect_equal(a$tab$index, 1)
    expect_s4_class(a$fit, "mle2")
  }
)
